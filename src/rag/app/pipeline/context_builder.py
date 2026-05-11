from app.core.config import settings


def format_chunk(index: int, chunk: dict) -> str:
    """
    نسّق chunk واحد مع ترويسة تحتوي على معلومات السياق.

    المدخل:
        index: رقم الـ chunk (0-based)
        chunk: dict يحتوي على "text" و "metadata"

    المخرج:
        نص منسّق مع ترويسة بين أقواس مربعة
        مثال:
        [مقتطف 1 — السياق: برنامج الرياضيات — المستوى 3 — الفصل: الأول]
        ... نص الـ chunk ...
    """
    meta       = chunk.get("metadata", {})
    article    = meta.get("article_number", "")
    breadcrumb = (
        meta.get("breadcrumb", "")
        or meta.get("section", "")
        or meta.get("chapter_title", "")
    )
    chunk_type = meta.get("chunk_type", "")
    level      = meta.get("level_number", "")
    semester   = meta.get("semester", "")

    tags = []
    if breadcrumb:
        tags.append(f"السياق: {breadcrumb}")
    if level:
        tags.append(f"المستوى {level}")
    if semester:
        tags.append(f"الفصل: {semester}")
    if article:
        tags.append(f"مادة رقم {article}")
    if chunk_type == "table":
        tags.append("جدول")

    tag_str = " — " + " — ".join(tags) if tags else ""
    return f"[مقتطف {index + 1}{tag_str}]\n{chunk['text']}"


def build_context(chunks: list[dict], max_chars: int | None = None) -> str:
    """
    ابنِ نص السياق الكامل من قائمة الـ chunks.

    ⚠️ مهم: يُوقف إضافة chunks قبل تجاوز الحد المسموح،
    لا يقطع chunk في المنتصف (لأن ذلك يكسر الجداول).

    المدخل:
        chunks: قائمة chunks من الـ retriever/reranker
        max_chars: الحد الأقصى للأحرف (الافتراضي من settings)

    المخرج:
        نص مجمّع مفصول بـ "---" بين الـ chunks
    """
    if not chunks:
        return ""

    limit = max_chars or settings.max_context_chars
    separator = "\n\n---\n\n"
    included = []
    total_len = 0

    for i, chunk in enumerate(chunks):
        formatted = format_chunk(i, chunk)
        added_len = len(formatted) + (len(separator) if included else 0)

        # أوقف إذا تجاوزنا الحد — لكن لا تقطع chunk في المنتصف
        if total_len + added_len > limit and included:
            break

        included.append(formatted)
        total_len += added_len

    return separator.join(included)


def extract_sources(chunks: list[dict]) -> list[str]:
    """استخرج قائمة مصادر فريدة من الـ chunks."""
    return list({chunk.get("source", "") for chunk in chunks if chunk.get("source")})