
import time
from dataclasses import dataclass
from langdetect import detect as detect_lang, LangDetectException

from app.core.config import settings
from app.core.logging_setup import get_logger
from app.retrieval import get_retriever
# from app.retrieval import get_retriever # rerank_chunks DISABLED: using Groq API
from app.retrieval.reranker import rerank_chunks
from app.pipeline.query_handler import is_followup_question, rewrite_query
from app.pipeline.context_builder import build_context, extract_sources
from app.pipeline.prompt_builder import build_system_prompt

logger = get_logger(__name__)


@dataclass
class PipelineResult:
    """نتيجة تشغيل الـ pipeline — تُمرَّر للـ LLM مباشرة."""
    messages: list[dict]   # الرسائل المجهّزة للـ LLM (system + history + user)
    sources: list[str]     # مصادر الـ chunks المسترجعة
    language: str          # "ar" أو "en"
    prep_time: float       # الوقت المستغرق في الاستعداد (بالثواني)
    chunks_count: int      # عدد الـ chunks المسترجعة


def _detect_language(text: str) -> str:
    """اكشف لغة النص. الافتراضي: عربي."""
    try:
        lang = detect_lang(text)
        return lang if lang in ("ar", "en") else "ar"
    except LangDetectException:
        return "ar"


async def run(
    question: str,
    session_id: str,
    history: list[dict],
) -> PipelineResult:
    t_start = time.time()
    lang = _detect_language(question)

    # ── الخطوة 2: إعادة صياغة أسئلة المتابعة ─────────────────────────────────
    search_query = question
    if history and is_followup_question(question):
        search_query = await rewrite_query(question, history)

    # ── الخطوة 3: استرجاع الـ chunks ──────────────────────────────────────────
    retriever = get_retriever()
    chunks = retriever.search(search_query, top_k=settings.top_k)
    logger.info(
        "تم استرجاع %d chunks | session=%s | query='%s'",
        len(chunks), session_id, search_query[:50]
    )

    # ── الخطوة 4: إعادة الترتيب بالـ Reranker ─────────────────────────────────
    # DISABLED: local HuggingFace reranker replaced by Groq API before discussion day.
    chunks = await rerank_chunks(search_query, chunks, top_k=5, lang=lang)
    # chunks = chunks[:5]  # fallback: take top 5 from RRF order
    
    # ── الخطوة 5: بناء السياق ─────────────────────────────────────────────────
    context = build_context(chunks)
    sources = extract_sources(chunks)

    # ── الخطوة 6 + 7: بناء الرسائل للـ LLM ───────────────────────────────────
    system_prompt = build_system_prompt(lang)
    messages = [
        {"role": "system", "content": f"{system_prompt}\n\nContext:\n{context}"},
        *history,
        {"role": "user", "content": question},
    ]

    prep_time = round(time.time() - t_start, 2)
    logger.info(
        "اكتمل التحضير | prep=%.2fs | chunks=%d | sources=%s",
        prep_time, len(chunks), sources
    )

    return PipelineResult(
        messages=messages,
        sources=sources,
        language=lang,
        prep_time=prep_time,
        chunks_count=len(chunks),
    )