import os
import sys

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

setup_logging()
logger = get_logger("startup")


@asynccontextmanager
async def lifespan(app: FastAPI):
    from pathlib import Path
    from app.retrieval import get_retriever
    # from app.llm.ollama_client import warmup_model
    from app.llm.groq_client import warmup_model
    from app.retrieval.reranker import warmup_reranker

    Path(settings.data_dir).mkdir(parents=True, exist_ok=True)
    Path("data/pdfs").mkdir(parents=True, exist_ok=True)

    guide_path = Path(settings.data_dir) / "guide.md"
    if guide_path.exists():
        retriever = get_retriever()
        if retriever.collection.count() == 0:
            logger.info("قاعدة البيانات المتجهية فارغة — بدء الاستيعاب التلقائي...")
            from app.ingestion import ingest_all_markdown
            from app.retrieval import reset_retriever
            ingest_all_markdown(settings.data_dir)
            reset_retriever()

    retriever = get_retriever()
    retriever.embed_model.encode(["warm up"], normalize_embeddings=True)
    logger.info("تم تسخين نموذج التضمين")

    await warmup_model()
    await warmup_reranker()

    # logger.info("التطبيق جاهز — %s", settings.ollama_model)
    logger.info("التطبيق جاهز — %s", settings.groq_model)
    yield
    logger.info("التطبيق يُغلق...")


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