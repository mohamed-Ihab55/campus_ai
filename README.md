# Campus AI — Ain Shams University Student Guide

> An intelligent mobile application for Faculty of Science students at Ain Shams University, featuring an Arabic-first AI chatbot powered by a local Retrieval-Augmented Generation (RAG) system.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Language Composition](#language-composition)
- [System Architecture](#system-architecture)
- [Repository Structure](#repository-structure)
- [Prerequisites & Dependencies](#prerequisites--dependencies)
- [Environment Setup & Configuration](#environment-setup--configuration)
- [Installation Steps](#installation-steps)
- [Compilation Steps](#compilation-steps)
- [Run Instructions](#run-instructions)
- [Features](#features)
- [API Reference](#api-reference)
- [Common Issues & Troubleshooting](#common-issues--troubleshooting)
- [Additional Resources](#additional-resources)

---

## Project Overview

**Campus AI** consists of two fully integrated systems:

| System | Technology | Purpose |
|--------|-----------|---------|
| **Flutter Mobile App** | Dart / Flutter 3.11+ | Student-facing mobile interface |
| **RAG Backend** | Python / FastAPI | AI chatbot with document retrieval |

The Flutter app provides students with a comprehensive university companion:
- **AI Chatbot** — Arabic/English conversation with local RAG
- **GPA Calculator** — Semester and cumulative GPA computation
- **Doctor Directory** — Faculty member search and contact
- **Campus Map** — Interactive geolocation-enabled map
- **Course Registration** — Course selection guidance
- **Academic Warnings** — Academic standing notifications
- **E-Learning Integration** — Portal access (WebView)
- **UMS Integration** — University Management System access
- **News Feed** — Campus announcements and updates

The RAG backend answers academic questions by retrieving relevant sections from the Faculty of Science student guide using hybrid search (semantic + keyword) and a local LLM — no cloud AI dependencies.

---

## Language Composition

The repository consists of **multiple programming languages** optimized for their use cases:

```
┌──────────────────────────────────────────┐
│  Campus AI Language Distribution         │
├──────────────────────────────────────────┤
│  Dart (Flutter)        61.1%  ██████░░  │
│  Python (RAG/Backend)  29.3%  ███░░░░░  │
│  C++ (Native)           4.0%  ░░░░░░░░  │
│  CMake (Build)          3.1%  ░░░░░░░░  │
│  Shell (Scripts)        0.6%  ░░░░░░░░  │
│  Java                   0.5%  ░░░░░░░░  │
│  Other                  1.4%  ░░░░░░░░  │
└──────────────────────────────────────────┘
```

**Why this stack?**
- **Dart/Flutter (61.1%)**: Cross-platform mobile (iOS/Android) with fast UI performance
- **Python (29.3%)**: NLP, ML pipelines, RAG backend, document processing
- **C++ (4.0%)**: Native platform integrations and performance-critical sections
- **CMake (3.1%)**: Native build system for C++ components
- **Shell (0.6%)**: Automation scripts for setup and deployment
- **Java (0.5%)**: Android native components
- **Other (1.4%)**: Build scripts and configuration files

---

## System Architecture

```
┌──────────────────────────────────────────────────────────┐
│              Flutter Mobile App (Dart)                    │
│  ┌──────────┐  ┌──────────┐  ┌────────┐  ┌─────────┐   │
│  │   Home   │  │ Services │  │  Map   │  │ ChatBot │   │
│  └──────────┘  └──────────┘  └────────┘  └────┬────┘   │
│                                              │            │
│  Firebase Auth ←── Users        Firestore ──┘            │
└────────────────────────────────────┬─────────────────────┘
                                     │ HTTP POST /chat
                                     │ (streaming SSE)
┌────────────────────────────────────▼──────────────────────┐
│               RAG Backend (FastAPI)                        │
│                      (Python)                              │
│                                                           │
│  User Query                                               │
│      │                                                    │
│      ▼                                                    │
│  Language Detection (Arabic / English)                    │
│      │                                                    │
│      ├──► Vector Search (SentenceTransformer)             │
│      └──► BM25 Search (Arabic tokenizer)                  │
│                   │                                       │
│              RRF Fusion                                   │
│                   │                                       │
│           Reranker (Qwen3 / HuggingFace) [optional]       │
│                   │                                       │
│           Build Prompt + Context                          │
│                   │                                       │
│           Ollama + Gemma3 (local LLM)                     │
│                   │                                       │
│           Stream tokens → Flutter                         │
└────────────────────────────────────────────────────────────┘
```

**Chat Message Full Flow:**

```
1.  Student types a question in ChatBotScreen (Flutter)
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
├── src/
│   ├── flutter/                      # Flutter mobile application (61.1%)
│   │   ├── lib/                      # Dart source code
│   │   │   ├── main.dart             # App entry point
│   │   │   ├── app.dart              # Main navigation (PageView + BottomNav)
│   │   │   ├── firebase_options.dart # Firebase configuration
│   │   │   ├── core/
│   │   │   │   ├── helper/           # Reusable UI components
│   │   │   │   ├── theme/            # App colors, theme, dark mode
│   │   │   │   └── utils/            # Routes, constants, nav bar
│   │   │   └── features/
│   │   │       ├── authentication_feature/       # Firebase Auth
│   │   │       ├── chat_bot_feature/             # RAG chatbot integration
│   │   │       │   ├── data/
│   │   │       │   │   ├── cubit/    # ChatCubit + ChatState
│   │   │       │   │   ├── model/    # ChatMessage model
│   │   │       │   │   └── services/ # HTTP calls to RAG API
│   │   │       │   └── presentation/ # Chat UI screens & widgets
│   │   │       ├── home_feature/                 # Home page
│   │   │       ├── departments_feature/          # Department listing
│   │   │       ├── doctors_feature/              # Faculty directory
│   │   │       ├── gpa_feature/                  # GPA calculator
│   │   │       ├── map_feature/                  # Campus map (Flutter Map)
│   │   │       ├── service_feature/              # Services & FAQs
│   │   │       ├── academic_warning_feature/     # Warnings & alerts
│   │   │       ├── course_registration_feature/  # Course registration
│   │   │       ├── elearn_web_view_feature/      # E-learning portal
│   │   │       ├── news_feature/                 # News feed
│   │   │       ├── transcript_feature/           # Academic transcript
│   │   │       ├── dashboard_screen/             # Admin dashboard
│   │   │       └── ums_webview_feature/          # UMS access
│   │   ├── android/                  # Android native configuration (C++, CMake, Java)
│   │   ├── ios/                      # iOS native configuration
│   │   ├── web/                      # Web platform files
│   │   ├── assets/                   # Images and static files
│   │   ├── test/                     # Flutter widget tests
│   │   └── pubspec.yaml              # Flutter dependencies
│   │
│   └── rag/                          # Python RAG backend (29.3%)
│       ├── main.py                   # FastAPI server
│       ├── retriever.py              # Hybrid RRF retrieval engine
│       ├── reranker.py               # Qwen3 cross-encoder reranking
│       ├── memory.py                 # Conversation memory (TTL-based)
│       ├── ingest_markdown.py        # Table-aware markdown ingestion
│       ├── requirements.txt          # Python dependencies
│       ├── setup.sh                  # Automated setup script
│       ├── data/
│       │   └── markdown/
│       │       └── guide.md          # Faculty of Science student guide
│       └── vectorstore/              # Auto-generated on first run
│           ├── chroma.sqlite3
│           └── bm25_cache.pkl
├── exe/                              # Pre-built executables
│   └── README.md                     # APK/binary distribution guide
└── README.md                         # This file

```

> **exe/ folder:** Place your compiled Android APK (`app-release.apk`) here after building with `flutter build apk --release`. This allows users to install the app without compiling from source.

---

## Prerequisites & Dependencies

### RAG Backend (Python)

#### System Requirements

| Requirement | Version/Specification | Notes |
|-------------|-------|-------|
| **Python** | 3.10 – 3.12 | 3.11 recommended for compatibility |
| **pip** | Latest | Python package manager |
| **Ollama** | Latest | [ollama.com](https://ollama.com) — **must be running** |
| **Gemma3 Model** | via Ollama | ~4 GB VRAM download (first run only) |
| **CUDA Toolkit** | 12.1 (optional) | For GPU acceleration (RTX 3050+) |
| **RAM** | 8 GB minimum | 16 GB recommended |
| **Disk Space** | 5 GB free | Models + vectorstore storage |
| **OS** | Linux, macOS, Windows | Any modern OS with Python 3.10+ |

#### Python Packages

| Package | Version | Purpose |
|---------|---------|---------|
| **fastapi** | 0.111.0 | HTTP API framework |
| **uvicorn[standard]** | 0.29.0 | ASGI server |
| **sentence-transformers** | 3.0.1 | Multilingual embeddings (Arabic support) |
| **chromadb** | 0.5.3 | Vector database |
| **httpx** | 0.27.0 | Async HTTP client (Ollama + HuggingFace) |
| **langdetect** | 1.0.9 | Language detection |
| **langchain-text-splitters** | 0.2.4 | Markdown-aware text chunking |
| **rank-bm25** | 0.2.2 | BM25 keyword retrieval |
| **numpy** | 1.26.4 | Numerical computing |
| **transformers** | 4.41.2 | HuggingFace model support |
| **torch** | 2.3.1+cu121 | Deep learning (GPU) |
| **pydantic** | 2.7.1 | Request/response validation |
| **scikit-learn** | 1.4.2 | Machine learning utilities |
| **pandas** | 2.2.2 | Data processing |
| **joblib** | ≥1.3.0 | Model persistence |
| **python-dotenv** | 1.0.1 | Environment variables |

**Note:** Full requirements are pinned in `src/rag/requirements.txt`

---

### Flutter Mobile App (Dart/Flutter)

#### System Requirements

| Requirement | Version | Notes |
|-------------|---------|-------|
| **Flutter SDK** | ≥3.11.5 | [flutter.dev/install](https://flutter.dev/docs/get-started/install) |
| **Dart SDK** | Included | Part of Flutter SDK |
| **Android Studio** | Latest | For Android development |
| **Xcode** | 15+ | macOS only — for iOS builds |
| **Android SDK** | API 21+ | Android 5.0 minimum target |
| **CMake** | ≥3.10 | For native C++ compilation |
| **Firebase Project** | — | Auth + Firestore required |
| **Git** | Latest | Version control |

#### Flutter Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| **firebase_core** | ^4.7.0 | Firebase initialization |
| **firebase_auth** | ^6.4.0 | User authentication |
| **cloud_firestore** | ^6.3.0 | Message persistence |
| **flutter_bloc** | ^9.1.1 | Cubit state management |
| **flutter_riverpod** | ^3.3.1 | Navigation state management |
| **dio** | ^5.9.2 | HTTP client for RAG API |
| **flutter_dotenv** | ^6.0.1 | Environment variables |
| **webview_flutter** | ^4.13.1 | E-learning & UMS integration |
| **flutter_map** | ^8.3.0 | Campus map with geolocation |
| **flutter_markdown** | ^0.7.4 | Render chatbot responses |
| **google_sign_in** | ^7.2.0 | Google authentication |
| **geolocator** | ^14.0.2 | Device location services |
| **url_launcher** | ^6.3.2 | Open external URLs |
| **font_awesome_flutter** | ^11.0.0 | Icon library |
| **intl** | ^0.19.0 | Internationalization |

**Note:** Full dependency list in `src/flutter/pubspec.yaml`

---

## Environment Setup & Configuration

### RAG Backend — `src/rag/.env`

Create a `.env` file in the `src/rag/` directory with the following configuration:

```env
# ════════════════════════════════════════════════════════════
# LLM Configuration
# ════════════════════════════════════════════════════════════

# Ollama model name and endpoint
OLLAMA_MODEL=gemma3
OLLAMA_URL=http://127.0.0.1:11434/api/chat

# ════════════════════════════════════════════════════════════
# Retrieval Configuration
# ════════════════════════════════════════════════════════════

# Number of chunks to retrieve per query
TOP_K=8

# ════════════════════════════════════════════════════════════
# Conversation Memory Configuration
# ════════════════════════════════════════════════════════════

# Maximum conversation turns per session (stores ~12 messages)
MAX_TURNS=6

# Maximum concurrent sessions
MAX_SESSIONS=200

# Session time-to-live in seconds (1 hour = 3600)
SESSION_TTL=3600

# ════════════════════════════════════════════════════════════
# Reranker Configuration (Optional)
# ════════════════════════════════════════════════════════════

# HuggingFace API token for Qwen3 reranking
# Get a free token at: https://huggingface.co/settings/tokens
# Without this token, system gracefully falls back to RRF ranking
HF_API_TOKEN=hf_your_token_here

# Reranker model identifier
RERANKER_MODEL=Qwen/Qwen3-Reranker-0.6B

# Concurrency limit for HuggingFace API calls
RERANKER_CONCURRENCY=4
```

**Key Notes:**
- **OLLAMA_URL**: Must match your Ollama server location (default: `http://127.0.0.1:11434`)
- **TOP_K**: Balanced at 8 to accommodate full academic tables
- **SESSION_TTL**: 3600 seconds (1 hour) prevents session bloat
- **HF_API_TOKEN**: Optional — improves accuracy by 20–30% if provided

---

### Flutter App — `src/flutter/.env`

Create a `.env` file in the `src/flutter/` directory:

```env
# ════════════════════════════════════════════════════════════
# RAG Backend Connection
# ════════════════════════════════════════════════════════════

# RAG backend URL — use your machine's LAN IP, NOT localhost
# The device/emulator and RAG server must be on the SAME network
#
# To find your local IP:
#   Windows:  run `ipconfig` in Command Prompt
#   Mac/Linux: run `ifconfig` in Terminal
#
# Example: http://192.168.1.100:8000
CHAT_BOT_API_KEY=http://192.168.x.x:8000

# ════════════════════════════════════════════════════════════
# Google Maps (for campus map feature)
# ════════════════════════════════════════════════════════════

# Get a free Google Maps API key from:
# https://console.cloud.google.com/
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

**Critical:** The phone/emulator and the RAG server **must be on the same Wi-Fi network**. Replace `192.168.x.x` with your actual machine's local IP.

---

### Firebase Setup (Required for Flutter)

1. **Create Firebase Project:**
   - Navigate to [console.firebase.google.com](https://console.firebase.google.com)
   - Click "Add project"
   - Follow the setup wizard

2. **Enable Authentication:**
   - In Firebase Console → Authentication
   - Click "Get Started"
   - Enable **Email/Password** provider
   - Enable **Google Sign-In** (optional)

3. **Enable Cloud Firestore:**
   - In Firebase Console → Firestore Database
   - Click "Create database"
   - Start in **Test Mode** (production rules can be set later)
   - Select region closest to your users

4. **Android Configuration:**
   - Download `google-services.json` from Firebase Console
   - Place in `src/flutter/android/app/`
   - This file is required for Android builds

5. **iOS Configuration:**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place in `src/flutter/ios/Runner/`
   - This file is required for iOS builds

6. **Update Firebase Options:**
   - Run from inside `src/flutter/` directory:
     ```bash
     flutterfire configure
     ```
   - OR manually update `src/flutter/lib/firebase_options.dart` with your project credentials

---

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/mohamed-Ihab55/campus_ai.git
cd campus_ai
```

---

### 2. RAG Backend (Python)

#### Step 1 — Navigate to RAG Directory

```bash
cd src/rag
```

#### Step 2 — Automated Setup (Recommended)

```bash
# Make setup script executable
chmod +x setup.sh

# Run automated setup
bash setup.sh
```

**What the script does:**
1. Creates Python virtual environment (`.venv`)
2. Installs all dependencies from `requirements.txt`
3. Verifies Ollama installation
4. Starts Ollama server (if not running)
5. Pulls Gemma3 model (~4 GB, first run only)
6. Indexes `data/markdown/guide.md` into ChromaDB
7. Starts FastAPI server at `http://0.0.0.0:8000`

#### Step 2 — Manual Setup (Alternative)

**Step 2a — Create Virtual Environment**

```bash
python -m venv .venv

# Activate virtual environment:
# Windows:
.venv\Scripts\activate

# macOS / Linux:
source .venv/bin/activate
```

**Step 2b — Install Python Dependencies**

```bash
# WITH GPU support (CUDA 12.1 — recommended for RTX 3050+)
pip install torch==2.3.1+cu121 --extra-index-url https://download.pytorch.org/whl/cu121
pip install -r requirements.txt

# WITHOUT GPU (CPU only — slower but works everywhere)
pip install torch==2.3.1+cpu --extra-index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt
```

**Step 2c — Install and Start Ollama**

```bash
# 1. Download and install from https://ollama.com
# 2. Start the Ollama server (keep running in background)
ollama serve

# 3. In a new terminal, pull Gemma3 model (~4 GB, run once)
ollama pull gemma3
```

**Step 2d — Create Environment Configuration**

```bash
# Create .env in src/rag/ with content from "Environment Setup & Configuration" section above
cat > .env << 'EOF'
OLLAMA_MODEL=gemma3
OLLAMA_URL=http://127.0.0.1:11434/api/chat
TOP_K=8
MAX_TURNS=6
MAX_SESSIONS=200
SESSION_TTL=3600
HF_API_TOKEN=hf_your_token_here
RERANKER_MODEL=Qwen/Qwen3-Reranker-0.6B
RERANKER_CONCURRENCY=4
EOF
```

---

### 3. Flutter Mobile App

#### Step 1 — Navigate to Flutter Directory

```bash
cd campus_ai/src/flutter
```

#### Step 2 — Install Flutter Dependencies

```bash
# Download all Dart packages
flutter pub get

# Update to latest compatible versions (optional)
flutter pub upgrade
```

#### Step 3 — Create Environment Configuration

Create `src/flutter/.env`:

```bash
cat > .env << 'EOF'
CHAT_BOT_API_KEY=http://192.168.x.x:8000
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
EOF
```

**Replace `192.168.x.x` with your machine's actual local IP.**

#### Step 4 — Set Up Firebase

Follow the **Firebase Setup** section above:
1. Create Firebase project
2. Enable Authentication and Firestore
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place in appropriate directories
5. Run `flutterfire configure`

#### Step 5 — Connect Device or Start Emulator

```bash
# List available devices
flutter devices

# Start Android emulator (if installed)
emulator -avd <emulator_name>

# Start iOS simulator (macOS only)
open -a Simulator
```

---

## Compilation Steps

### RAG Backend (Python) — No Compilation Needed

The RAG backend is written in pure Python and does not require compilation. However, dependencies like `torch` and `sentence-transformers` may compile native extensions during installation.

**To verify the backend is ready:**

```bash
# From src/rag/ directory (with virtual environment activated)
python -c "import fastapi, torch, sentence_transformers; print('✓ All dependencies loaded successfully')"
```

---

### Flutter Mobile App — Compilation Required

#### Android Build (APK for Installation)

```bash
# From src/flutter/ directory

# Build debug APK (for testing)
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk

# Build release APK (optimized, for distribution)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Copy release APK to exe/ folder for distribution
cp build/app/outputs/flutter-apk/app-release.apk ../../exe/
```

#### Android App Bundle (For Play Store)

```bash
# Build optimized app bundle
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# Upload to Google Play Console for distribution
```

#### iOS Build (macOS Only)

```bash
# From src/flutter/ directory

# Build debug iOS app
flutter build ios --debug

# Build release iOS app (for App Store)
flutter build ios --release

# To run on iOS device:
# 1. Open in Xcode for code signing
# 2. Set signing certificate and provisioning profile
# 3. Build and deploy
```

**Typical Compilation Time:**
- First build: 5–15 minutes (downloads dependencies)
- Subsequent builds: 1–3 minutes (cached)

---

## Run Instructions

### Start the RAG Backend

```bash
# From src/rag/ directory (with virtual environment activated)

# Terminal 1: Start Ollama (keep running)
ollama serve

# Terminal 2: Start FastAPI server
python main.py
```

The server will start at `http://0.0.0.0:8000`.

**On first run:** Server automatically indexes `data/markdown/guide.md` — this takes **2–5 minutes**. Subsequent starts load the cached vectorstore instantly.

**Verify the server is ready:**

```bash
curl http://localhost:8000/health

# Expected response:
# {
#   "status": "ok",
#   "ollama_connected": true,
#   "chunks_indexed": 1247,
#   "sessions_active": 0
# }
```

**Test a query:**

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"question": "ما هي مقررات المستوى الأول؟"}' \
  -N
```

---

### Run the Flutter App

#### Development Mode (Hot Reload)

```bash
# From src/flutter/ directory

# Run on connected device or emulator
flutter run

# Run with verbose logging (for debugging)
flutter run -v
```

**Hot Reload:**
- Press `r` to hot reload (UI changes only)
- Press `R` to hot restart (state reset)
- Press `q` to quit

#### Production Mode

```bash
# Build and run release APK on Android
flutter run --release

# For iOS
flutter run --release -d <ios_device_id>
```

---

### Install Pre-Built APK (No Compilation Needed)

If an `app-release.apk` is available in the `exe/` folder:

```bash
# Using ADB (Android Debug Bridge)
adb install exe/app-release.apk

# Or manually:
# 1. Copy app-release.apk to Android phone
# 2. Open file manager and tap the APK
# 3. Follow installation prompts
```

---

## Features

### Flutter Mobile App

| Feature | Description |
|---------|-------------|
| **Authentication** | Email/password login and registration via Firebase Auth |
| **AI Chatbot** | Arabic/English streaming chat with multi-turn conversation memory |
| **Home Feed** | Campus news and quick-access shortcuts |
| **Department Browser** | Explore faculty departments and details |
| **Doctor Directory** | Search and filter faculty members with contact info |
| **GPA Calculator** | Compute semester and cumulative GPA with credit hours |
| **Campus Map** | Interactive map with device geolocation and points of interest |
| **Services & FAQ** | Common student questions and services information |
| **Academic Warnings** | View academic standing and warning notifications |
| **Course Registration** | Course registration guidance and prerequisites |
| **E-Learning Portal** | WebView integration with institutional e-learning system |
| **UMS Access** | University Management System WebView integration |
| **Admin Dashboard** | Administrative data management interface |

### RAG Backend

| Feature | Description |
|---------|-------------|
| **Arabic NLP** | Diacritic removal, alef normalization, prefix stripping |
| **Hybrid Retrieval** | Semantic (vector) + keyword (BM25) search fused via RRF |
| **Table-Aware Ingestion** | Academic tables preserved intact; headers repeated across fragments |
| **Cross-Encoder Reranking** | Optional Qwen3-Reranker for precision re-scoring |
| **Conversation Memory** | Multi-turn dialogue with TTL-based session eviction |
| **Streaming Responses** | Server-Sent Events for real-time token delivery |
| **Structural Query Detection** | Detects level/semester queries and applies smart filtering |
| **Local LLM** | Ollama + Gemma3 — fully offline, no cloud API costs |

---

## API Reference

Base URL: `http://localhost:8000`

### `POST /chat`

Main chat endpoint — returns streaming text response.

**Request:**
```json
{
  "question": "ما هي مقررات المستوى الثالث؟",
  "session_id": "optional-uuid-for-conversation-continuity"
}
```

**Response:** `text/event-stream` — plain text tokens streamed as generated.

**Response Headers:**
```
X-Session-ID:     <uuid>
X-Response-Time:  <seconds>
X-Sources:        [chunk indices]
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

**Request:**
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

## Common Issues & Troubleshooting

| Issue | Root Cause | Solution |
|-------|-----------|----------|
| **Chatbot shows "Connection refused"** | RAG server not running | Ensure `python main.py` is running on port 8000 |
| **App cannot reach RAG server** | Using `localhost` instead of LAN IP | Use your machine's actual LAN IP (run `ipconfig` or `ifconfig`) in `.env` |
| **Slow first chat response** | Embedding model warmup | Normal — first query warms up embedder (~10s). Subsequent queries are faster. |
| **"Ollama not connected" in `/health`** | Ollama server not running | Run `ollama serve` in a separate terminal before starting RAG server |
| **Vectorstore seems empty / chunks not found** | Corrupted or missing vectorstore | Delete `src/rag/vectorstore/` folder and restart server (re-indexes automatically) |
| **Firebase auth errors in Flutter** | Missing configuration files | Check `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) are in correct directories |
| **`flutter pub get` fails** | Flutter SDK outdated | Run `flutter upgrade` then retry |
| **`flutter run` says "project not found"** | Wrong working directory | Ensure you're inside `src/flutter/` directory |
| **"CUDA out of memory"** | GPU memory insufficient | Reduce `TOP_K` in `.env` or use CPU-only torch build |
| **Chat responses cut off** | Context window exceeded | Reduce `MAX_TURNS` in `.env` (default: 6) |
| **App crashes on startup** | Missing Firebase configuration | Complete Firebase setup and place config files in correct locations |
| **"Port 8000 already in use"** | Another process using port | Kill existing process or change port in `main.py` |
| **Slow APK compilation** | First-time build with full dependency download | Subsequent builds will be faster; use `--release` for production |
| **Google Maps not showing on campus map** | Invalid API key | Verify `GOOGLE_MAPS_API_KEY` in `.env` is correct and has appropriate permissions |
| **Geolocation permission denied** | App permissions not granted | Grant location permission when prompted by Flutter app |

---

## Additional Resources

- **Flutter Documentation:** https://flutter.dev/docs
- **FastAPI Documentation:** https://fastapi.tiangolo.com/
- **Ollama:** https://ollama.com/library/gemma3
- **ChromaDB:** https://www.trychroma.com/
- **Firebase Console:** https://console.firebase.google.com
- **RAG Backend Documentation:** `src/rag/README.md`
- **GitHub Repository:** https://github.com/mohamed-Ihab55/campus_ai

---

## License

This project is proprietary and intended for educational purposes at Ain Shams University.

---

## Contact & Support

For issues, questions, or contributions, please refer to the GitHub repository or contact the development team.

**Last Updated:** May 11, 2026
