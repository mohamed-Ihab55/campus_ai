#!/usr/bin/env bash
# setup.sh — One-time setup + run script for the RAG chatbot
# Run with:  bash setup.sh

set -e

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║     Arabic RAG Chatbot — Setup Script        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── 1. Python virtual environment ──────────────────────────────────────────────
if [ ! -d ".venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python -m venv .venv
fi
source .venv/bin/activate

echo "📦 Installing Python dependencies..."
pip install --upgrade pip -q
pip install -r requirements.txt -q
echo "✅ Python dependencies installed"

# ── 2. Ollama check ────────────────────────────────────────────────────────────
echo ""
echo "🔍 Checking Ollama..."
if ! command -v ollama &> /dev/null; then
    echo "❌ Ollama not found. Install it from: https://ollama.com/download"
    echo "   Then run:  ollama pull gemma3"
    exit 1
fi

# Check if Ollama is running
if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "🚀 Starting Ollama server in background..."
    ollama serve &
    sleep 3
fi

echo "✅ Ollama is running"

# ── 3. Pull LLM model if needed ────────────────────────────────────────────────
echo ""
echo "📥 Checking for gemma3 model..."
if ! ollama list | grep -q "gemma3"; then
    echo "📥 Pulling gemma3 (this downloads ~4 GB once)..."
    ollama pull gemma3
else
    echo "✅ gemma3 already available"
fi

# ── 4. Prepare Markdown knowledge base ────────────────────────────────────────
echo ""
echo "📁 Preparing data/markdown/ directory..."
mkdir -p data/markdown

MD_FILES=$(find data/markdown -name "*.md" 2>/dev/null | wc -l)
if [ "$MD_FILES" -gt 0 ]; then
    echo "📄 Found $MD_FILES Markdown file(s). Ingesting..."
    python ingest_markdown.py
    echo "✅ Knowledge base ready"
else
    echo "⚠️  No Markdown files found in data/markdown/"
    echo "   Place your .md files there and either:"
    echo "     • Run:  python ingest_markdown.py"
    echo "     • Or upload via the web UI at http://localhost:8000"
fi

# ── 5. Start FastAPI ───────────────────────────────────────────────────────────
echo ""
echo "🚀 Starting FastAPI server..."
echo "   UI:        http://localhost:8000"
echo "   API docs:  http://localhost:8000/docs"
echo "   Health:    http://localhost:8000/health"
echo "   Press Ctrl+C to stop"
echo ""

uvicorn main:app --host 0.0.0.0 --port 8000 --reload
