import json
import httpx
from app.core.config import settings
from app.core.logging_setup import get_logger

logger = get_logger(__name__)

_OLLAMA_TIMEOUT = httpx.Timeout(settings.ollama_timeout)


def is_followup_question(question: str) -> bool:
    """
    اكشف ما إذا كان السؤال يعتمد على context سابق.

    يعتمد على 4 إشارات:
    - قصير (≤8 كلمات)
    - يحتوي على كلمة استفهام غير محددة
    - يحتوي على ضمير إشاري (ده/هذا)
    - يبدأ بحرف عطف (و/ف/لكن)

    إذا توفّرت إشارتان أو أكثر → سؤال متابِع.
    """
    followup_keywords = [
        "لماذا", "كيف", "ماذا", "وضح", "اشرح", "يعني", "طيب", "وإيه",
        "why", "how", "what do you mean", "explain", "elaborate",
        "and what about", "what else",
    ]
    pronouns = ["ده", "دي", "هذا", "هذه", "ذلك", "تلك", "it", "this", "that"]

    is_short         = len(question.split()) <= 8
    has_keyword      = any(kw in question.lower() for kw in followup_keywords)
    has_pronoun      = any(p  in question.lower() for p  in pronouns)
    starts_with_conj = question.strip().startswith(("و", "ف", "لكن", "but", "and"))

    signals = sum([is_short, has_keyword, has_pronoun, starts_with_conj])
    return signals >= 2


async def rewrite_query(question: str, history: list[dict]) -> str:
    """
    أعد صياغة السؤال ليكون مستقلاً باستخدام الـ LLM.

    إذا فشل الـ LLM لأي سبب → يُعاد السؤال الأصلي بدون تغيير.
    هذا يضمن أن الفشل لا يوقف المحادثة.
    """
    if not history:
        return question

    rewrite_prompt = (
        "بناءً على تاريخ المحادثة التالي والسؤال الأخير، أعد صياغة السؤال الأخير "
        "ليكون سؤالاً كاملاً ومستقلاً يمكن البحث به في المستندات. "
        "لا تجب على السؤال، فقط أعد صياغته في جملة واحدة.\n\n"
        f"التاريخ: {json.dumps(history[-2:], ensure_ascii=False)}\n"
        f"السؤال: {question}\n"
        "السؤال المعاد صياغته:"
    )

    try:
        async with httpx.AsyncClient(timeout=_OLLAMA_TIMEOUT) as client:
            response = await client.post(
                settings.ollama_url,
                json={
                    "model":    settings.ollama_model,
                    "messages": [{"role": "user", "content": rewrite_prompt}],
                    "stream":   False,
                },
            )
            if response.status_code == 200:
                rewritten = response.json()["message"]["content"].strip()
                logger.info("تمت إعادة صياغة السؤال: %s", rewritten)
                return rewritten
    except Exception as exc:
        logger.warning("فشل إعادة الصياغة: %s", exc)

    return question  # fallback: السؤال الأصلي