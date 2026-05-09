"""
retriever.py — Hybrid retriever with weighted RRF fusion (CPU-only production)
==============================================================================
  - CPU-only embedding (GPU reserved for Ollama LLM)
  - Arabic-aware BM25 tokenizer (diacritics, prefix stripping, alef normalization)
  - BM25 index persisted via joblib — skips rebuild if collection unchanged
  - top_k hard-capped at 8 (raised from 5) to give LLM enough rows to
    reconstruct multi-row academic tables without OOM risk on CPU
  - fetch_k = top_k × 4 — wide candidate pool for fragmented tables
  - Weighted RRF: structural queries (level/dept/course) get 2× vector weight
    and 0.5× BM25 weight to suppress noise from ubiquitous terms like "ساعة"
  - BM25 score threshold: skip BM25 results when max raw score < 0.1
    (query has no meaningful keyword match — prevents random noise from
     contaminating the fusion ranking)
  - reset_retriever() holds _init_lock to prevent concurrent partial-reset reads
"""

import re
import time
import joblib
import threading
from pathlib import Path

import numpy as np
import chromadb
from rank_bm25 import BM25Okapi
from sentence_transformers import SentenceTransformer

from ingest_markdown import _extract_level_number, _extract_semester, _detect_query_program

# ── Program boost matching ────────────────────────────────────────────────────
# Explicit shared-program allowlist: when user asks about program A,
# it's correct to also boost program B's chunks (L1-L2 shared data).
_SHARED_PROGRAM_BOOST: set[tuple[str, str]] = {
    ("الكيمياء التطبيقية", "الكيمياء"),   # L1-L2 shared with plain الكيمياء
    ("الجيوفيزياء", "الجيولوجيا"),         # L1 shared with الجيولوجيا programs
}


def _boost_matches(query_prog: str, chunk_prog: str) -> bool:
    """Return True when chunk_prog deserves a boost for query_prog.

    Rules (applied in order):
    1. Exact match.
    2. ال-prefix variant (النبات == نبات).
       EXCEPTION: compound names with '+' are excluded from this rule so that
       'النبات' does NOT match 'نبات+كيمياء' (dual-track variant).
    3. Explicit shared-program allowlist only.
    """
    if not query_prog or not chunk_prog:
        return False

    # Rule 1: exact match
    if query_prog == chunk_prog:
        return True

    # Rule 2: ال-prefix variant — but ONLY for simple (non-compound) names
    def strip_al(s: str) -> str:
        return s[2:] if s.startswith("ال") else s

    if "+" not in query_prog and "+" not in chunk_prog:
        if strip_al(query_prog) == strip_al(chunk_prog):
            return True

    # Rule 3: explicit shared-program allowlist
    if (query_prog, chunk_prog) in _SHARED_PROGRAM_BOOST:
        return True

    return False


# ── Config ────────────────────────────────────────────────────────────────────
BM25_CACHE_PATH = Path("vectorstore/bm25_cache.pkl")

# ── Arabic normalization ──────────────────────────────────────────────────────
# Only strip actual diacritical marks — NOT base Arabic letters.
# U+064B-U+065F = Arabic diacritics (fathatan through hamza below)
# U+0670       = Superscript alef
# U+0640       = Tatweel / kashida
# BUG FIX: The old pattern r"[ؗ-ًؚ-ْٰـ]" used the range U+0617-U+064B
# which covered ALL base Arabic letters (ا through ي), stripping them
# entirely and producing empty tokens for every Arabic word.
_DIACRITICS_AND_TATWEEL = re.compile(r"[\u064B-\u065F\u0670\u0640]")

_SAFE_MULTI_PREFIXES = ('وال', 'فال', 'بال', 'كال', 'لل')
_AL_PREFIX           = 'ال'
_SINGLE_PREFIXES     = ('ل',)   # ل only — و removed (too often a root letter)

_PUNCT_STRIP = ".ءء،؛;:!؟?()[]{}'«»…—–-/\\"

# High-value academic terms: preserve their ال prefix to keep semantic identity.
# NOTE: These must be in post-normalization form (ة→ه, ى→ي) because
# normalize_arabic() runs BEFORE the no-strip check in arabic_tokenize().
_ACADEMIC_NO_STRIP = {
    "المستوي", "المستويات",
    "المقرر",  "المقررات",
    "الفصل",   "الفصول",
    "القسم",   "الاقسام",
    "الكليه",  "الكليات",
    "الشعبه",  "الشعب",
    "البرنامج","البرامج",
}

# ── Structural-query detection ────────────────────────────────────────────────
# Queries that ask about academic structure benefit from vector search (which
# understands table context) over BM25 (which over-fires on common row terms).
_STRUCTURAL_STEMS = {
    # post-normalization stems (ال stripped, ة→ه, ى→ي)
    "مستوي", "مستويات",
    "قسم",   "اقسام",
    "شعبه",  "شعب",
    "فصل",   "فصول",
    "مقرر",  "مقررات",
    "برنامج","برامج",
    "كليه",  "كليات",
    "جدول",  "جداول",
    # English / mixed
    "level", "department", "semester", "course", "track", "faculty", "table",
}


def normalize_arabic(text: str) -> str:
    text = _DIACRITICS_AND_TATWEEL.sub('', text)
    text = (text
            .replace('أ', 'ا')
            .replace('إ', 'ا')
            .replace('آ', 'ا')
            .replace('ة', 'ه')
            .replace('ى', 'ي'))
    return text


def arabic_tokenize(text: str) -> list[str]:
    text = normalize_arabic(text)
    text = re.sub(r"[|/\\—–\-]", " ", text)
    raw_tokens = text.split()
    result = []
    for tok in raw_tokens:
        tok = tok.strip(_PUNCT_STRIP)
        if not tok:
            continue

        is_arabic = any('؀' <= c <= 'ۿ' for c in tok)
        if not is_arabic:
            result.append(tok.lower())
            continue

        if tok in _ACADEMIC_NO_STRIP:
            result.append(tok)
            continue

        stripped = tok

        for pfx in _SAFE_MULTI_PREFIXES:
            if stripped.startswith(pfx) and len(stripped) - len(pfx) >= 3:
                stripped = stripped[len(pfx):]
                break
        else:
            if stripped.startswith(_AL_PREFIX) and len(stripped) - len(_AL_PREFIX) >= 3:
                stripped = stripped[len(_AL_PREFIX):]
            else:
                for pfx in _SINGLE_PREFIXES:
                    if stripped.startswith(pfx) and len(stripped) - len(pfx) >= 3:
                        stripped = stripped[len(pfx):]
                        break

        result.append(stripped)

    return result


def _is_structural_query(query: str) -> bool:
    """Return True when the query asks about academic structure.

    Normalizes the query through the same pipeline used for BM25 tokens,
    then checks for overlap with _STRUCTURAL_STEMS.  A match signals that
    the user is hunting for table/level/department data — vector search is
    more reliable than BM25 for that, so we up-weight it in the RRF fusion.
    """
    tokens = set(arabic_tokenize(query))
    # Also check raw lower-cased words for English structural terms
    raw = set(query.lower().split())
    return bool((tokens | raw) & _STRUCTURAL_STEMS)


def _build_metadata_filter(query: str) -> dict | None:
    """Build a ChromaDB `where` filter from the query's level/semester mentions.

    When a user asks about "المستوى الأول الفصل الثاني", this returns a filter
    that restricts vector search to chunks whose `level_number` = "1" AND
    `semester` = "الثاني".  This prevents Level-2/3/4 chunks (which may be
    semantically closer due to course-code overlap) from outranking the
    actually-requested Level-1 chunks.

    Returns None if no level/semester can be extracted (general query).
    """
    level = _extract_level_number(query)
    semester = _extract_semester(query)

    if not level and not semester:
        return None

    conditions = []
    if level:
        conditions.append({"level_number": level})
    if semester:
        conditions.append({"semester": semester})

    if len(conditions) == 1:
        return conditions[0]
    return {"$and": conditions}


def _select_device() -> str:
    return "cpu"   # GPU reserved for Ollama/gemma3


# ── Retriever ─────────────────────────────────────────────────────────────────

class Retriever:
    def __init__(self):
        device = _select_device()
        print(f"[INIT] Embedding device: {device}")
        self.embed_model = SentenceTransformer(
            "paraphrase-multilingual-mpnet-base-v2", device=device
        )
        self.client     = chromadb.PersistentClient(path="vectorstore")
        self.collection = self.client.get_or_create_collection(name="rag_docs")
        self._prepare_bm25()

    # ── BM25 persistence ──────────────────────────────────────────────────────

    def _collection_fingerprint(self) -> str:
        count = self.collection.count()
        return "empty" if count == 0 else str(count)

    def _prepare_bm25(self):
        fingerprint = self._collection_fingerprint()

        if BM25_CACHE_PATH.exists():
            try:
                cache = joblib.load(BM25_CACHE_PATH)
                if cache.get("fingerprint") == fingerprint:
                    self.bm25      = cache["bm25"]
                    self.documents = cache["documents"]
                    self.metadatas = cache["metadatas"]
                    print(f"[CACHE] BM25 loaded ({len(self.documents)} docs)")
                    return
            except Exception as e:
                print(f"[WARN] BM25 cache invalid: {e}")

        print("[BUILD] Building BM25 index...")
        all_docs       = self.collection.get()
        self.documents = all_docs["documents"]
        self.metadatas = all_docs["metadatas"]

        if self.documents:
            tokenized  = [arabic_tokenize(doc) for doc in self.documents]
            self.bm25  = BM25Okapi(tokenized)
        else:
            self.bm25  = None

        try:
            joblib.dump({
                "fingerprint": fingerprint,
                "bm25":        self.bm25,
                "documents":   self.documents,
                "metadatas":   self.metadatas,
            }, BM25_CACHE_PATH)
            print("[CACHE] BM25 cache saved")
        except Exception as e:
            print(f"[WARN] Could not save BM25 cache: {e}")

    def invalidate_bm25_cache(self):
        BM25_CACHE_PATH.unlink(missing_ok=True)

    # ── Hybrid search ─────────────────────────────────────────────────────────

    def search(self, query: str, top_k: int = 8, rrf_k: int = 60) -> list[dict]:
        """
        Hybrid search via weighted Reciprocal Rank Fusion.

        Structural queries get top_k=12 (large tables split into 2 fragments
        compete with ~25 same-level chunks from other programs).
        General queries keep top_k=8.

        Program boosting: after RRF, chunks matching the query's program name
        get +0.03 bonus to outrank same-level competitors from other programs.
        """
        structural = _is_structural_query(query)
        hard_cap = 12 if structural else 8
        top_k = min(top_k, hard_cap)

        if not self.documents or not self.bm25:
            return []

        fetch_k = min(top_k * 4, len(self.documents))

        # Detect program name for post-RRF boosting
        query_program = _detect_query_program(query) if structural else ""
        if query_program:
            print(f"[SEARCH] Program detected: '{query_program}'")

        vector_weight = 2.0 if structural else 1.0
        bm25_weight   = 0.5 if structural else 1.0

        if structural:
            print(f"[SEARCH] Structural query detected — vector_w={vector_weight}, bm25_w={bm25_weight}")

        t1 = time.time()

        # ── 1. Vector search ──────────────────────────────────────────────────
        query_vec = self.embed_model.encode(
            [query], normalize_embeddings=True
        ).tolist()

        # Apply metadata filter for structural queries so the correct
        # level/semester chunks are guaranteed to surface.
        meta_filter = _build_metadata_filter(query) if structural else None

        try:
            vector_results = self.collection.query(
                query_embeddings=query_vec,
                n_results=fetch_k,
                include=["documents", "metadatas"],
                where=meta_filter,
            )
            # If filtered results are too few, fall back to unfiltered
            if meta_filter and len(vector_results["documents"][0]) < 2:
                vector_results = self.collection.query(
                    query_embeddings=query_vec,
                    n_results=fetch_k,
                    include=["documents", "metadatas"],
                )
                meta_filter = None  # disable BM25 filtering too
        except Exception:
            # Fallback: if the filter produces zero matches (e.g. bad level
            # extraction), retry without filtering.
            vector_results = self.collection.query(
                query_embeddings=query_vec,
                n_results=fetch_k,
                include=["documents", "metadatas"],
            )
            meta_filter = None

        if meta_filter:
            print(f"[SEARCH] Metadata filter: {meta_filter}")

        # ── 2. BM25 search ────────────────────────────────────────────────────
        tokenized_query = arabic_tokenize(query)
        bm25_scores     = self.bm25.get_scores(tokenized_query)
        max_bm25        = float(np.max(bm25_scores)) if len(bm25_scores) > 0 else 0.0

        # Noise gate: no meaningful keyword match → skip BM25 entirely
        if max_bm25 < 0.1:
            top_bm25_idx = []
            print(f"[SEARCH] BM25 noise-gated (max_score={max_bm25:.4f})")
        else:
            bm25_threshold = max_bm25 * 0.15   # only top 15%-of-max candidates
            all_bm25_idx   = np.argsort(bm25_scores)[::-1][:fetch_k]
            top_bm25_idx   = [i for i in all_bm25_idx
                               if bm25_scores[i] >= bm25_threshold]

        # Apply the same level/semester filter to BM25 results
        if meta_filter and top_bm25_idx:
            level_val = _extract_level_number(query)
            sem_val   = _extract_semester(query)
            filtered  = []
            for i in top_bm25_idx:
                m = self.metadatas[i]
                if level_val and m.get("level_number") != level_val:
                    continue
                if sem_val and m.get("semester") != sem_val:
                    continue
                filtered.append(i)
            top_bm25_idx = filtered

        # ── 3. Weighted RRF Fusion ────────────────────────────────────────────
        rrf_scores: dict[str, dict] = {}

        for rank, (doc, meta) in enumerate(zip(
            vector_results["documents"][0],
            vector_results["metadatas"][0],
        )):
            rrf_scores.setdefault(doc, {"score": 0.0, "source": meta.get("source", ""), "metadata": meta})
            rrf_scores[doc]["score"] += vector_weight / (rrf_k + rank + 1)

        for rank, idx in enumerate(top_bm25_idx):
            doc  = self.documents[idx]
            meta = self.metadatas[idx]
            rrf_scores.setdefault(doc, {"score": 0.0, "source": meta.get("source", ""), "metadata": meta})
            rrf_scores[doc]["score"] += bm25_weight / (rrf_k + rank + 1)

        # ── 4. Program-name boosting (structural queries only) ────────────────
        if query_program:
            is_compound = "+" in query_program
            # Compound (dual-track) programs need stronger boost because they
            # compete with TWO single-track programs that share keywords.
            boost_val = 0.06 if is_compound else 0.03
            boosted = 0
            for doc, info in rrf_scores.items():
                chunk_prog = info.get("metadata", {}).get("program_name", "")
                if _boost_matches(query_program, chunk_prog):
                    info["score"] += boost_val
                    boosted += 1
                elif is_compound and chunk_prog and not _boost_matches(query_program, chunk_prog):
                    # Penalize chunks from wrong programs when we know exactly
                    # which dual-track program the user wants — prevents single-
                    # track الفيزياء chunks from outranking الفيزياء+علوم الحاسب.
                    info["score"] -= 0.02
            if boosted:
                print(f"[SEARCH] Program boost: {boosted} chunks for '{query_program}' (boost={boost_val})")

        # ── 5. Sort and return top_k ──────────────────────────────────────────
        sorted_docs = sorted(
            rrf_scores.items(), key=lambda x: x[1]["score"], reverse=True
        )

        results = [
            {
                "text":      doc,
                "source":    info["source"],
                "rrf_score": round(info["score"], 4),
                "metadata":  info.get("metadata", {}),
            }
            for doc, info in sorted_docs[:top_k]
        ]

        print(
            f"[SEARCH] {round(time.time()-t1, 2)}s | "
            f"Vector={len(vector_results['documents'][0])} "
            f"BM25={len(top_bm25_idx)} structural={structural} -> Fused={len(results)}"
        )
        return results


# ── Singleton management ──────────────────────────────────────────────────────

_init_lock             = threading.Lock()
_retriever_instance: Retriever | None = None


def get_retriever() -> Retriever:
    global _retriever_instance
    if _retriever_instance is None:
        with _init_lock:
            if _retriever_instance is None:
                _retriever_instance = Retriever()
    return _retriever_instance


def reset_retriever():
    """Clear the singleton under the same lock used by get_retriever() so a
    concurrent request cannot observe a partially-reset state."""
    global _retriever_instance
    with _init_lock:
        _retriever_instance = None
