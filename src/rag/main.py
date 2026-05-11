"""
main.py — نقطة الدخول الوحيدة للتطبيق.
=========================================
هذا الملف مسؤول عن شيء واحد فقط:
    تجميع كل أجزاء التطبيق وتشغيله.

لا يحتوي على أي منطق.
أي منطق يجب أن يكون في app/
"""

import os
import sys

# إجبار UTF-8 على Windows
if sys.stdout.encoding != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if sys.stderr.encoding != "utf-8":
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

os.environ["ANONYMIZED_TELEMETRY"] = "False"
os.environ["CHROMA_TELEMETRY"]     = "False"

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.logging_setup import setup_logging, get_logger
from app.api.routes_chat import router as chat_router
from app.api.routes_health import router as health_router

# إعداد الـ logging فوراً
setup_logging()
logger = get_logger("startup")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Startup/Shutdown hooks.
    يُنفَّذ عند بدء التشغيل، و yield يعني "التطبيق يعمل الآن".
    """
    from pathlib import Path
    from app.retrieval import get_retriever
    from app.llm.ollama_client import warmup_model

    # أنشئ المجلدات اللازمة
    Path(settings.data_dir).mkdir(parents=True, exist_ok=True)
    Path("data/pdfs").mkdir(parents=True, exist_ok=True)

    # تحقق من الـ vectorstore — أعد الاستيعاب تلقائياً إذا كان فارغاً
    guide_path = Path(settings.data_dir) / "guide.md"
    if guide_path.exists():
        retriever = get_retriever()
        if retriever.collection.count() == 0:
            logger.info("قاعدة البيانات المتجهية فارغة — بدء الاستيعاب التلقائي...")
            from app.ingestion import ingest_all_markdown
            ingest_all_markdown(settings.data_dir)

    # تسخين نموذج التضمين
    retriever = get_retriever()
    retriever.embed_model.encode(["warm up"], normalize_embeddings=True)
    logger.info("تم تسخين نموذج التضمين")

    # تحميل Ollama مسبقاً
    await warmup_model()

    logger.info("✅ التطبيق جاهز — %s", settings.ollama_model)
    yield
    logger.info("التطبيق يُغلق...")


# ── إنشاء التطبيق ──────────────────────────────────────────────────────────────
app = FastAPI(
    title="ASU RAG Chatbot",
    version="3.0.0",
    description="مساعد أكاديمي ذكي لطلاب كلية العلوم - جامعة عين شمس",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["X-Session-ID", "X-Sources", "X-Response-Time"],
)

# ── تسجيل الـ Routes ───────────────────────────────────────────────────────────
app.include_router(chat_router)
app.include_router(health_router)


@app.get("/")
async def root():
    return {"status": "ok", "message": "ASU RAG Chatbot API v3.0"}