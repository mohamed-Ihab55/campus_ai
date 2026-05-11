import os
from dotenv import load_dotenv

load_dotenv()


class Settings:
    # ── نموذج اللغة (Ollama) ──────────────────────────────────────────────────
    ollama_model: str = os.getenv("OLLAMA_MODEL", "gemma3")
    ollama_url: str   = os.getenv("OLLAMA_URL", "http://127.0.0.1:11434/api/chat")

    # ── الاسترجاع والتضمين ───────────────────────────────────────────────────
    # نموذج التضمين — يجب أن يكون نفسه في الاستيعاب والاسترجاع دائماً
    embed_model: str      = os.getenv("EMBED_MODEL", "paraphrase-multilingual-mpnet-base-v2")
    chroma_path: str      = os.getenv("CHROMA_PATH", "vectorstore")
    chroma_collection: str = os.getenv("CHROMA_COLLECTION", "rag_docs")
    top_k: int            = min(int(os.getenv("TOP_K", "8")), 8)
    max_context_chars: int = int(os.getenv("MAX_CONTEXT_CHARS", "10000"))

    # ── Reranker (HuggingFace) ────────────────────────────────────────────────
    hf_api_token: str       = os.getenv("HF_API_TOKEN", "")
    reranker_model: str     = os.getenv("RERANKER_MODEL", "Qwen/Qwen3-Reranker-0.6B")
    reranker_concurrency: int = int(os.getenv("RERANKER_CONCURRENCY", "4"))

    # ── ذاكرة المحادثة ────────────────────────────────────────────────────────
    max_turns: int    = int(os.getenv("MAX_TURNS", "6"))
    max_sessions: int = int(os.getenv("MAX_SESSIONS", "200"))
    session_ttl: int  = int(os.getenv("SESSION_TTL", "3600"))

    # ── استيعاب المستندات ────────────────────────────────────────────────────
    data_dir: str      = os.getenv("DATA_DIR", "data/markdown")
    chunk_size: int    = int(os.getenv("CHUNK_SIZE", "1600"))
    chunk_overlap: int = int(os.getenv("CHUNK_OVERLAP", "200"))

    # ── الشبكة ───────────────────────────────────────────────────────────────
    # في بيئة الإنتاج: ضع عناوين المحددة مثل "https://myapp.com"
    allowed_origins: list[str] = [
        o.strip()
        for o in os.getenv("ALLOWED_ORIGINS", "*").split(",")
        if o.strip()
    ]

    # ── Timeouts ─────────────────────────────────────────────────────────────
    # None = لا timeout (الاستنتاج على CPU قد يأخذ 200+ ثانية)
    ollama_timeout = None
    keepalive_interval: int = 20  # ثانية — heartbeat للـ SSE


# Singleton — يُستخدم في كل مكان
settings = Settings()