import asyncio
import json
import httpx
from app.core.config import settings
from app.core.logging_setup import get_logger
from app.memory import memory

logger = get_logger(__name__)

_OLLAMA_TIMEOUT  = httpx.Timeout(settings.ollama_timeout)
_KEEPALIVE_INTERVAL = settings.keepalive_interval


async def stream_response(
    messages: list[dict],
    session_id: str,
    original_question: str,
):

    full_answer      = ""
    stream_completed = False
    logger.info("بدء توليد الإجابة | session=%s", session_id)

    token_queue: asyncio.Queue = asyncio.Queue()

    async def _reader():
        """مهمة خلفية تقرأ من Ollama وتضع التوكنات في قائمة الانتظار."""
        nonlocal stream_completed
        try:
            async with httpx.AsyncClient(timeout=_OLLAMA_TIMEOUT) as client:
                async with client.stream(
                    "POST",
                    settings.ollama_url,
                    json={
                        "model":      settings.ollama_model,
                        "messages":   messages,
                        "stream":     True,
                        "keep_alive": -1,
                        "options": {
                            "temperature": 0.1,
                            "top_p":       0.7,
                            "num_ctx":     8192,
                        },
                    },
                ) as response:
                    if response.status_code != 200:
                        body = await response.aread()
                        logger.error("خطأ من Ollama HTTP %d: %s", response.status_code, body[:200])
                        await token_queue.put(("error", f"\n[ERROR|{response.status_code}]"))
                        return

                    async for line in response.aiter_lines():
                        if not line:
                            continue
                        try:
                            chunk = json.loads(line)
                        except json.JSONDecodeError:
                            continue
                        token = chunk.get("message", {}).get("content", "")
                        if token:
                            await token_queue.put(("token", token))
                        if chunk.get("done"):
                            stream_completed = True
                            break

        except Exception as exc:
            logger.error("خطأ في قراءة Ollama: %s", exc, exc_info=True)
        finally:
            await token_queue.put(("done", None))

    reader_task = asyncio.create_task(_reader())

    try:
        while True:
            try:
                kind, content = await asyncio.wait_for(
                    token_queue.get(), timeout=_KEEPALIVE_INTERVAL
                )
            except asyncio.TimeoutError:
                yield "\u200b"  # heartbeat — مسافة صغيرة غير مرئية
                continue

            if kind == "done":
                break
            if kind == "error":
                yield content
                break
            full_answer += content
            yield content

    finally:
        reader_task.cancel()
        try:
            await reader_task
        except asyncio.CancelledError:
            pass

        if full_answer.strip():
            saved = full_answer if stream_completed else full_answer + " [...]"
            memory.add(session_id, "user", original_question)
            memory.add(session_id, "assistant", saved)


async def warmup_model() -> bool:

    try:
        async with httpx.AsyncClient(timeout=httpx.Timeout(300.0)) as client:
            await client.post(
                settings.ollama_url,
                json={
                    "model":      settings.ollama_model,
                    "messages":   [{"role": "user", "content": "hi"}],
                    "stream":     False,
                    "keep_alive": -1,
                },
            )
        logger.info("تم تحميل نموذج %s في الذاكرة", settings.ollama_model)
        return True
    except Exception as exc:
        logger.warning("فشل تحميل Ollama مسبقاً (سيُحمّل عند أول طلب): %s", exc)
        return False