import asyncio
from groq import AsyncGroq
from app.core.config import settings
from app.core.logging_setup import get_logger
from app.memory import memory

logger = get_logger(__name__)

_client = AsyncGroq(api_key=settings.groq_api_key)
_KEEPALIVE_INTERVAL = settings.keepalive_interval


async def stream_response(
    messages: list[dict],
    session_id: str,
    original_question: str,
):
    """
    بث الرد من Groq مع حفظ المحادثة في الذاكرة.
    """
    full_answer      = ""
    stream_completed = False
    logger.info("بدء توليد الإجابة | session=%s", session_id)

    token_queue: asyncio.Queue = asyncio.Queue()

    async def _reader():
        nonlocal stream_completed
        try:
            stream = await _client.chat.completions.create(
                model=settings.groq_model,
                messages=messages,
                stream=True,
                temperature=0.1,
                top_p=0.7,
                max_tokens=4096,
            )
            async for chunk in stream:
                token = chunk.choices[0].delta.content or ""
                if token:
                    await token_queue.put(("token", token))
            stream_completed = True
        except Exception as exc:
            logger.error("خطأ في قراءة Groq: %s", exc, exc_info=True)
            await token_queue.put(("error", f"\n[ERROR: {exc}]"))
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
                yield "​"  # heartbeat — مسافة صغيرة غير مرئية
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
    """تحقق من الاتصال بـ Groq عند بدء التطبيق."""
    try:
        await _client.chat.completions.create(
            model=settings.groq_model,
            messages=[{"role": "user", "content": "hi"}],
            max_tokens=1,
        )
        logger.info("تم الاتصال بـ Groq | النموذج: %s", settings.groq_model)
        return True
    except Exception as exc:
        logger.warning("فشل الاتصال بـ Groq: %s", exc)
        return False
