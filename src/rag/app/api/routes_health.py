
import httpx
from fastapi import APIRouter
from pydantic import BaseModel

from app.core.config import settings
from app.retrieval import get_retriever
from app.memory import memory

router = APIRouter()

_OLLAMA_BASE_URL = settings.ollama_url.split("/api/")[0]


@router.get("/health")
async def health():
    """
    تحقق من حالة النظام.

    يُعيد:
        status: "ok" أو "error"
        ollama_connected: هل Ollama يستجيب؟
        chunks_indexed: عدد chunks في قاعدة البيانات
        sessions_active: عدد الجلسات النشطة في الذاكرة
    """
    retriever = get_retriever()
    ollama_ok = False
    try:
        async with httpx.AsyncClient(timeout=httpx.Timeout(5.0)) as client:
            r = await client.get(f"{_OLLAMA_BASE_URL}/api/tags")
            ollama_ok = r.status_code == 200
    except (httpx.HTTPError, OSError):
        pass

    return {
        "status":           "ok" if ollama_ok else "error",
        "ollama_connected": ollama_ok,
        "model":            settings.ollama_model,
        "chunks_indexed":   retriever.collection.count(),
        "sessions_active":  memory.session_count,
    }


class RetrieveRequest(BaseModel):
    question: str
    top_k: int | None = None


@router.post("/retrieve")
async def retrieve(req: RetrieveRequest):
    """أداة debug: شاهد ما يسترجعه النظام لأي سؤال."""
    retriever = get_retriever()
    k = req.top_k or settings.top_k
    chunks = retriever.search(req.question, top_k=k)
    return {"chunks": chunks}