"""
ingest_markdown.py — Table-aware Markdown ingestion for the Arabic RAG pipeline.

Key features (fixes "context fragmentation" failure mode):
  1. MarkdownHeaderTextSplitter with strip_headers=False — header text is
     physically embedded in every chunk, which helps vector search match on
     section names directly.
  2. Breadcrumb injection — every chunk is prefixed with
     "السياق: H1 > H2 > H3" so the LLM always knows which level/department/
     section the text belongs to, even after retrieval lifts it out of place.
  3. Table-aware chunking — markdown tables are detected and either kept
     whole (if they fit CHUNK_SIZE) or split row-wise, with the header row
     (and its |---|---| separator) re-prepended to every fragment so the
     LLM never sees orphaned rows whose columns are unlabeled.
  4. Prose chunks use RecursiveCharacterTextSplitter with Arabic separators.
  5. level_number metadata — extracted from Arabic ordinal / digit patterns
     so retriever can apply structural-query weighting correctly.
"""

import re
import hashlib
import shutil
from pathlib import Path

import chromadb
from sentence_transformers import SentenceTransformer
from langchain_text_splitters import MarkdownHeaderTextSplitter, RecursiveCharacterTextSplitter

# ── Config ────────────────────────────────────────────────────────────────────
CHROMA_PATH   = "vectorstore"
COLLECTION    = "rag_docs"
EMBED_MODEL   = "paraphrase-multilingual-mpnet-base-v2"
CHUNK_SIZE    = 1600      # raised from 1400: prevents ETHR/ENGL edge rows from being cut at chunk boundary
CHUNK_OVERLAP = 200
DATA_DIR      = "data/markdown"

# ── Article-number detection ──────────────────────────────────────────────────
# Boundary-protected match for "مادة رقم 34" / "مادة (34)" / "مادة 34".
# `(?<!\S)` requires the word "مادة" to start a token (preceded by whitespace
# or start-of-string), preventing matches inside another word.
# `(?<!\d)(\d{1,4})(?!\d)` requires the digit run to be self-contained — this
# stops a chunk-boundary that splits "34" into "3...4" from being mis-read as
# article 3 or article 4 (the partial digit fails the boundary check).
_ARTICLE_RE = re.compile(
    r'(?<!\S)مادة\s*(?:رقم\s*)?\(?\s*(?<!\d)(\d{1,4})(?!\d)\s*\)?',
    re.UNICODE,
)

# ── Level-number extraction ───────────────────────────────────────────────────
# Matches: "المستوى الرابع", "المستوى 4", "Level 4", "level4"
# BUG FIX: Also matches colloquial forms where users type ي instead of ى
#          and ا instead of أ (e.g. "المستوي الاول" instead of "المستوى الأول").
_LEVEL_RE = re.compile(
    r'المستو[ىي]\s+(?P<ar>الأول|الاول|الثاني|الثالث|الرابع|الخامس|السادس)'
    r'|المستو[ىي]\s*(?P<d1>\d+)'
    r'|[Ll]evel\s*(?P<d2>\d+)',
    re.UNICODE,
)
_AR_ORDINAL = {
    "الأول": "1", "الاول": "1",
    "الثاني": "2",
    "الثالث": "3",
    "الرابع": "4",
    "الخامس": "5",
    "السادس": "6",
}

# ── Semester extraction ───────────────────────────────────────────────────────
# Detects the academic term so the retriever / LLM can disambiguate
# "Level 4 - Term 1" vs "Level 4 - Term 2" without relying on header layout.
# BUG FIX: Also matches colloquial "الاول" (without hamza on alef).
_SEMESTER_RE = re.compile(
    r'الفصل\s+(?:الدراسي\s+)?(?P<ar>الأول|الاول|الثاني|الثاني عشر|الصيفي)'
    r'|(?P<fall>الخريف)'
    r'|(?P<spring>الربيع)'
    r'|[Tt]erm\s*(?P<t>1|2|I|II)'
    r'|[Ss]emester\s*(?P<s>1|2|I|II)',
    re.UNICODE,
)
_AR_SEMESTER = {
    "الأول": "الأول", "الاول": "الأول",
    "الثاني": "الثاني",
    "الثاني عشر": "الثاني",
    "الصيفي": "الصيفي",
}


def _detect_article_number(text: str) -> str:
    m = _ARTICLE_RE.search(text)
    return m.group(1) if m else ""


def _extract_level_number(text: str) -> str:
    """Return a digit string (e.g. '4') for the academic level found in text."""
    m = _LEVEL_RE.search(text)
    if not m:
        return ""
    if m.group("ar"):
        return _AR_ORDINAL.get(m.group("ar"), "")
    if m.group("d1"):
        return m.group("d1")
    if m.group("d2"):
        return m.group("d2")
    return ""


def _extract_semester(text: str) -> str:
    """Return a normalized term label ('الأول' | 'الثاني' | 'الصيفي') or ''.

    Maps English "Term 1/I", Arabic "الفصل الأول"/"الخريف", and equivalents
    to a canonical Arabic label so the LLM sees a consistent tag regardless
    of how the source markdown spells the term.
    """
    m = _SEMESTER_RE.search(text)
    if not m:
        return ""
    if m.group("ar"):
        return _AR_SEMESTER.get(m.group("ar"), m.group("ar"))
    if m.group("fall"):
        return "الأول"
    if m.group("spring"):
        return "الثاني"
    if m.group("t"):
        return "الأول" if m.group("t") in ("1", "I") else "الثاني"
    if m.group("s"):
        return "الأول" if m.group("s") in ("1", "I") else "الثاني"
    return ""


# ── Program-name extraction ───────────────────────────────────────────────────
_PROG_NAME_RE = re.compile(
    r'(?:برنامج\s+)(?P<name>[^\(\n]+?)(?:\s*\(|\s*$)',
    re.UNICODE,
)

PROGRAM_SYNONYMS: dict[str, list[str]] = {
    # ── Dual-track (longer keys matched first by _detect_query_program) ──
    "الإحصاء الرياضي وعلوم الحاسب": ["الإحصاء الرياضي+علوم الحاسب"],
    "الرياضيات البحتة وعلوم الحاسب": ["الرياضيات البحتة+علوم الحاسب"],
    "الرياضيات البحتة والإحصاء الرياضي": ["الرياضيات البحتة+الإحصاء الرياضي"],
    "الفيزياء وعلوم الحاسب":      ["الفيزياء+علوم الحاسب", "فيزياء+علوم الحاسب"],
    "الفيزياء والكيمياء":          ["الفيزياء+الكيمياء", "فيزياء+كيمياء"],
    "علم الحيوان - الكيمياء":      ["علم الحيوان+الكيمياء"],
    "علم الحيوان والكيمياء":       ["علم الحيوان+الكيمياء"],
    "الحيوان - الكيمياء":          ["علم الحيوان+الكيمياء"],
    "الحيوان والكيمياء":           ["علم الحيوان+الكيمياء"],
    "حيوان - كيمياء":              ["علم الحيوان+الكيمياء"],
    "حيوان وكيمياء":               ["علم الحيوان+الكيمياء"],
    "نبات - كيمياء":               ["نبات+كيمياء"],
    "النبات - الكيمياء":           ["نبات+كيمياء"],
    "جيولوجيا - جيوفيزياء":       ["جيولوجيا+جيوفيزياء"],
    "الجيولوجيا - الجيوفيزياء":   ["جيولوجيا+جيوفيزياء"],
    "الجيولوجيا - الكيمياء":      ["الجيولوجيا+الكيمياء"],
    # ── Single-track ──
    "الرياضيات":                    ["الرياضيات"],
    "الرياضيات البحتة":            ["الرياضيات البحتة"],
    "الإحصاء":                      ["الإحصاء الرياضي"],
    "الاحصاء":                      ["الإحصاء الرياضي"],
    "الإحصاء الرياضي":             ["الإحصاء الرياضي"],
    "الحاسب":                       ["علوم الحاسب"],
    "علوم الحاسب":                  ["علوم الحاسب"],
    "الفيزياء":                     ["الفيزياء"],
    "الفيزياء الحيوية":            ["الفيزياء الحيوية"],
    "الكيمياء":                     ["الكيمياء"],
    "الكيمياء التطبيقية":          ["الكيمياء التطبيقية"],
    "النبات":                       ["النبات"],
    "نبات":                         ["النبات"],
    "قسم النبات":                   ["النبات"],
    "علم النبات":                   ["النبات"],
    "الحيوان":                      ["علم الحيوان"],
    "علم الحيوان":                  ["علم الحيوان"],
    "قسم الحيوان":                  ["علم الحيوان"],
    "الحشرات":                      ["علم الحشرات"],
    "علم الحشرات":                  ["علم الحشرات"],
    "الحشرات الطبية":              ["الحشرات الطبية"],
    "الكيمياء الحيوية":            ["الكيمياء الحيوية"],
    "الميكروبيولوجي":              ["الميكروبيولوجي"],
    "الميكروبيولوجيا":             ["الميكروبيولوجي"],
    "ميكروبيولوجيا":               ["الميكروبيولوجي"],
    "ميكروبيولوجي":                ["الميكروبيولوجي"],
    "الجيولوجيا":                   ["الجيولوجيا"],
    "جيولوجيا":                     ["الجيولوجيا"],
    "الجيوفيزياء":                  ["الجيوفيزياء"],
    "جيوفيزياء البترول":           ["جيوفيزياء البترول"],
    "جيوفيزياء":                    ["الجيوفيزياء"],
}


def _extract_program_name(breadcrumb: str) -> str:
    """Extract canonical program name from breadcrumb/header.

    Single-track: '15- برنامج النبات (تخصص منفرد)' → 'النبات'
    Dual-track:   '14 (مزدوج)- برنامج نبات - كيمياء' → 'نبات+كيمياء'
    Dual-track:   '9- برنامج الفيزياء والكيمياء (مزدوج)' → 'الفيزياء+الكيمياء'
    Special:      'برنامج جيوفيزياء البترول - اللائحة' → 'جيوفيزياء البترول'
    """
    m = _PROG_NAME_RE.search(breadcrumb)
    if not m:
        return ""
    name = m.group("name").strip()
    # Remove trailing editorial suffixes like "- اللائحة الأكاديمية"
    # that appear in breadcrumbs of special subsections.
    name = re.sub(r'\s*-\s+اللائحة.*$', '', name).strip()
    name = re.sub(r'\s*-\s+الخطة.*$', '', name).strip()

    # Dual-track: "X - Y" → "X+Y" (prevents النبات matching نبات+كيمياء)
    if " - " in name and "البترول" not in name:
        parts = [p.strip() for p in name.split(" - ")]
        return "+".join(parts)

    # Dual-track with "و": "الفيزياء والكيمياء" → "الفيزياء+الكيمياء"
    # "الرياضيات البحتة والإحصاء الرياضي" → "الرياضيات البحتة+الإحصاء الرياضي"
    # "الإحصاء الرياضي وعلوم الحاسب" → "الإحصاء الرياضي+علوم الحاسب"
    # Only apply to known dual-track patterns (مزدوج in breadcrumb or known combos).
    _DUAL_WO_PATTERNS = [
        (r"الرياضيات البحتة والإحصاء الرياضي",   "الرياضيات البحتة+الإحصاء الرياضي"),
        (r"الرياضيات البحتة وعلوم الحاسب",       "الرياضيات البحتة+علوم الحاسب"),
        (r"الإحصاء الرياضي وعلوم الحاسب",        "الإحصاء الرياضي+علوم الحاسب"),
        (r"الفيزياء والكيمياء",                    "الفيزياء+الكيمياء"),
        (r"الفيزياء وعلوم الحاسب",                "الفيزياء+علوم الحاسب"),
    ]
    for pattern, replacement in _DUAL_WO_PATTERNS:
        if pattern in name:
            return replacement

    return name


def _detect_query_program(query: str) -> str:
    """Return canonical program name if the query mentions one, else ''."""
    q = query.strip()
    for alias in sorted(PROGRAM_SYNONYMS.keys(), key=len, reverse=True):
        if alias in q:
            return PROGRAM_SYNONYMS[alias][0]
    return ""


def reset_vector_db() -> None:
    db_path = Path(CHROMA_PATH)
    if db_path.exists():
        shutil.rmtree(db_path)
        print(f"[RESET] Deleted vectorstore at {db_path}")


def clean_markdown(text: str) -> str:
    """Light cleanup that PRESERVES table structure."""
    text = re.sub(r'ـ+', '', text)            # tatweel
    text = re.sub(r'\n{3,}', '\n\n', text)    # max two blank lines
    return text.strip()


# ── Table detection helpers ───────────────────────────────────────────────────

def _is_table_line(line: str) -> bool:
    return "|" in line and line.lstrip().startswith("|")


def _is_separator_line(line: str) -> bool:
    """Detect |---|---|  or  |:---:|:---:| style separator rows."""
    s = line.strip()
    if not s.startswith("|"):
        return False
    inner = s.replace("|", "").replace(":", "").replace(" ", "")
    return bool(inner) and set(inner) <= {"-"}


def _split_into_blocks(text: str) -> list[dict]:
    """Walk the section text and group lines into alternating prose / table
    blocks.  Each table block carries its own header+separator so we can
    re-prepend it on every row-group fragment later."""
    lines = text.split("\n")
    blocks: list[dict] = []
    i, n = 0, len(lines)

    while i < n:
        if _is_table_line(lines[i]):
            start = i
            # Consume all table lines (allow blank lines only inside tables)
            while i < n:
                stripped = lines[i].strip()
                if _is_table_line(lines[i]):
                    i += 1
                elif stripped == "" and i + 1 < n and _is_table_line(lines[i + 1]):
                    i += 1  # blank line between table rows — keep going
                else:
                    break
            tbl = lines[start:i]
            # Trim trailing blank lines
            while tbl and tbl[-1].strip() == "":
                tbl.pop()

            if not tbl:
                continue

            # Identify header row and separator
            if len(tbl) >= 2 and _is_separator_line(tbl[1]):
                header_block = tbl[0] + "\n" + tbl[1]   # header row + separator
                body_lines   = tbl[2:]
            elif len(tbl) >= 1 and _is_separator_line(tbl[0]):
                # Separator appears first (malformed); treat first data row as header
                header_block = tbl[0]
                body_lines   = tbl[1:]
            else:
                # No separator found — treat first row as header without separator
                header_block = tbl[0]
                body_lines   = tbl[1:]

            blocks.append({
                "type":   "table",
                "header": header_block,   # always includes the column-header row
                "rows":   body_lines,
                "full":   "\n".join(tbl),
            })
        else:
            start = i
            while i < n and not _is_table_line(lines[i]):
                i += 1
            prose = "\n".join(lines[start:i]).strip()
            if prose:
                blocks.append({"type": "prose", "content": prose})

    return blocks


def _merge_header_blocks(blocks: list[dict]) -> list[dict]:
    """Merge standalone header-only prose blocks into the following block.

    The MarkdownHeaderTextSplitter with strip_headers=False can create tiny
    chunks that contain only a heading like '### المستوى الأول - الفصل الأول'
    with no actual data.  These header-only chunks rank higher than the real
    table chunks for level-based queries (because the heading text is a closer
    semantic match to 'المستوى الأول' than table-row data like 'SAFS 101'),
    stealing retrieval slots and causing the LLM to say 'not found'.

    Fix: if a prose block is just a short Markdown heading and is followed by
    another block, merge the heading text into the next block.
    """
    if not blocks:
        return blocks

    merged: list[dict] = []
    i = 0
    while i < len(blocks):
        block = blocks[i]
        content = block.get("content", "") if block["type"] == "prose" else ""
        is_short_header = (
            block["type"] == "prose"
            and content.strip().startswith("#")
            and len(content.strip()) < 200
        )

        if is_short_header and i + 1 < len(blocks):
            next_block = blocks[i + 1]
            if next_block["type"] == "table":
                next_block["full"] = content + "\n\n" + next_block["full"]
            else:
                next_block["content"] = content + "\n\n" + next_block["content"]
            i += 1  # skip to the next block (which now includes the header)
        else:
            merged.append(block)
            i += 1

    return merged


def _split_table_rowwise(table: dict, breadcrumb_prefix: str, max_chars: int) -> list[str]:
    """Split an oversized table into row groups.

    Every fragment always starts with:
      1. breadcrumb_prefix  (السياق: ...)
      2. table["header"]    (| Col1 | Col2 | + separator row)

    This ensures the LLM can always interpret every column, even when a table
    is spread across multiple retrieval chunks.
    """
    prefix = (breadcrumb_prefix + "\n\n" if breadcrumb_prefix else "") + table["header"] + "\n"
    rows   = [r for r in table["rows"] if r.strip()]

    if not rows:
        return [prefix.rstrip()]

    out, current, current_len = [], [], len(prefix)
    for row in rows:
        added = len(row) + 1  # +1 for the newline
        if current and current_len + added > max_chars:
            out.append(prefix + "\n".join(current))
            current, current_len = [row], len(prefix) + added
        else:
            current.append(row)
            current_len += added
    if current:
        out.append(prefix + "\n".join(current))

    return out


# ── Chunker ───────────────────────────────────────────────────────────────────

def chunk_markdown(md_text: str, source_name: str) -> list[dict]:
    """
    Split a Markdown document into retrievable chunks.

    Flow:
      MarkdownHeaderTextSplitter (strip_headers=False)
        → sections with physical headers in text + metadata
        → for each section: detect prose/table blocks
          → table fits → one chunk (breadcrumb + full table incl. header row)
          → table too big → row-wise split, header re-injected per fragment
          → prose fits → one chunk (breadcrumb + text)
          → prose too big → RecursiveCharacterTextSplitter sub-chunks
    """
    header_splitter = MarkdownHeaderTextSplitter(
        headers_to_split_on=[
            ("#",   "chapter"),
            ("##",  "section"),
            ("###", "subsection"),
        ],
        strip_headers=False,   # headers are physically in the text → better vector recall
    )
    sections = header_splitter.split_text(md_text)

    prose_splitter = RecursiveCharacterTextSplitter(
        chunk_size=CHUNK_SIZE,
        chunk_overlap=CHUNK_OVERLAP,
        separators=["\n\n", "\n", "؟", "،", ".", " ", ""],
    )

    chunks: list[dict] = []

    for doc in sections:
        chapter    = doc.metadata.get("chapter",    "")
        section    = doc.metadata.get("section",    "")
        subsection = doc.metadata.get("subsection", "")
        crumbs     = [p for p in [chapter, section, subsection] if p]
        crumb_text = " ".join(crumbs)

        # Extract level / term from the breadcrumb so every chunk under that
        # subsection inherits a consistent label, even if the chunk body
        # itself never repeats the level/term name (the typical case for
        # row-wise table fragments where rows lack the heading).
        level_num    = _extract_level_number(crumb_text)
        section_term = _extract_semester(crumb_text)
        # Article number from the subsection header (e.g. "مادة (34): ..."):
        # this protects against chunk-boundary splits that would otherwise
        # cause the body-text regex to miss the number.
        section_article = _detect_article_number(crumb_text)

        # Build the breadcrumb prefix that is physically embedded in every
        # chunk text — gives both the human-readable path and a normalized
        # [تصنيف: ...] tag the LLM can rely on regardless of source layout.
        def _build_prefix(local_level: str, local_term: str) -> str:
            parts = []
            if crumbs:
                parts.append("السياق: " + " > ".join(crumbs))
            tag_bits = []
            if local_level:
                tag_bits.append(f"المستوى {local_level}")
            if local_term:
                tag_bits.append(f"الفصل: {local_term}")
            if tag_bits:
                parts.append("تصنيف: " + " — ".join(tag_bits))
            return ("\n".join(parts) + "\n\n") if parts else ""

        prog_name = _extract_program_name(crumb_text)

        base_meta = {
            "source":        source_name,
            "chapter":       chapter,
            "section":       section,
            "subsection":    subsection,
            "chapter_title": chapter,
            "breadcrumb":    " > ".join(crumbs),
            "level_number":  level_num,
            "semester":      section_term,
            "program_name":  prog_name,
        }

        for block in _merge_header_blocks(_split_into_blocks(doc.page_content)):
            if block["type"] == "table":
                full_level = level_num or _extract_level_number(block["full"])
                full_term  = section_term or _extract_semester(block["full"])
                prefix     = _build_prefix(full_level, full_term)
                full       = prefix + block["full"]

                if len(full) <= CHUNK_SIZE:
                    chunks.append({
                        "text": full,
                        "metadata": {
                            **base_meta,
                            "chunk_type":     "table",
                            "article_number": _detect_article_number(full)
                                              or section_article,
                            "level_number":   full_level,
                            "semester":       full_term,
                        },
                    })
                else:
                    # Split table — assign a group ID so retriever can pull siblings.
                    # Use a content hash (not len(chunks)) so the ID is stable
                    # across re-ingestions and chunk-order changes.
                    group_seed = f"{prog_name}|L{full_level}|S{full_term}|{block['full'][:120]}"
                    group_id = hashlib.md5(group_seed.encode("utf-8")).hexdigest()[:16]
                    split_pieces = list(_split_table_rowwise(block, prefix.rstrip(), CHUNK_SIZE))
                    for piece_idx, piece in enumerate(split_pieces):
                        piece_level = full_level or _extract_level_number(piece)
                        piece_term  = full_term  or _extract_semester(piece)
                        chunks.append({
                            "text": piece,
                            "metadata": {
                                **base_meta,
                                "chunk_type":     "table",
                                "article_number": _detect_article_number(piece)
                                                  or section_article,
                                "level_number":   piece_level,
                                "semester":       piece_term,
                                "table_group_id": group_id,
                                "table_piece_idx": piece_idx,
                                "table_piece_total": len(split_pieces),
                            },
                        })
            else:
                # Prose block
                prose_level = level_num    or _extract_level_number(block["content"])
                prose_term  = section_term or _extract_semester(block["content"])
                prefix      = _build_prefix(prose_level, prose_term)
                effective   = max(CHUNK_SIZE - len(prefix), 200)

                if len(block["content"]) <= effective:
                    text = prefix + block["content"]
                    chunks.append({
                        "text": text,
                        "metadata": {
                            **base_meta,
                            "chunk_type":     "prose",
                            "article_number": _detect_article_number(block["content"])
                                              or section_article,
                            "level_number":   prose_level,
                            "semester":       prose_term,
                        },
                    })
                else:
                    sub_splitter = RecursiveCharacterTextSplitter(
                        chunk_size=effective,
                        chunk_overlap=CHUNK_OVERLAP,
                        separators=["\n\n", "\n", "؟", "،", ".", " ", ""],
                    )
                    for sub in sub_splitter.split_text(block["content"]):
                        text = prefix + sub
                        sub_level = prose_level or _extract_level_number(sub)
                        sub_term  = prose_term  or _extract_semester(sub)
                        chunks.append({
                            "text": text,
                            "metadata": {
                                **base_meta,
                                "chunk_type":     "prose",
                                "article_number": _detect_article_number(sub)
                                                  or section_article,
                                "level_number":   sub_level,
                                "semester":       sub_term,
                            },
                        })

    # Drop trivially short chunks (likely artifacts)
    chunks = [c for c in chunks if len(c["text"].strip()) >= 40]

    # Drop non-course tables that pollute retrieval:
    # 1. ملخص توزيع الساعات — credit-hour summaries (no course codes)
    # 2. Program structure overview from اللائحة الداخلية section
    #    (describes credit categories, not actual courses)
    _NOISE = [
        re.compile(r"ملخص\s+توزيع\s+الساعات"),
        re.compile(r"متطلبات التخصص للبرامج المزدوجة"),
        re.compile(r"\|\s*م\s*\|\s*المتطلبات\s*\|\s*المقررات\s*\|"),
    ]
    before = len(chunks)
    chunks = [c for c in chunks if not any(p.search(c["text"]) for p in _NOISE)]
    if (d := before - len(chunks)):
        print(f"[INGEST] Dropped {d} noise chunks (summary/structure tables)")

    return chunks


# ── Storage ───────────────────────────────────────────────────────────────────

def ingest_markdown(md_path: str, model: SentenceTransformer | None = None) -> dict:
    path    = Path(md_path)
    content = path.read_text(encoding="utf-8")
    file_id = hashlib.md5(content.encode("utf-8")).hexdigest()

    client     = chromadb.PersistentClient(path=CHROMA_PATH)
    collection = client.get_or_create_collection(
        name=COLLECTION, metadata={"hnsw:space": "cosine"}
    )

    existing = collection.get(where={"source_hash": file_id}, limit=1)
    if existing["ids"]:
        print(f"[WARN] Already indexed ({md_path}). Skipping.")
        return {"status": "skipped", "reason": "already indexed",
                "chunks_added": 0, "collection_total": collection.count()}

    cleaned = clean_markdown(content)
    chunks  = chunk_markdown(cleaned, path.name)
    n_table = sum(1 for c in chunks if c["metadata"].get("chunk_type") == "table")
    print(f"[INGEST] {len(chunks)} chunks from {md_path}  (tables={n_table})")

    if model is None:
        model = SentenceTransformer(EMBED_MODEL)

    embeddings = model.encode(
        [c["text"] for c in chunks],
        batch_size=32,              # conservative batch size for CPU
        normalize_embeddings=True,
        show_progress_bar=True,
    )

    ids       = [f"{file_id}_{i}" for i in range(len(chunks))]
    metadatas = [
        {**chunks[i]["metadata"], "source_hash": file_id, "chunk_index": i}
        for i in range(len(chunks))
    ]

    batch = 5000
    for i in range(0, len(chunks), batch):
        collection.add(
            ids=ids[i:i + batch],
            documents=[c["text"] for c in chunks[i:i + batch]],
            embeddings=embeddings[i:i + batch].tolist(),
            metadatas=metadatas[i:i + batch],
        )

    return {"status": "ok", "chunks_added": len(chunks),
            "collection_total": collection.count()}


def ingest_all_markdown(md_dir: str = DATA_DIR) -> dict:
    md_files = sorted(Path(md_dir).glob("*.md"))
    if not md_files:
        print(f"[WARN] No .md files found in {md_dir}")
        return {"status": "ok", "chunks_added": 0,
                "files_processed": 0, "collection_total": 0}

    print(f"[INGEST] Found {len(md_files)} Markdown file(s) in {md_dir}")
    model = SentenceTransformer(EMBED_MODEL)

    total_chunks     = 0
    collection_total = 0
    for md_file in md_files:
        result = ingest_markdown(str(md_file), model=model)
        total_chunks    += result.get("chunks_added", 0)
        collection_total = result.get("collection_total", collection_total)

    return {
        "status":           "ok",
        "chunks_added":     total_chunks,
        "files_processed":  len(md_files),
        "collection_total": collection_total,
    }


if __name__ == "__main__":
    print("Table-aware Markdown ingestion starting...")
    result = ingest_all_markdown()
    print(f"Done. Total chunks: {result['chunks_added']}")
