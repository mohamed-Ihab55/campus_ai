from pathlib import Path
from app.core.logging_setup import get_logger

logger = get_logger(__name__)

_PROMPTS_DIR = Path(__file__).resolve().parent.parent.parent / "prompts"


def build_system_prompt(language: str) -> str:
    """
    ارجع الـ system prompt المناسب حسب اللغة.

    المعاملات:
        language: "ar" للعربية، "en" للإنجليزية

    الإرجاع:
        نص الـ prompt الكامل
    """
    filename = "system_ar.txt" if language == "ar" else "system_en.txt"
    prompt_path = _PROMPTS_DIR / filename

    if not prompt_path.exists():
        logger.error("ملف الـ Prompt غير موجود: %s", prompt_path)
        # Fallback أساسي إذا لم يوجد الملف
        return (
            "You are an academic assistant for Faculty of Science, Ain Shams University. "
            "Answer only from the provided context."
        )

    return prompt_path.read_text(encoding="utf-8")