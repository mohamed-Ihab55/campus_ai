# ── RERANKER DISABLED ──────────────────────────────────────────────────────────
# Currently using Groq API instead of local HuggingFace reranker.
# Will be re-enabled and upgraded before discussion day.
# ──────────────────────────────────────────────────────────────────────────────
import os
import asyncio
import math
import httpx
from dotenv import load_dotenv

load_dotenv()

# ── Configuration ─────────────────────────────────────────────────────────────
HF_API_TOKEN    = os.getenv("HF_API_TOKEN", "")
RERANKER_MODEL  = os.getenv("RERANKER_MODEL", "Qwen/Qwen3-Reranker-0.6B")
HF_API_BASE     = "https://api-inference.huggingface.co/models"
HF_API_URL      = f"{HF_API_BASE}/{RERANKER_MODEL}"

# Max parallel calls to the HF Inference API.
# The free tier has a rate limit (~10 req/s); keep this at 4-5 to stay safe.
_CONCURRENCY    = int(os.getenv("RERANKER_CONCURRENCY", "4"))

# Instruction that tells the model what "relevant" means in this domain.
_INSTRUCTION_AR = (
    "بناءً على سؤال الطالب، حدد ما إذا كان المقطع التالي من دليل الطالب "
    "يحتوي على إجابة مفيدة ومباشرة للسؤال"
)
_INSTRUCTION_EN = (
    "Given a student's question about Faculty of Science at Ain Shams University, "
    "determine whether the following passage from the student guide contains "
    "a relevant and direct answer"
)


# ── Prompt formatter ──────────────────────────────────────────────────────────

def _format_prompt(query: str, passage: str, instruction: str) -> str:
    return (
        "<|im_start|>system\n"
        "Judge whether the Document meets the requirements based on the Query "
        "and the Instruct provided. "
        "Note that the answer can only be \"yes\" or \"no\"."
        "<|im_end|>\n"
        "<|im_start|>user\n"
        f"<Instruct>: {instruction}\n"
        f"<Query>: {query}\n"
        f"<Document>: {passage}"
        "<|im_end|>\n"
        "<|im_start|>assistant\n"
        "<think>\n\n</think>\n"
    )


# ── Single-pair scorer ────────────────────────────────────────────────────────

async def _score_pair(
    client: httpx.AsyncClient,
    semaphore: asyncio.Semaphore,
    headers: dict,
    query: str,
    passage: str,
    instruction: str,
) -> float:
    """
    Score one (query, passage) pair via the HF Inference API.

    Returns a float in [0, 1]:
      - Uses log-probability of the "yes" token when details=True is available
        (continuous score — ideal for ranking).
      - Falls back to binary 1.0 / 0.0 if logprobs are unavailable.
      - Returns 0.5 on any API error (neutral score — preserves original order).

    بالعربي: يرجع رقم بين 0 و 1 يمثل مدى صلة الـ passage بالسؤال.
    """
    prompt = _format_prompt(query, passage, instruction)

    async with semaphore:
        try:
            resp = await client.post(
                HF_API_URL,
                headers=headers,
                json={
                    "inputs": prompt,
                    "parameters": {
                        "max_new_tokens": 1,
                        "return_full_text": False,
                        "details": True,         # request logprobs for continuous score
                    },
                },
                timeout=30.0,
            )

            if resp.status_code == 503:
                # Model is loading (cold start) — wait and retry once
                print(f"[RERANKER] Model loading (503), waiting 20s...")
                await asyncio.sleep(20)
                resp = await client.post(
                    HF_API_URL,
                    headers=headers,
                    json={
                        "inputs": prompt,
                        "parameters": {
                            "max_new_tokens": 1,
                            "return_full_text": False,
                            "details": True,
                        },
                    },
                    timeout=30.0,
                )

            if resp.status_code != 200:
                print(f"[RERANKER] API error {resp.status_code}: {resp.text[:120]}")
                return 0.5   # neutral fallback

            data = resp.json()

            # ── Try to extract log-probability of "yes" token ──────────────
            # HF API response structure when details=True:
            # [{"generated_text": "yes", "details": {"tokens": [{"id":..., "logprob":...}]}}]
            try:
                token_details = data[0]["details"]["tokens"][0]
                generated_token = token_details.get("text", "").strip().lower()
                logprob         = token_details.get("logprob", None)

                if logprob is not None:
                    # Convert logprob to probability: p = exp(logprob)
                    prob = math.exp(logprob)
                    # If token is "no", invert: score = 1 - P(no)
                    score = prob if generated_token.startswith("yes") else 1.0 - prob
                    return round(max(0.0, min(1.0, score)), 4)

                # logprob not available — fall back to binary
                generated_text = data[0].get("generated_text", "").strip().lower()
                return 1.0 if "yes" in generated_text else 0.0

            except (KeyError, IndexError, TypeError):
                # Unexpected response format — binary fallback
                generated_text = ""
                if isinstance(data, list) and data:
                    item = data[0]
                    generated_text = (
                        item.get("generated_text", "")
                        if isinstance(item, dict)
                        else str(item)
                    )
                return 1.0 if "yes" in generated_text.lower() else 0.0

        except asyncio.TimeoutError:
            print("[RERANKER] Timeout on one pair — using neutral score 0.5")
            return 0.5
        except Exception as exc:
            print(f"[RERANKER] Unexpected error: {exc}")
            return 0.5


# ── Public API ────────────────────────────────────────────────────────────────

async def rerank_chunks(
    query: str,
    chunks: list[dict],
    top_k: int = 5,
    lang: str = "ar",
) -> list[dict]:

    if not chunks:
        return []

    # ── Graceful degradation: no token → skip reranking ──────────────────────
    if not HF_API_TOKEN:
        print("[RERANKER] HF_API_TOKEN not set — skipping reranking (using RRF order)")
        return [
            {**c, "rerank_score": c.get("rrf_score", 0.0)}
            for c in chunks[:top_k]
        ]

    # ── No need to rerank if candidates ≤ top_k ──────────────────────────────
    if len(chunks) <= top_k:
        print(f"[RERANKER] Only {len(chunks)} candidates ≤ top_k={top_k} — skipping")
        return [{**c, "rerank_score": c.get("rrf_score", 0.0)} for c in chunks]

    instruction = _INSTRUCTION_AR if lang == "ar" else _INSTRUCTION_EN
    headers = {
        "Authorization": f"Bearer {HF_API_TOKEN}",
        "Content-Type": "application/json",
    }

    semaphore = asyncio.Semaphore(_CONCURRENCY)

    print(
        f"[RERANKER] Scoring {len(chunks)} candidates with "
        f"{RERANKER_MODEL} (concurrency={_CONCURRENCY})..."
    )

    async with httpx.AsyncClient() as client:
        score_tasks = [
            _score_pair(client, semaphore, headers, query, c["text"], instruction)
            for c in chunks
        ]
        scores = await asyncio.gather(*score_tasks)

    # ── Pair chunks with scores, sort, return top_k ───────────────────────────
    ranked = sorted(
        zip(chunks, scores),
        key=lambda x: x[1],
        reverse=True,
    )

    result = [
        {**chunk, "rerank_score": score}
        for chunk, score in ranked[:top_k]
    ]

    print(
        f"[RERANKER] Done — top score={result[0]['rerank_score']:.4f}  "
        f"bottom score={result[-1]['rerank_score']:.4f}"
    )
    return result
