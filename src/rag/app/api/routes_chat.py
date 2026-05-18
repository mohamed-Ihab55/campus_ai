import uuid
import json
import time
from fastapi import APIRouter
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field

from app.memory import memory
from app.pipeline import chat_pipeline
# from app.llm.ollama_client import stream_response
from app.llm.groq_client import stream_response
from app.core.logging_setup import get_logger

logger = get_logger(__name__)
router = APIRouter()


class ChatRequest(BaseModel):
    question: str = Field(..., min_length=1, max_length=2000)
    session_id: str | None = None


@router.post("/chat")
async def chat(req: ChatRequest):
    question   = req.question.strip()
    session_id = req.session_id or str(uuid.uuid4())
    history    = memory.get_history(session_id)

    result = await chat_pipeline.run(question, session_id, history)

    async def _stream():
        t_gen = time.time()
        async for token in stream_response(result.messages, session_id, question):
            yield token
        logger.info("اكتمل التوليد | gen=%.2fs | session=%s",
                    round(time.time() - t_gen, 2), session_id)

    return StreamingResponse(
        _stream(),
        media_type="text/event-stream",
        headers={
            "X-Session-ID":    session_id,
            "X-Sources":       json.dumps(result.sources),
            "X-Response-Time": str(result.prep_time),
        },
    )


@router.delete("/session/{session_id}")
def clear_session(session_id: str):
    memory.clear(session_id)
    return {"status": "cleared", "session_id": session_id}