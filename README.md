# Campus AI — Ain Shams University Student Guide

> An intelligent mobile application for Faculty of Science students at Ain Shams University, featuring an Arabic-first AI chatbot powered by a local Retrieval-Augmented Generation (RAG) system.

---

## Table of Contents

- [Project Overview](#project-overview)
- [System Architecture](#system-architecture)
- [Repository Structure](#repository-structure)
- [Prerequisites & Dependencies](#prerequisites--dependencies)
- [Environment Setup & Configuration](#environment-setup--configuration)
- [Installation & Running](#installation--running)
  - [1. RAG Backend (Python)](#1-rag-backend-python)
  - [2. Flutter Mobile App](#2-flutter-mobile-app)
- [Features](#features)
- [API Reference](#api-reference)
- [Common Issues](#common-issues)

---

## Project Overview

**Campus AI** consists of two integrated systems:

| System | Technology | Purpose |
|--------|-----------|---------|
| **Flutter Mobile App** | Dart / Flutter 3.11+ | Student-facing mobile interface |
| **RAG Backend** | Python / FastAPI | AI chatbot with document retrieval |

The Flutter app provides students with a full university companion: AI chatbot, GPA calculator, doctor directory, campus map, course registration, academic warnings, and e-learning integration.

The RAG backend answers academic questions by retrieving relevant sections from the Faculty of Science student guide, using hybrid search (semantic + keyword) and a local LLM — no cloud AI dependency required.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Flutter Mobile App                      │
│  ┌──────────┐  ┌──────────┐  ┌────────┐  ┌─────────┐  │
│  │   Home   │  │ Services │  │  Map   │  │ ChatBot │  │
│  └──────────┘  └──────────┘  └────────┘  └────┬────┘  │
│                                                │         │
│  Firebase Auth ←── Users          Firestore ──┘         │
└────────────────────────────────────┬────────────────────┘
                                     │ HTTP POST /chat
                                     │ (streaming SSE)
┌────────────────────────────────────▼────────────────────┐
│                    RAG Backend (FastAPI)                  │
│                                                          │
│  User Query                                              │
│      │                                                   │
│      ▼                                                   │
│  Language Detection (Arabic / English)                   │
│      │                                                   │
│      ├──► Vector Search (SentenceTransformer)            │
│      └──► BM25 Search (Arabic tokenizer)                 │
│                   │                                      │
│              RRF Fusion                                  │
│                   │                                      │
│           Reranker (Qwen3 / HuggingFace) [optional]      │
│                   │                                      │
│           Build Prompt + Context                         │
│                   │                                      │
│           Ollama + Gemma3 (local LLM)                    │
│                   │                                      │
│           Stream tokens → Flutter                        │
└──────────────────────────────────────────────────────────┘
```

**Chat Message Full Flow:**

```
1.  Student types a question in the ChatBotScreen (Flutter)
2.  ChatCubit calls ChatRemoteService.sendMessageStreaming()
3.  HTTP POST to RAG /chat with { question, session_id }
4.  RAG detects language (Arabic / English)
5.  RAG runs Vector Search + BM25 Search
6.  RRF Fusion combines and ranks both result sets
7.  Optional: Qwen3 Reranker re-scores top candidates
8.  RAG builds system prompt with context + conversation history
9.  Ollama (Gemma3) generates response token-by-token
10. RAG streams tokens to Flutter via Server-Sent Events
11. Flutter emits ChatStreaming state — UI updates in real-time
12. When complete, message is saved to Firestore
13. ChatCubit emits ChatSuccess state
```

---

## Repository Structure

```
campus_ai/
├── src/                              # All source code
│   ├── lib/                          # Flutter Dart source
│   │   ├── main.dart                 # App entry point
│   │   ├── app.dart                  # Main navigation (PageView + BottomNav)
│   │   ├── firebase_options.dart     # Firebase configuration
│   │   ├── core/
│   │   │   ├── helper/               # Reusable UI components
│   │   │   ├── theme/                # App colors, theme, dark mode
│   │   │   └── utils/               # Routes, constants, nav bar
│   │   └── features/
│   │       ├── authentication_feature/
│   │       ├── chat_bot_feature/     # RAG chatbot integration
│   │       │   ├── data/
│   │       │   │   ├── cubit/        # ChatCubit + ChatState
│   │       │   │   ├── model/        # ChatMessage model
│   │       │   │   └── services/     # HTTP calls to RAG API
│   │       │   └── presentation/     # Chat UI screens & widgets
│   │       ├── home_feature/
│   │       ├── departments_feature/
│   │       ├── doctors_feature/
│   │       ├── gpa_feature/
│   │       ├── map_feature/
│   │       ├── service_feature/
│   │       ├── academic_warning_feature/
│   │       ├── course_registration_feature/
│   │       ├── elearn_web_view_feature/
│   │       ├── news_feature/
│   │       ├── transcript_feature/
│   │       ├── dashboard_screen/
│   │       └── ums_webview_feature/
│   ├── rag_system/                   # Python RAG backend
│   │   ├── main.py                   # FastAPI server
│   │   ├── retriever.py              # Hybrid RRF retrieval engine
│   │   ├── reranker.py               # Qwen3 cross-encoder reranking
│   │   ├── memory.py                 # Conversation memory (TTL-based)
│   │   ├── ingest_markdown.py        # Table-aware markdown ingestion
│   │   ├── requirements.txt          # Python dependencies
│   │   ├── setup.sh                  # Automated setup script
│   │   ├── data/
│   │   │   └── markdown/
│   │   │       └── guide.md          # Faculty of Science student guide
│   │   └── vectorstore/              # Auto-generated on first run
│   │       ├── chroma.sqlite3
│   │       └── bm25_cache.pkl
│   ├── android/                      # Android native configuration
│   ├── ios/                          # iOS native configuration
│   ├── web/                          # Web platform files
│   ├── assets/                       # Images and static files
│   ├── test/                         # Flutter widget tests
│   └── pubspec.yaml                  # Flutter dependencies
├── exe/                              # Pre-built executables (see below)
└── README.md
```

> **exe/ folder:** Place your compiled Android APK (`app-release.apk`) here after building with `flutter build apk --release`. This allows users to install the app without compiling from source.

---

## Prerequisites & Dependencies

### RAG Backend

| Requirement | Version | Notes |
|-------------|---------|-------|
| Python | 3.10 – 3.12 | 3.11 recommended |
| pip | Latest | |
| Ollama | Latest | [ollama.com](https://ollama.com) — must be running |
| Gemma3 model | via Ollama | ~4 GB download |
| CUDA toolkit | 12.1 (optional) | For GPU acceleration (RTX 3050+) |
| RAM | 8 GB minimum | 16 GB recommended |
| Disk | 5 GB free | Models + vectorstore |

**Python packages** (pinned in `src/rag_system/requirements.txt`):

| Package | Version | Purpose |
|---------|---------|---------|
| fastapi | 0.111.0 | HTTP API framework |
| uvicorn | 0.29.0 | ASGI server |
| sentence-transformers | 3.0.1 | Multilingual embeddings (Arabic support) |
| chromadb | 0.5.3 | Vector database |
| httpx | 0.27.0 | Async HTTP client (Ollama + HuggingFace) |
| langdetect | 1.0.9 | Language detection |
| langchain-text-splitters | 0.2.4 | Markdown-aware text chunking |
| rank-bm25 | 0.2.2 | BM25 keyword retrieval |
| numpy | 1.26.4 | Numerical computing |
| transformers | 4.41.2 | HuggingFace model support |
| torch | 2.3.1+cu121 | Deep learning (GPU) |
| pydantic | 2.7.1 | Request/response validation |

### Flutter App

| Requirement | Version | Notes |
|-------------|---------|-------|
| Flutter SDK | ^3.11.5 | [flutter.dev/install](https://flutter.dev/docs/get-started/install) |
| Dart SDK | Included | Part of Flutter |
| Android Studio | Latest | For Android builds |
| Xcode | 15+ | For iOS builds (macOS only) |
| Android SDK | API 21+ | Android 5.0 minimum |
| Firebase project | — | Auth + Firestore enabled |

**Key Flutter packages** (full list in `src/pubspec.yaml`):

| Package | Version | Purpose |
|---------|---------|---------|
| firebase_core | ^4.7.0 | Firebase initialization |
| firebase_auth | ^6.4.0 | User authentication |
| cloud_firestore | ^6.3.0 | Message persistence |
| flutter_bloc | ^9.1.1 | Cubit state management |
| flutter_riverpod | ^3.3.1 | Navigation state management |
| dio | ^5.9.2 | HTTP client |
| flutter_dotenv | ^6.0.1 | Environment variables |
| webview_flutter | ^4.13.1 | E-learning & UMS integration |
| flutter_map | ^8.3.0 | Campus map |
| flutter_markdown | ^0.7.4 | Render chatbot responses |

---

## Environment Setup & Configuration

### RAG Backend — `src/rag_system/.env`

```env
# LLM — local Ollama server
OLLAMA_MODEL=gemma3
OLLAMA_URL=http://127.0.0.1:11434/api/chat

# Retrieval
TOP_K=8

# Conversation memory
MAX_TURNS=6
MAX_SESSIONS=200
SESSION_TTL=3600

# Reranker (optional — improves accuracy by ~20-30%)
# Get a free token at: https://huggingface.co/settings/tokens
HF_API_TOKEN=hf_your_token_here
RERANKER_MODEL=Qwen/Qwen3-Reranker-0.6B
RERANKER_CONCURRENCY=4
```

### Flutter App — `src/.env`

```env
# RAG backend URL — use your machine's LAN IP, not localhost
# Windows: run `ipconfig` | Mac/Linux: run `ifconfig`
CHAT_BOT_API_KEY=http://192.168.x.x:8000

# Google Maps (for campus map feature)
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

> **Important:** The phone/emulator and the RAG server must be on the **same Wi-Fi network**. Replace `192.168.x.x` with your actual local IP.

### Firebase Setup

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** → Email/Password provider
3. Enable **Cloud Firestore** → Start in test mode
4. **Android:** Download `google-services.json` → place in `src/android/app/`
5. **iOS:** Download `GoogleService-Info.plist` → place in `src/ios/Runner/`
6. Update `src/lib/firebase_options.dart` with your project credentials (or run `flutterfire configure` from inside `src/`)

---

## Installation & Running

### 1. RAG Backend (Python)

**Step 1 — Clone the repository**

```bash
git clone https://github.com/mohamed-Ihab55/campus_ai.git
cd campus_ai/src/rag_system
```

**Step 2 — Automated setup (recommended)**

```bash
chmod +x setup.sh
bash setup.sh
```

This script creates the virtual environment, installs dependencies, starts Ollama, pulls Gemma3, indexes the student guide, and starts the server.

**— OR — Manual setup**

**Step 2a — Create a virtual environment**

```bash
python -m venv .venv

# Windows
.venv\Scripts\activate

# macOS / Linux
source .venv/bin/activate
```

**Step 2b — Install Python dependencies**

```bash
# With GPU support (CUDA 12.1 — recommended)
pip install torch==2.3.1+cu121 --extra-index-url https://download.pytorch.org/whl/cu121
pip install -r requirements.txt

# Without GPU (CPU only — slower but works everywhere)
pip install torch==2.3.1+cpu --extra-index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt
```

**Step 2c — Install and start Ollama**

```bash
# Download from https://ollama.com and install, then:
ollama serve           # Start the Ollama server (keep running)
ollama pull gemma3     # Download Gemma3 model (~4 GB, run once)
```

**Step 2d — Configure environment**

```bash
# Create .env in src/rag_system/ with the values shown above
```

**Step 3 — Start the RAG server**

```bash
# From inside src/rag_system/
python main.py
```

The server starts at `http://0.0.0.0:8000`.

> On first run, the server automatically indexes `data/markdown/guide.md` into ChromaDB. This takes **2–5 minutes**. Subsequent starts load the cached vectorstore instantly.

**Verify the server is ready:**

```bash
curl http://localhost:8000/health
```

Expected response:
```json
{
  "status": "ok",
  "ollama_connected": true,
  "chunks_indexed": 1247,
  "sessions_active": 0
}
```

**Test a query:**

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"question": "ما هي مقررات المستوى الأول؟"}' \
  -N
```

---

### 2. Flutter Mobile App

**Step 1 — Navigate to the Flutter source directory**

```bash
cd campus_ai/src
```

**Step 2 — Install Flutter dependencies**

```bash
flutter pub get
```

**Step 3 — Configure environment**

Create `src/.env` with the values shown in [Flutter App `.env`](#flutter-app--srcenv) above.

**Step 4 — Set up Firebase**

Follow the [Firebase Setup](#firebase-setup) steps above.

**Step 5 — Connect a device or start an emulator**

```bash
flutter devices   # list available devices
```

**Step 6 — Run the app**

```bash
flutter run
```

**Build release APK (Android):**

```bash
flutter build apk --release
# Output: src/build/app/outputs/flutter-apk/app-release.apk
# Copy the APK to the exe/ folder for distribution
```

**Build App Bundle (for Play Store):**

```bash
flutter build appbundle --release
```

> The RAG backend must be running **before** launching the app for the chatbot to work.

---

## Features

### Flutter App

| Feature | Description |
|---------|-------------|
| Authentication | Email/password login and registration via Firebase Auth |
| AI Chatbot | Arabic/English streaming chat with conversation history |
| Home | News feed and quick-access links |
| Department Browser | Explore faculty departments |
| Doctor Directory | Search and filter faculty members |
| GPA Calculator | Calculate semester and cumulative GPA |
| Campus Map | Interactive map with device geolocation |
| Services / FAQ | Common student questions and services |
| Academic Warnings | View academic standing and warnings |
| Course Registration | Course registration guidance |
| E-Learning | WebView integration with e-learning portal |
| UMS | University Management System WebView |
| Admin Dashboard | Data management for admins |

### RAG Backend

| Feature | Description |
|---------|-------------|
| Arabic NLP | Diacritic removal, alef normalization, prefix stripping |
| Hybrid Retrieval | Semantic (vector) + keyword (BM25) search fused via RRF |
| Table-Aware Ingestion | Academic tables preserved intact; headers repeated across fragments |
| Cross-Encoder Reranking | Optional Qwen3-Reranker for precision re-scoring (top-15 → top-5) |
| Conversation Memory | Multi-turn dialogue, TTL-based session eviction (1 hour) |
| Streaming Responses | Server-Sent Events for real-time token delivery |
| Structural Query Detection | Detects level/semester queries, applies metadata filtering |
| Local LLM | Ollama + Gemma3 — fully offline, no cloud API costs |

---

## API Reference

Base URL: `http://localhost:8000`

### `POST /chat`

Main chat endpoint — returns a streaming text response.

**Request body:**
```json
{
  "question": "ما هي مقررات المستوى الثالث؟",
  "session_id": "optional-uuid-for-conversation-continuity"
}
```

**Response:** `text/event-stream` — plain text tokens streamed as generated.

**Response headers:**
```
X-Session-ID:     <uuid>
X-Response-Time:  <seconds>
X-Sources:        ["chunk_1", "chunk_2", ...]
```

---

### `GET /health`

**Response:**
```json
{
  "status": "ok",
  "ollama_connected": true,
  "chunks_indexed": 1247,
  "sessions_active": 2
}
```

---

### `POST /retrieve`

Debug endpoint — returns raw retrieved chunks without LLM generation.

**Request body:**
```json
{
  "question": "المستوى الأول",
  "top_k": 5
}
```

---

### `POST /ingest`

Upload a new Markdown file to extend the knowledge base.

```bash
curl -X POST http://localhost:8000/ingest \
  -F "file=@new_guide.md"
```

**Response:**
```json
{
  "status": "ok",
  "chunks_added": 342,
  "message": "Indexed successfully"
}
```

---

### `DELETE /session/{session_id}`

Clear a conversation session's memory.

```bash
curl -X DELETE http://localhost:8000/session/your-session-uuid
```

---

## Common Issues

| Issue | Solution |
|-------|---------|
| Chatbot shows "Connection refused" | Make sure the RAG server is running on port 8000 |
| App cannot reach RAG server | Use machine's LAN IP (not `localhost`) in `src/.env` |
| Slow first chat response | Normal — first query warms up the embedding model (~10s) |
| Ollama not connected in `/health` | Run `ollama serve` before starting the RAG server |
| Vectorstore seems empty / wrong | Delete `src/rag_system/vectorstore/` folder and restart server |
| Firebase auth errors | Check `google-services.json` is in `src/android/app/` |
| `flutter pub get` fails | Run `flutter upgrade` then retry |
| `flutter run` not finding project | Make sure you are inside the `src/` directory |
