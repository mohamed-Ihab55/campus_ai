"""
reranker.py — Groq LLM-based reranker
======================================================================

Role in the RAG pipeline
-------------------------
                    Query
                      │
          ┌───────────▼────────────┐
          │  Hybrid Search (RRF)   │  ← retriever.py (fast, recall-focused)
          │  returns 8+ candidates │
          └───────────┬────────────┘
                      │
          ┌───────────▼────────────┐
          │  Groq LLM Reranker     │  ← THIS FILE (precision-focused)
          │  Uses LLM in JSON mode │
          │  to rank candidates    │
          │  returns best 5        │
          └───────────┬────────────┘
                      │
          ┌───────────▼────────────┐
          │   Groq LLM (answer)    │  ← groq_client.py
          └────────────────────────┘

Graceful degradation
--------------------
If the model fails to load or score, chunks are returned in their
original RRF order — the pipeline keeps working without reranking.
"""

import json
import time
import asyncio
from groq import AsyncGroq

from app.core.config import settings
from app.core.logging_setup import get_logger

logger = get_logger(__name__)

# Re-use the existing Groq client setup
_client = AsyncGroq(api_key=settings.groq_api_key)
_reranker_available: bool | None = None


# ── Public API ────────────────────────────────────────────────────────────────

async def rerank_chunks(
    query: str,
    chunks: list[dict],
    top_k: int = 5,
    lang: str = "ar",
) -> list[dict]:
    """
    Rerank a list of retrieved chunks using the Groq LLM.

    Parameters
    ----------
    query  : the user's question
    chunks : list of dicts with at least {"text": str, "source": str}
    top_k  : number of chunks to return after reranking
    lang   : "ar" or "en" (not used)

    Returns
    -------
    list[dict] — same schema as input chunks, with an added "rerank_score" key,
    sorted by rerank_score descending.
    """
    if not chunks:
        return []

    # ── No need to rerank if candidates ≤ top_k ──────────────────────────────
    if len(chunks) <= top_k:
        logger.info("[RERANKER] %d مقطع فقط ≤ top_k=%d — لا حاجة لإعادة الترتيب", len(chunks), top_k)
        return [{**c, "rerank_score": c.get("rrf_score", 0.0)} for c in chunks]

    # ── Skip if model unavailable ─────────────────────────────────────────────
    if _reranker_available is False:
        logger.info("[RERANKER] النموذج غير متاح — استخدام ترتيب RRF الأصلي")
        return [
            {**c, "rerank_score": c.get("rrf_score", 0.0)}
            for c in chunks[:top_k]
        ]

    # ── Score all chunks via Groq ─────────────────────────────────────────────
    logger.info(
        "[RERANKER] إعادة ترتيب %d مقطع بواسطة Groq (%s)...",
        len(chunks), settings.groq_model,
    )

    chunk_map = {f"chunk_{i}": c for i, c in enumerate(chunks)}
    
    prompt = f"""You are a relevance ranking assistant.
Rank the following document chunks based on their relevance to the user's query.

User Query: "{query}"

Chunks:
"""
    for chunk_id, chunk in chunk_map.items():
        text = chunk.get("text", "").strip()[:500] 
        prompt += f"\n--- {chunk_id} ---\n{text}\n"

    prompt += f"""
Return ONLY a valid JSON object containing a single key "ranked_ids" which is a list of the chunk IDs ordered from most relevant to least relevant. Provide up to {top_k} IDs. Do not include markdown formatting or explanations.
Example: {{"ranked_ids": ["chunk_3", "chunk_0", "chunk_1"]}}
"""

    t = time.time()
    try:
        response = await _client.chat.completions.create(
            model=settings.groq_model,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.0,
            response_format={"type": "json_object"}
        )
        content = response.choices[0].message.content.strip()
        elapsed = time.time() - t
        
        data = json.loads(content)
        ranked_ids = data.get("ranked_ids", [])
        
        # Build the final ordered list
        result = []
        score = 1.0
        step = 1.0 / len(ranked_ids) if ranked_ids else 0.1
        
        for cid in ranked_ids:
            if cid in chunk_map:
                c = chunk_map[cid]
                result.append({**c, "rerank_score": round(score, 4)})
                score -= step
                
        # Fill in any missing ones from original chunks if top_k is not reached
        if len(result) < top_k:
            existing_texts = {r["text"] for r in result}
            for c in chunks:
                if len(result) >= top_k:
                    break
                if c["text"] not in existing_texts:
                    result.append({**c, "rerank_score": 0.0})
                    existing_texts.add(c["text"])

        logger.info(
            "[RERANKER] تم التقييم بواسطة Groq في %.2f ثانية", elapsed
        )
        return result[:top_k]

    except Exception as exc:
        logger.warning("[RERANKER] فشل التقييم: %s — استخدام ترتيب RRF", exc, exc_info=True)
        return [
            {**c, "rerank_score": c.get("rrf_score", 0.0)}
            for c in chunks[:top_k]
        ]


# ── Startup verification ──────────────────────────────────────────────────────

async def warmup_reranker() -> bool:
    """Check Groq API connection at startup.
    Sets ``_reranker_available`` so subsequent calls can skip if it fails.
    Returns True if reranking works.
    """
    global _reranker_available

    try:
        await _client.chat.completions.create(
            model=settings.groq_model,
            messages=[{"role": "user", "content": 'Return {"test": 1} in JSON format'}],
            temperature=0.0,
            max_tokens=10,
            response_format={"type": "json_object"}
        )
        
        logger.info("[RERANKER] ✅ Warmup OK — Groq API ready for reranking")
        _reranker_available = True
        return True

    except Exception as exc:
        logger.warning("[RERANKER] ❌ Warmup FAILED — %s", exc)
        _reranker_available = False
        return False
