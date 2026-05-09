# Arabic Retrieval-Augmented Generation (RAG) Chatbot

## Executive Summary 

This project implements a production-ready Retrieval-Augmented Generation (RAG) system designed to answer student inquiries about academic regulations and course information at the Faculty of Science, Ain Shams University. The system processes a comprehensive student guide and provides accurate, context-aware responses in both Arabic and English, with full support for follow-up questions through conversation memory.

The system is built as a local deployment with a CPU-optimized retriever and GPU-accelerated local LLM inference, making it suitable for deployment in resource-constrained academic environments without requiring cloud services or external dependencies.


---

## Project Overview

### Purpose

This system addresses the challenge of providing timely, accurate academic guidance to students by automating the retrieval of relevant information from institutional documents. Rather than requiring manual document searches, students can ask natural language questions about:

- Admission and registration requirements
- Course offerings and prerequisites  
- Academic regulations and policies
- Degree completion requirements
- Grading systems and minimum standards
- Academic advising guidelines
- Student services and policies

The system maintains conversation history to handle follow-up questions naturally (e.g., "Why is this a requirement?"), enhancing the interactive experience.


### Problem Statement

**Challenge:** Students often struggle to find specific information in lengthy, unstructured institutional documents (guides, handbooks, regulations). Manual searches are time-consuming and error-prone.

**Solution:** This RAG system combines:
1. **Dense vector retrieval** (semantic understanding) for context-aware matching
2. **Sparse keyword retrieval** (BM25) for exact term matching
3. **Hybrid ranking** (Reciprocal Rank Fusion) to balance precision and recall
4. **Cross-encoder reranking** (Qwen3-Reranker) to refine top-k candidates
5. **Local LLM** (Ollama/Gemma3) to generate natural language responses
6. **Conversation memory** to handle multi-turn dialogues

This architecture ensures high-quality, factual responses grounded entirely in the institution's official documents.

---

## Technology Stack

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| **Web Framework** | FastAPI 0.111.0 | Async HTTP server, auto-generated API docs, type-safe request/response handling |
| **Embeddings** | Sentence Transformers `paraphrase-multilingual-mpnet-base-v2` | Native multilingual support (50+ languages including Arabic), pre-trained on 215M sentence pairs |
| **Vector Database** | ChromaDB 0.5.3 | Persistent local storage, no external DB server required, efficient similarity search |
| **Language Model** | Ollama + Gemma3 | Local inference, GPU-accelerated (CUDA 12.1), ~7B parameters, free and open-source |
| **Sparse Retrieval** | BM25 (rank-bm25) | Classical IR ranking, handles exact keyword matching, essential for structured academic tables |
| **Reranking** | Qwen3-Reranker-0.6B (HuggingFace API) | Cross-encoder precision ranking, ~20–30% improvement in relevance vs. bi-encoders alone |
| **Text Splitting** | LangChain TextSplitters | Table-aware chunking, header-aware splitting, custom Arabic normalization |
| **Language Detection** | langdetect 1.0.9 | Automatic query language routing (Arabic/English) |
| **Server** | Uvicorn 0.29.0 | ASGI server, handles streaming responses for long LLM inference |
| **Data Format** | Markdown | Structured, human-readable, preserves hierarchical organization and tables |

### Dependencies Overview

- **Core**: FastAPI, Uvicorn, Pydantic (2.7.1)
- **ML/NLP**: Sentence Transformers, Transformers (4.41.2), Torch (2.3.1 + CUDA 12.1)
- **Retrieval**: ChromaDB, rank-bm25, LangChain Text Splitters
- **HTTP**: httpx (0.27.0) — streaming Ollama responses and HuggingFace API calls
- **Data Processing**: NumPy (1.26.4), Pandas (2.2.2), Scikit-learn (1.4.2)
- **Utilities**: python-dotenv, joblib, langdetect

---

## Project Structure

```
rag_system/
├── main.py                           # FastAPI server (v2.1.0 — CPU stability + table-context fixes)
├── retriever.py                      # Hybrid RRF retriever (CPU-only embeddings, BM25 fusion)
├── reranker.py                       # Qwen3-Reranker-0.6B integration (HuggingFace API)
├── memory.py                         # Conversation store (TTL eviction, LRU session cap)
├── ingest_markdown.py                # Table-aware Markdown ingestion + chunking
├── evaluate.py                       # RAG evaluation (Faithfulness, Relevancy, Completeness)
├── evaluation_dataset.py             # 40+ test question/answer pairs
├── test_chat.py                      # Integration tests (streaming, tables, retrieval)
├── requirements.txt                  # Python dependencies
├── setup.sh                          # One-time setup automation (venv, Ollama, indexing)
├── .env                              # Configuration (model names, API tokens)
├── index.html                        # Simple UI for browser-based testing
├── .claude/                          # Claude AI settings
├── data/
│   ├── markdown/
│   │   └── guide.md                  # 2017–2018 Faculty of Science Student Guide
│   └── pdfs/                         # (Legacy) PDF upload directory
├── tests/
│   ├── __init__.py
│   └── test_arabic_tokenizer.py      # Tests for Arabic normalization + tokenization
└── vectorstore/
    ├── chroma.sqlite3                # ChromaDB database (persistent)
    └── bm25_cache.pkl                # BM25 index cache (joblib-serialized)
```

### Core Modules

#### 1. **main.py** — FastAPI Server (v2.1.0)
- **Lifespan handler**: Warms up embedder and Ollama model at startup
- **Chat endpoint** (`POST /chat`): Streams responses with keep-alive heartbeats for long CPU inference
- **Retrieve endpoint** (`POST /retrieve`): Returns raw ranked chunks with metadata
- **Ingest endpoint** (`POST /ingest`): Accepts file uploads, re-indexes vectorstore
- **Language detection**: Routes queries to Arabic or English system prompts
- **Session management**: Generates unique session IDs, persists conversation history
- **Streaming architecture**: Async task queue + generator loop with zero-width space keep-alive

**Key Features:**
- No request timeouts (`httpx.Timeout(None)`) — CPU inference can exceed 200 seconds
- 20-second keep-alive heartbeat prevents proxy/browser connection closure
- System prompts include detailed table-handling rules to prevent hallucination on multi-row academic tables
- Context capping at 7,000 characters keeps responses within Gemma3's 8,192-token context window

#### 2. **retriever.py** — Hybrid RRF Retriever
**Architecture:** Two-stage retrieval with Reciprocal Rank Fusion

1. **Vector Search (Semantic):**
   - Uses CPU-only embeddings (`paraphrase-multilingual-mpnet-base-v2`)
   - Retrieves top-15 candidates by cosine similarity
   - GPU reserved exclusively for LLM inference (no embedding overhead on GPU)

2. **BM25 Search (Keyword-Based):**
   - Custom Arabic tokenizer: diacritics removed, alef variants normalized, smart prefix stripping
   - High-value academic terms (`المستوى`, `المقرر`, `الفصل`, etc.) preserve `ال` prefix
   - BM25 score threshold (< 0.1 → skipped) prevents noise from ubiquitous terms
   - Extracted from all chunks and persisted via joblib

3. **Structural Query Detection:**
   - Queries containing academic structure terms (level, department, course, semester) receive 2× vector weight + 0.5× BM25 weight
   - Suppresses false positives from common row terms

4. **RRF Fusion:**
   - Combined ranking via Reciprocal Rank Fusion (equal contribution from vector + BM25 stages)
   - fetch_k = top_k × 4 — wide candidate pool to handle fragmented multi-row tables
   - Top-k hard-capped at 8 (raised from 5) to accommodate full academic tables without OOM risk

**Metadata Attached per Chunk:**
- `chunk_type`: prose, table, table_fragment
- `breadcrumb`: hierarchical path (e.g., "Level 4 — Term 2")
- `level_number`: extracted via regex from Arabic ordinals / digits
- `semester`: normalized term label
- `article_number`: extracted from "مادة رقم X" patterns

#### 3. **reranker.py** — Qwen3-Reranker-0.6B Integration
**Role:** Second-stage precision ranking

- **Input:** Top 15 candidates from hybrid search
- **Process:** Cross-encoder scoring (query + document together) — ~20-30% more accurate than bi-encoder
- **Output:** Top 5 re-ranked candidates to LLM
- **Integration:** HuggingFace Inference API with rate-limited concurrency (4 requests/s)
- **Graceful degradation:** If `HF_API_TOKEN` is absent, transparently returns RRF order

**Prompt Format:**
```
<|im_start|>system
Judge whether the Document meets the requirements based on the Query...
<|im_end|>
<|im_start|>user
<Instruct>: [domain-specific instruction in Arabic/English]
<Query>: {user_query}
<Document>: {candidate_chunk}
<|im_end|>
<|im_start|>assistant
<think>
[Model reasoning]
</think>
```
Uses log-probabilities of "yes" token for continuous ranking score.

#### 4. **memory.py** — Conversation Memory
**Thread-safe session store with TTL and LRU eviction**

- **Data structure:** OrderedDict of deques (preserves insertion order, efficient deque for fixed-size history)
- **Max turns per session:** 6 (default) — stores last ~12 messages
- **Max sessions:** 200 (LRU eviction when exceeded)
- **TTL:** 3,600 seconds (1 hour) — auto-remove expired sessions
- **Bug #36 fix:** `get_history()` does NOT create new sessions on unknown IDs (prevents silently refreshing TTL on typos)
- **Thread-safety:** All mutations guarded by threading.Lock()

Used for multi-turn support: "Why?" follow-ups can reference prior context.

#### 5. **ingest_markdown.py** — Table-Aware Markdown Ingestion
**Fixes "context fragmentation" failure mode where table rows are split and lose column context**

**Features:**
1. **Header-embedding:** Headers remain physically in every chunk (not just metadata)
2. **Breadcrumb injection:** Every chunk prefixed with "السياق: H1 > H2 > H3" so LLM knows which section
3. **Table-aware chunking:**
   - Markdown tables detected via regex
   - If table fits CHUNK_SIZE (1,400 chars) → kept whole
   - If table > CHUNK_SIZE → split row-wise with header re-prepended to every fragment
   - Prevents orphaned rows whose columns are unlabeled
4. **Prose chunking:** RecursiveCharacterTextSplitter with Arabic separators (،، ۔ ؛)
5. **Metadata extraction:**
   - `level_number`: extracted from "المستوى الرابع" / "Level 4" patterns
   - `semester`: extracted from "الفصل الأول" / "Term 1" patterns
   - `article_number`: extracted from "مادة رقم 34" patterns
   - `chunk_type`: prose / table / table_fragment

**Integration with Retriever:**
- Structural metadata enables weighted retrieval (level/department queries prefer semantic ranking)
- Breadcrumbs and headers allow LLM to reconstruct multi-row tables correctly

#### 6. **evaluate.py** — RAG Evaluation Framework
**No external dependencies (no RAGAS); uses local Gemma3 as judge**

**Metrics:**
- **Faithfulness:** Does the LLM response match facts in the retrieved context?
- **Relevancy:** Is the context relevant to the question?
- **Completeness:** Does the response cover all aspects of the question?

**Test Set:** 40+ gold question/answer pairs in `evaluation_dataset.py`

**Execution:**
```bash
# Terminal 1: Start server
uvicorn main:app --port 8000

# Terminal 2: Start Ollama
ollama serve

# Terminal 3: Run evaluation
python evaluate.py
```

Output: CSV with per-question scores, median/mean metrics, detailed feedback.

---

## Installation & Setup

### Prerequisites

- **Python 3.10+**
- **Ollama** (https://ollama.com/download)  
  - Required for local Gemma3 model (≈4 GB VRAM)
- **CUDA 12.1** (optional but recommended)
  - For Torch GPU acceleration
  - If absent, Torch defaults to CPU (slower, but works)
- **Hardware:** 
  - CPU: Modern multi-core (Intel Core i7 or equivalent)
  - RAM: 8 GB minimum, 16 GB recommended
  - GPU: 4 GB VRAM for Ollama (RTX 3050 or better; optional)
  - Disk: 5 GB free space (models + vectorstore)

### Automated Setup (Recommended)

```bash
# Clone/download the project, then:
cd rag_system

# Make setup.sh executable (if needed)
chmod +x setup.sh

# Run setup (creates venv, installs dependencies, indexes data)
bash setup.sh
```

The script will:
1. Create Python virtual environment (`.venv`)
2. Install all dependencies from `requirements.txt`
3. Check for Ollama installation
4. Verify Ollama is running (starts if needed)
5. Pull Gemma3 model
6. Auto-index markdown data into ChromaDB
7. Start FastAPI server on `http://localhost:8000`

### Manual Setup (Alternative)

```bash
# 1. Create virtual environment
python -m venv .venv

# 2. Activate (Linux/macOS)
source .venv/bin/activate
# Or Windows:
.venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Start Ollama (in a separate terminal)
ollama serve

# 5. Pull Gemma3 (run once)
ollama pull gemma3

# 6. Configure environment
cp .env.example .env          # if provided, or edit .env with your settings

# 7. Index markdown data
python -c "from ingest_markdown import ingest_all_markdown; ingest_all_markdown('data/markdown')"

# 8. Start the server
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Environment Configuration (`.env`)

```env
# LLM model and endpoint
OLLAMA_MODEL=gemma3
OLLAMA_URL=http://127.0.0.1:11434/api/chat

# Retrieval parameters
TOP_K=8                           # Max chunks returned per query

# Conversation memory
MAX_TURNS=6                       # Max dialog turns stored per session

# Reranker (HuggingFace Inference API)
HF_API_TOKEN=hf_xxxxxxxxxxxxxxxx  # Get from https://huggingface.co/settings/tokens
RERANKER_MODEL=Qwen/Qwen3-Reranker-0.6B
RERANKER_CONCURRENCY=4
```

---

## API Reference

All endpoints return JSON responses with appropriate HTTP status codes. Streaming responses use `text/event-stream` media type.

### 1. Chat Endpoint — `/chat`

**Request:**
```bash
POST /chat
Content-Type: application/json

{
  "question": "ما هي متطلبات التسجيل؟",
  "session_id": "optional-existing-session-id"
}
```

**Response (Streaming):**
```
HTTP/1.1 200 OK
Content-Type: text/event-stream
X-Session-ID: 550e8400-e29b-41d4-a716-446655440000
X-Response-Time: 8.234
X-Sources: [1, 2, 3]

[Stream of text chunks...]
```

**Response Headers:**
- `X-Session-ID`: UUID for session management (use for follow-ups)
- `X-Response-Time`: Seconds to prepare context (excludes LLM generation time)
- `X-Sources`: JSON array of source chunk indices

**Example — Arabic Question:**
```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "question": "ما هي مقررات المستوى الرابع في قسم الإحصاء؟"
  }' \
  -N | grep -v "^:keep-alive"
```

**Example — Follow-up Question:**
```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "question": "لماذا هذه المقررات إجبارية؟",
    "session_id": "550e8400-e29b-41d4-a716-446655440000"
  }' \
  -N
```

### 2. Retrieve Endpoint — `/retrieve`

Returns raw retrieved and ranked chunks for debugging/inspection.

**Request:**
```bash
POST /retrieve
Content-Type: application/json

{
  "question": "ما الحد الأدنى للمعدل التراكمي؟",
  "top_k": 5
}
```

**Response:**
```json
{
  "chunks": [
    {
      "text": "يتخرج الطالب عندما يحصل على معدل تراكمي لا يقل عن 2.00...",
      "rrf_score": 0.95,
      "metadata": {
        "chunk_type": "prose",
        "level_number": "4",
        "semester": "الأول",
        "breadcrumb": "المستوى الرابع > الفصل الأول > متطلبات التخرج",
        "article_number": ""
      }
    },
    ...
  ]
}
```

**Fields:**
- `text`: Chunk content (may include table rows + header row if table)
- `rrf_score`: Combined RRF ranking score (0–1)
- `metadata`: Breadcrumb, level, semester, chunk type, etc.

### 3. Ingest Endpoint — `/ingest`

Uploads and indexes new Markdown or PDF files.

**Request:**
```bash
POST /ingest
Content-Type: multipart/form-data

# Upload a Markdown file
curl -X POST http://localhost:8000/ingest \
  -F "file=@data/markdown/new_guide.md"

# Upload a PDF (legacy; converted to Markdown internally)
curl -X POST http://localhost:8000/ingest \
  -F "file=@data/pdfs/document.pdf"
```

**Response:**
```json
{
  "status": "success",
  "chunks_added": 147,
  "message": "Successfully ingested new_guide.md (147 chunks)"
}
```

### 4. Health Endpoint — `/health`

**Request:**
```bash
GET /health
```

**Response:**
```json
{
  "status": "ok",
  "vectorstore_chunks": 1250,
  "ollama_model": "gemma3",
  "timestamp": "2024-04-30T12:34:56Z"
}
```

---

## Running the System

### Development Mode

```bash
# Terminal 1: Ollama server
ollama serve

# Terminal 2: FastAPI server (with auto-reload)
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Then navigate to:
- **API Interactive Docs:** http://localhost:8000/docs
- **Alternative Docs:** http://localhost:8000/redoc
- **Web UI:** http://localhost:8000/index.html

### Production Deployment

```bash
# Use Gunicorn + Uvicorn workers for production:
gunicorn main:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000 \
  --timeout 600 \
  --access-logfile -
```

### Testing

**Integration Tests:**
```bash
# Test streaming chat
python test_chat.py

# Run specific test function
python -m pytest tests/test_arabic_tokenizer.py -v
```

**Evaluation:**
```bash
# Terminal 1: Start server + Ollama
uvicorn main:app --port 8000 &
ollama serve &

# Terminal 2: Run evaluation
python evaluate.py
```

---

## Key Features

### 1. **Multilingual Support**
- **Arabic & English:** Automatic language detection routes queries to appropriate system prompt
- **Multilingual embeddings:** `paraphrase-multilingual-mpnet-base-v2` handles 50+ languages
- **Arabic normalization:** Custom tokenizer handles diacritics, alef variants, prefix stripping

### 2. **Conversation Memory**
- **Multi-turn support:** Sessions preserve last 6 dialog turns
- **TTL-based eviction:** Sessions automatically expire after 1 hour
- **LRU session cap:** Maximum 200 concurrent sessions

### 3. **Table-Aware Processing**
- **Breadcrumb injection:** Every chunk includes hierarchical context
- **Table reconstruction:** Multi-row tables correctly reassembled even if fragmented
- **Column binding:** LLM instructed to bind cells to column headers
- **Metadata tagging:** Level, semester, article number extracted and attached

### 4. **Hybrid Retrieval**
- **Two-stage ranking:** Vector search (semantic) + BM25 (exact keywords)
- **RRF fusion:** Balanced contribution from both retrieval stages
- **Weighted ranking:** Structural queries (level/department) prefer semantic signals
- **Reranking:** Optional Qwen3-Reranker cross-encoder for top-5 refinement

### 5. **CPU-Optimized Inference**
- **Embeddings on CPU:** No GPU overhead for vector search
- **GPU reserved for LLM:** All Ollama inference on GPU (if available)
- **No timeouts:** Supports CPU inference up to 200+ seconds
- **Keep-alive heartbeat:** Prevents connection closure during long inference

### 6. **Academic-Focused System Prompts**
- **Formal tone:** Responses sound like certified academic advisors
- **Table handling rules:** Explicit instructions to prevent hallucination on multi-row tables
- **Citation format:** Every answer includes source attribution (مادة رقم X, breadcrumb)
- **Coverage rules:** Level/term/department specifications handled correctly

### 7. **Quality Evaluation**
- **Faithfulness scoring:** Does LLM response match retrieved context?
- **Relevancy scoring:** Is context relevant to question?
- **Completeness scoring:** Does answer cover all question aspects?
- **40+ test cases:** Comprehensive evaluation dataset

---

## Known Limitations & Design Decisions

1. **Top-K Hard Cap:** Maximum 8 chunks retrieved per query (raised from 5 to accommodate full tables). Further increases risk CPU OOM.

2. **CPU Embedding Only:** Embeddings run on CPU to maximize GPU availability for LLM. Trade-off: slower but more flexible resource usage.

3. **No Real-Time Updates:** Vectorstore is static after initial ingestion. Adding new documents requires re-indexing via `/ingest` endpoint.

4. **Reranker Optional:** HuggingFace API token required for Qwen3 reranking. System gracefully falls back to RRF order if token absent.

5. **Session TTL:** 1-hour session expiration may be short for long-running user interactions. Configurable in `.env` if needed.

6. **Markdown-Only Ingestion:** Current pipeline optimized for Markdown; PDF support is legacy and less robust.

---

## Important Notes for Reviewers

### Architectural Rationale

**Why Hybrid Retrieval?**
- Vector search alone misses exact keyword matches (e.g., "مادة رقم 34")
- BM25 alone fails on semantic variations (e.g., "المتطلبات" vs. "شروط")
- RRF fusion balances both strengths

**Why Local LLM?**
- Privacy: No data leaves the institution
- Cost: No API fees
- Control: Full inference pipeline under user's authority
- Latency: Predictable, no external dependency

**Why Cross-Encoder Reranking?**
- Bi-encoders compare query and document separately (approximate)
- Cross-encoders see both together (precise)
- Two-stage design: fast recall → precise ranking

### Evaluation Metrics

The system is evaluated on three metrics:
1. **Faithfulness (0–1):** LLM response must be grounded in retrieved context
2. **Relevancy (0–1):** Retrieved context must match query intent
3. **Completeness (0–1):** Response must address all aspects of question

Acceptable threshold: ≥ 0.8 on all three metrics.

### Performance Characteristics

- **Latency per query:** 8–15 seconds (prep) + 5–60 seconds (LLM inference on CPU)
- **Throughput:** ~1–2 queries/second (single GPU Ollama instance)
- **Vectorstore size:** 1,200+ chunks (~5 MB ChromaDB file)
- **BM25 index:** ~500 KB (joblib-cached)

### Future Enhancements

1. **Batch indexing:** Parallel chunk processing for faster ingestion
2. **Semantic caching:** Cache embeddings for frequent queries
3. **Multi-document chat:** Support simultaneous queries across multiple guides
4. **Web UI:** Interactive chat interface (currently minimal HTML/JS)
5. **Fine-tuning:** Custom embedding model fine-tuned on institutional domain
6. **API versioning:** Backward-compatible endpoint evolution

---

## References & Resources

- **Ollama:** https://ollama.com/library/gemma3
- **ChromaDB:** https://www.trychroma.com/
- **Sentence Transformers:** https://www.sbert.net/
- **FastAPI:** https://fastapi.tiangolo.com/
- **Qwen3-Reranker:** https://huggingface.co/Qwen/Qwen3-Reranker-0.6B
- **LangChain:** https://python.langchain.com/

---

## Citation

If you use this system in academic work, please cite:

```bibtex
@thesis{rag_chatbot_2024,
  title={Arabic Retrieval-Augmented Generation Chatbot for Academic Guidance},
  author={[Your Name]},
  school={Faculty of Science, Ain Shams University},
  year={2024},
  note={Graduation Project}
}
```

---

## License

This project is proprietary and intended for educational purposes at Ain Shams University.
