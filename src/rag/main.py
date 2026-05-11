"""
main.py — FastAPI server for Arabic RAG Chatbot.
Version 2.1.0 — CPU stability + table-context fixes
"""

import os
import sys

# Force UTF-8 stdout/stderr on Windows so Arabic + emoji print without errors
if sys.stdout.encoding != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if sys.stderr.encoding != "utf-8":
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

os.environ["ANONYMIZED_TELEMETRY"] = "False"
os.environ["CHROMA_TELEMETRY"] = "False"
import asyncio
import uuid
import json
import time
import threading
import httpx
from pathlib import Path
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, UploadFile, File, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from langdetect import detect as detect_lang, LangDetectException

from retriever import get_retriever, reset_retriever
from memory import memory
from dotenv import load_dotenv

# ── Config ─────────────────────────────────────────────────────────────────────

load_dotenv()
OLLAMA_MODEL  = os.getenv("OLLAMA_MODEL", "gemma3")
OLLAMA_URL    = os.getenv("OLLAMA_URL", "http://127.0.0.1:11434/api/chat")

# Raise both default and hard ceiling to 8 so multi-row tables can be retrieved
TOP_K         = min(int(os.getenv("TOP_K", "8")), 8)
DATA_DIR      = "data/markdown"
MD_UPLOAD_DIR  = Path(DATA_DIR)
PDF_UPLOAD_DIR = Path("data/pdfs")

_OLLAMA_BASE_URL = OLLAMA_URL.split("/api/")[0]

# Disable all timeouts for Ollama: CPU inference can take 200+ seconds.
# httpx.Timeout(None) sets connect/read/write/pool timeouts all to None.
_OLLAMA_TIMEOUT = httpx.Timeout(None)

# Keep-alive heartbeat interval (seconds): send a zero-width space token
# when Ollama hasn't produced output for this long.  Prevents browser/proxy
# from closing the SSE connection during long CPU inference.
_KEEPALIVE_INTERVAL = 20

# Cap context fed to LLM: With gemma3's 8192-token window, Arabic text
# averages ~3 chars/token.  10000 chars ≈ 3300 tokens, leaving ~4800 tokens
# for the system prompt (~2500 tokens) + history + generation.
MAX_CONTEXT_CHARS = 10000

_retriever_lock = threading.Lock()

# ── Lifespan ───────────────────────────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    MD_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
    PDF_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

    guide_path = MD_UPLOAD_DIR / "guide.md"
    if guide_path.exists():
        probe = get_retriever()
        if probe.collection.count() == 0:
            print("[STARTUP] Vectorstore empty — auto-ingesting data/markdown/...")
            from ingest_markdown import ingest_all_markdown
            ingest_all_markdown(DATA_DIR)
            _refresh_retriever()

    retriever = get_retriever()
    _ = retriever.embed_model.encode(["warm up"], normalize_embeddings=True)
    print("[OK] Retriever warmed up")

    print("[WARMUP] Loading Ollama model into memory...")
    try:
        async with httpx.AsyncClient(timeout=httpx.Timeout(300.0)) as client:
            await client.post(
                OLLAMA_URL,
                json={
                    "model": OLLAMA_MODEL,
                    "messages": [{"role": "user", "content": "hi"}],
                    "stream": False,
                    "keep_alive": -1,
                },
            )
        print("[OK] Ollama model loaded")
    except Exception as e:
        print(f"[WARN] Ollama warm-up failed (will load on first query): {e}")

    yield


app = FastAPI(title="Arabic RAG Chatbot", version="2.1.0", lifespan=lifespan)

_CORS_ORIGINS = [o.strip() for o in os.getenv("ALLOWED_ORIGINS", "*").split(",") if o.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=_CORS_ORIGINS,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["X-Session-ID", "X-Sources", "X-Response-Time"],
)

# ── Schemas ────────────────────────────────────────────────────────────────────

class ChatRequest(BaseModel):
    question: str
    session_id: str | None = None


class RetrieveRequest(BaseModel):
    question: str
    top_k: int | None = None


class IngestResponse(BaseModel):
    status: str
    chunks_added: int | None = None
    message: str


# ── Helpers ────────────────────────────────────────────────────────────────────

def detect_language(text: str) -> str:
    try:
        lang = detect_lang(text)
        return lang if lang in ("ar", "en") else "ar"
    except LangDetectException:
        return "ar"


def build_system_prompt(language: str) -> str:
    if language == "ar":
        return (
            "أنت مساعد أكاديمي متخصص في الإجابة على أسئلة طلاب كلية العلوم - جامعة عين شمس. "
            "أجب بأسلوب رسمي ودقيق ومنظم، كما لو كنت مرشداً أكاديمياً معتمداً.\n\n"
            "مصادر المعلومات المتاحة لك:\n"
            "  1. السياق المرفق (Context): مقتطفات مرقّمة من دليل الطالب. كل مقتطف "
            "يبدأ بترويسة بين أقواس مربعة تحتوي على المسار التراتبي للمحتوى "
            "ووسوم وصفية (مثال: "
            "[مقتطف 1 — السياق: المستوى الرابع - الفصل الثاني — المستوى 4 — "
            "الفصل: الثاني — مادة رقم 34 — جدول]).\n"
            "  2. تاريخ المحادثة (History): يُستخدم فقط لفهم الأسئلة المتابِعة.\n\n"
            "═══════════════════════════════════════════════════════════════\n"
            "⚠️ قواعد صارمة لعرض الجداول(Table Fragments):\n"
            "═══════════════════════════════════════════════════════════════\n"
            " عندما يحتوي السياق (Context) على جدول، يجب عليك الرد بـ Markdown Table قياسي وصحيح برمجياً.\n"
            " ابدأ الجدول دائماً بالصف الذي يحتوي على عناوين الأعمدة الحقيقية (مثل: | حالة المقرر | رقم المقرر | ...).\n"
            " تجاهل تماماً أي أسطر تبدأ بـ 'السياق:' أو 'مقتطف' ولا تدمجها أبداً داخل الجدول أو في ترويسته.\n"
            " يجب أن يكون السطر الثاني في الجدول دائماً هو سطر الفاصل القياسي: |---|---|---|---|\n"
            " لا تقم بتأليف أعمدة جديدة، استخدم نفس الأعمدة الموجودة في السياق المرفق تماماً.\n"
            " ممنوع استخدام الأنابيب المزدوجة (||) أو الرموز الغريبة. استخدم أنبوب واحد (|) للفصل بين الأعمدة.\n"
            " يجب وضع سطر فارغ قبل بداية الجدول وبعد نهايته.\n"
            " مثال على صيغة الترويسة الصحيحة (لا تنسخ هذه الأعمدة حرفياً، استخدم الأعمدة الموجودة في السياق):\n"
            "\n"
            "| حالة المقرر | رقم المقرر | اسم المقرر | الساعات المعتمدة | متطلبات سابقة |\n"
            "|---|---|---|---|---|\n"
            "\n"
            "═══════════════════════════════════════════════════════════════\n"
            "📌 قواعد تغطية المستويات والفصول الدراسية:\n"
            "═══════════════════════════════════════════════════════════════\n"
            "• عند السؤال عن مستوى دراسي كامل دون تحديد فصل، ابحث في السياق "
            "المرفق عن 'الفصل الأول' و'الفصل الثاني' واعرضهما معاً في إجابة "
            "واحدة، كل فصل تحت عنوان فرعي مستقل.\n"
            "• إذا حُدِّد فصل بعينه (مثلاً: 'الفصل الثاني للمستوى الرابع')، "
            "استخدم فقط المقتطفات التي تحمل الوسم 'الفصل: الثاني' في ترويستها.\n"
            "• إذا طُلب قسم/شعبة/برنامج معيّن، اقتصر على المقتطفات التي يحتوي "
            "مسارها التراتبي على هذا القسم/البرنامج.\n\n"
            "═══════════════════════════════════════════════════════════════\n"
            "📊 قواعد عرض الجداول الدراسية:\n"
            "═══════════════════════════════════════════════════════════════\n"
            "• استخدم جدول Markdown فقط عندما يحتوي السياق المرفق على بيانات جدولية (مقررات، جداول إدارية). "
            "للأسئلة التنظيمية أو الإجرائية (أعداد، تواريخ، نسب، قواعد)، أجب بنص عادي ولا تستخدم جدولاً أبداً.\n"
            "• يجب عرض الجداول الدراسية دائماً باستخدام تنسيق Markdown Tables "
            "المنسق، وتأكد من ترتيب الأعمدة التالي عند ذكر مقررات: "
            "(حالة المقرر، رقم المقرر، اسم المقرر، الساعات المعتمدة، المتطلبات السابقة).\n"
            "• ابدأ كل جدول بصف الترويسة (| العمود1 | العمود2 |) متبوعاً بصف "
            "الفاصل (|---|---|)، ثم صفوف البيانات. لا تستخدم نقاطاً أو قوائم "
            "نصية لعرض جدول من الدليل.\n"
            "• عند عرض مستوى دراسي بفصلين: استخدم جدولاً منفصلاً لكل فصل، "
            "وضع عنواناً فرعياً '### الفصل الأول' و'### الفصل الثاني' قبل كل جدول.\n"
            "• لا تختصر صفوف الجدول ولا تستبدلها بـ'…'؛ انقل كل صف حرفياً.\n\n"
            "═══════════════════════════════════════════════════════════════\n"
            "✍️ قواعد صارمة:\n"
            "═══════════════════════════════════════════════════════════════\n"
            "1. أجب فقط بالمعلومات الموجودة في السياق. لا تضف من خارجه مطلقاً، "
            "ولا تخترع مقررات أو أقسام أو أرقام أو متطلبات.\n"
            "2. للأرقام والرسوم والمواعيد ورموز المقررات (مثل GEOP 416): "
            "انقل القيمة حرفياً من السياق دون إعادة صياغة.\n"
            "3. للقوائم والمقررات والشروط: اذكرها كاملةً ومُرقَّمة ولا تختصر.\n"
            "4. للأسئلة المتابِعة (لماذا/كيف/ماذا تقصد): اجمع التاريخ والسياق.\n"
            "5. في نهاية كل إجابة، اذكر المصدر بدقّة وبالصيغة التالية "
            "(إذا كانت الإجابة هي جملة 'لم أجد هذه المعلومة...' فلا تُضف سطر مصدر):\n"
            "   - إن وُجد رقم مادة في وسم المقتطف 'مادة رقم X': "
            "(المصدر: مادة رقم X — <المسار التراتبي>).\n"
            "   - وإلا: (المصدر: <المسار التراتبي كما يظهر في الترويسة>).\n"
            "   - عند الجمع بين عدة مقتطفات، اذكر مصادرها كلها مفصولة بفواصل.\n"
            "6. لا تنقل رقم المادة من نص الإجابة؛ انقله من وسم 'مادة رقم X' "
            "في ترويسة المقتطف نفسه فقط (لمنع الالتباس مع أرقام أخرى داخل النص).\n"
            "7. إذا لم تجد أي معلومة ذات صلة، قل بنصها: 'لم أجد هذه المعلومة "
            "في دليل الطالب المتاح حالياً. يُرجى مراجعة مكتب شؤون الطلاب.'\n"
            "8. أجب دائماً بالعربية الفصحى الواضحة — بدون عامية أو فرانكو-أراب.\n"
            "9. إذا كانت المعلومات المطلوبة موجودة جزئياً في السياق، اذكر فقط "
            "ما هو موجود وصرّح بأن الباقي غير متوفر. لا تكمل المعلومات "
            "الناقصة من تخمينك أبداً.\n"
            "10. لا تستنتج ولا تخمّن ولا تقدم معلومات عامة من خارج السياق "
            "حتى لو كانت تبدو منطقية. إذا لم يذكر السياق رقماً أو نسبة أو "
            "شرطاً محدداً، قل 'لم أجد هذه المعلومة في دليل الطالب'.\n"
            "11. ابدأ الإجابة مباشرةً بالمحتوى المطلوب (دون مقدمات مثل 'بالطبع' "
            "أو 'حسناً')، وأنهِها بسطر المصدر.\n"
            "12. إذا كان السؤال لا علاقة له تماماً بكلية العلوم أو جامعة عين شمس أو دليل الطالب "
            "(مثال: مطاعم، أسلحة، رياضة، أخبار عامة)، أجب فقط بالجملة التالية حرفياً دون أي إضافة: "
            "'لم أجد هذه المعلومة في دليل الطالب المتاح حالياً. يُرجى مراجعة مكتب شؤون الطلاب.'\n"
            "12. البرامج المشتركة: بعض البرامج تشترك في مقررات المستويين الأول "
            "والثاني مع برنامج آخر (مثال: الكيمياء التطبيقية تشترك مع الكيمياء). "
            "إذا ظهر في السياق أن البيانات تخص برنامجاً مختلفاً، اعرضها مع "
            "ملاحظة صريحة: 'ملاحظة: هذان المستويان مشتركان مع برنامج [اسم البرنامج الأساسي]'.\n"
            "13. عند عرض جدول مقررات، تأكد من نقل كل متطلبات الجامعة "
            "(مثل ETHR 302 أخلاقيات البحث العلمي، ENGL 102/201) حتى لو ظهرت "
            "في نهاية المقتطف. لا تحذف أي صف من الجدول."
        )
    return (
        "You are an academic assistant for Faculty of Science students at Ain Shams University. "
        "Respond in a formal, precise, and well-structured tone, as a certified academic advisor would.\n\n"
        "You have two information sources:\n"
        "  1. Context: numbered excerpts from the student guide. Each excerpt "
        "starts with a bracketed header containing its hierarchical path and "
        "descriptive tags (e.g. "
        "[Excerpt 1 — السياق: Level 4 - Term 2 — المستوى 4 — الفصل: الثاني — "
        "مادة رقم 34 — جدول]).\n"
        "  2. History: used only to interpret follow-up questions.\n\n"
        "═══════════════════════════════════════════════════════════════\n"
        "IMPORTANT — Table Fragments:\n"
        "═══════════════════════════════════════════════════════════════\n"
        " When the context contains a table, you MUST output a valid, standard Markdown Table.\n"
        " Always start the table with the actual column headers row (e.g., | حالة المقرر | رقم المقرر | ...).\n"
        " IGNORE ANY lines starting with 'السياق:' or 'مقتطف'; NEVER include them inside the table or as headers.\n"
        " The second row of the table MUST be the standard separator: |---|---|---|---|\n"
        " Do not invent columns. Use the exact columns provided in the context.\n"
        " Do NOT use double pipes (||) or strange symbols. Use a single pipe (|) to separate columns.\n"
        " Always place a blank line before and after the table.\n"
        " Example of correct header format (do NOT copy these column names literally — use the columns present in the context):\n"
        "\n"
        "| حالة المقرر | رقم المقرر | اسم المقرر | الساعات المعتمدة | متطلبات سابقة |\n"
        "|---|---|---|---|\n"
        "\n"
        "═══════════════════════════════════════════════════════════════\n"
        "Level / Term coverage rules:\n"
        "═══════════════════════════════════════════════════════════════\n"
        "• When asked about an entire academic level WITHOUT specifying a term, "
        "search the context for both 'الفصل الأول' (Term 1) and 'الفصل الثاني' "
        "(Term 2) and present BOTH together, each under its own subheading.\n"
        "• When a specific term is requested, use only excerpts whose header "
        "carries the matching 'الفصل: ...' tag.\n"
        "• When a department/track/program is requested, restrict to excerpts "
        "whose breadcrumb contains that department/program.\n\n"
        "═══════════════════════════════════════════════════════════════\n"
        "Table rendering rules:\n"
        "═══════════════════════════════════════════════════════════════\n"
        "• Use a Markdown table ONLY when the retrieved context itself contains tabular data (course tables, admin tables). "
        "For regulatory or procedural questions (counts, dates, percentages, rules), answer in plain prose — never force a table.\n"
        "• Always render academic course tables using formatted Markdown "
        "tables. When listing courses, use this column order: "
        "(Status, Course No., Course Name, Credit Hours, Prerequisites).\n"
        "• Begin every table with a header row (| Col1 | Col2 |) followed by "
        "a separator row (|---|---|), then data rows. Do not use bullet lists "
        "to render a table that exists as a table in the source.\n"
        "• When rendering a level with two terms, use one separate table per "
        "term, each preceded by a '### Term 1' / '### Term 2' subheading.\n"
        "• Never abbreviate or replace rows with '…'; copy every row verbatim.\n\n"
        "═══════════════════════════════════════════════════════════════\n"
        "Strict rules:\n"
        "═══════════════════════════════════════════════════════════════\n"
        "1. Answer ONLY using information in the context. Never invent courses, "
        "departments, numbers, or prerequisites.\n"
        "2. For numbers / fees / dates / course codes (e.g. GEOP 416): copy "
        "the exact figure verbatim.\n"
        "3. For lists / courses / requirements: list ALL items, numbered, no summarizing.\n"
        "4. End every answer with a citation in this exact form "
        "(if the answer is the 'not found' refusal, omit the source line entirely):\n"
        "   - If the excerpt header carries a 'مادة رقم X' tag: "
        "(Source: Article No. X — <breadcrumb>).\n"
        "   - Else: (Source: <breadcrumb as shown in the header>).\n"
        "   - When merging multiple excerpts, list all sources, comma-separated.\n"
        "5. Never copy an article number from the answer body; take it ONLY "
        "from the 'مادة رقم X' tag in the excerpt header (prevents confusion "
        "with other numbers inside the text).\n"
        "6. If nothing relevant exists, say verbatim: 'I could not find this "
        "in the available student guide. Please contact the Student Affairs office.'\n"
        "7. If the context contains only partial information, state ONLY what "
        "is present and explicitly say the rest is not available. NEVER complete "
        "missing information from your own knowledge.\n"
        "8. Do NOT guess, infer, or provide general knowledge. If the context "
        "does not mention a specific number, percentage, or condition, say "
        "'I could not find this information'.\n"
        "9. Answer in English. Begin directly with the requested content (no "
        "'Sure' / 'Of course' preambles), and end with the source line.\n"
        "10. If the question is entirely unrelated to Ain Shams University Faculty of Science "
        "(e.g. restaurants, weapons, sports, general knowledge), respond ONLY with the exact phrase: "
        "'I could not find this in the available student guide. Please contact the Student Affairs office.' "
        "Do not provide general knowledge answers."
    )


# ── Streaming with async keepalive ─────────────────────────────────────────────

async def stream_ollama_and_save(messages: list[dict], session_id: str, question: str):
    """
    Stream tokens from Ollama and persist the exchange to memory.

    Architecture: a background asyncio Task reads from Ollama and enqueues
    tokens.  The generator loop dequeues with a _KEEPALIVE_INTERVAL timeout;
    if no token arrives in that window it yields a zero-width space (​)
    to keep the browser/proxy SSE connection alive during long CPU inference.

    Timeout strategy: _OLLAMA_TIMEOUT = httpx.Timeout(None) disables all
    httpx-level timeouts.  This prevents ConnectionError on 200s+ queries
    that the old timeout=300.0 couldn't handle.

    Completion tracking: if the client disconnects mid-stream, the finally
    block appends ' [...]' to the partial answer before saving to memory so
    the LLM knows the previous turn was cut off.
    """
    full_answer      = ""
    stream_completed = False
    print(f"[THINK] session={session_id}")

    token_queue: asyncio.Queue = asyncio.Queue()

    async def _ollama_reader():
        nonlocal stream_completed
        try:
            async with httpx.AsyncClient(timeout=_OLLAMA_TIMEOUT) as client:
                async with client.stream(
                    "POST",
                    OLLAMA_URL,
                    json={
                        "model":    OLLAMA_MODEL,
                        "messages": messages,
                        "stream":   True,
                        "keep_alive": -1,
                        "options": {
                            "temperature": 0.1,
                            "top_p":       0.7,
                            "num_ctx":     8192,
                            "num_predict": 2048,
                        },
                    },
                ) as response:
                    if response.status_code != 200:
                        error_body = await response.aread()
                        print(f"[ERROR] Ollama HTTP {response.status_code}: {error_body[:200]}")
                        await token_queue.put(("error", f"\n[ERROR|{response.status_code}]"))
                        return

                    async for line in response.aiter_lines():
                        if not line:
                            continue
                        try:
                            chunk = json.loads(line)
                        except json.JSONDecodeError:
                            print(f"[WARN] Malformed Ollama chunk: {line[:120]}")
                            continue

                        if "message" in chunk and "content" in chunk["message"]:
                            content = chunk["message"]["content"]
                            await token_queue.put(("token", content))

                        if chunk.get("done"):
                            stream_completed = True
                            break

        except httpx.RemoteProtocolError as e:
            print(f"[WARN] Stream interrupted: {e}")
            await token_queue.put(("error", "\n[ERROR|STREAM_INTERRUPTED]"))
        except Exception as e:
            print(f"[ERROR] Ollama connection error: {e}")
            await token_queue.put(("error", "\n[ERROR|CONNECTION]"))
        finally:
            await token_queue.put(("done", None))

    reader_task = asyncio.create_task(_ollama_reader())

    try:
        while True:
            try:
                msg_type, content = await asyncio.wait_for(
                    token_queue.get(), timeout=_KEEPALIVE_INTERVAL
                )
            except asyncio.TimeoutError:
                # No token for _KEEPALIVE_INTERVAL seconds — send invisible heartbeat
                yield "​"
                continue

            if msg_type == "done":
                break
            if msg_type == "error":
                yield content
                break

            # msg_type == "token"
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
            memory.add(session_id, "user", question)
            memory.add(session_id, "assistant", saved)


# ── Query Rewriting ────────────────────────────────────────────────────────────

def is_followup_question(question: str) -> bool:
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


async def rewrite_query_with_ollama(question: str, history: list[dict]) -> str:
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
                OLLAMA_URL,
                json={
                    "model":    OLLAMA_MODEL,
                    "messages": [{"role": "user", "content": rewrite_prompt}],
                    "stream":   False,
                },
            )
            if response.status_code == 200:
                rewritten = response.json()["message"]["content"].strip()
                print(f"[REWRITE] {rewritten}")
                return rewritten
    except Exception as e:
        print(f"[WARN] Rewrite failed: {e}")

    return question


# ── Internal helpers ──────────────────────────────────────────────────────────

def _refresh_retriever():
    with _retriever_lock:
        # Invalidate stale BM25 cache BEFORE resetting the singleton so the
        # next get_retriever() call always rebuilds from fresh collection data.
        try:
            old = get_retriever.__wrapped__ if hasattr(get_retriever, "__wrapped__") else None
            from retriever import BM25_CACHE_PATH
            BM25_CACHE_PATH.unlink(missing_ok=True)
        except Exception:
            pass
        reset_retriever()
        get_retriever()


# ── Endpoints ──────────────────────────────────────────────────────────────────

@app.get("/")
async def root():
    return {"status": "ok", "message": "ASU RAG Chatbot API"}


@app.post("/chat")
async def chat(req: ChatRequest):
    question = req.question.strip()
    if not question:
        raise HTTPException(status_code=400, detail="Question cannot be empty")

    start_time = time.time()
    session_id = req.session_id or str(uuid.uuid4())
    lang       = detect_language(question)
    history    = memory.get_history(session_id)

    search_query = question
    if history and is_followup_question(question):
        search_query = await rewrite_query_with_ollama(question, history)

    retriever = get_retriever()
    chunks    = retriever.search(search_query, top_k=TOP_K)

    def _format_chunk(i: int, c: dict) -> str:
        meta       = c.get("metadata", {})
        article    = meta.get("article_number", "")
        breadcrumb = (
            meta.get("breadcrumb", "")
            or meta.get("section", "")
            or meta.get("chapter_title", "")
        )
        ctype      = meta.get("chunk_type", "")
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
        if ctype == "table":
            tags.append("جدول")
        tag_str = " — " + " — ".join(tags) if tags else ""

        return f"[مقتطف {i+1}{tag_str}]\n{c['text']}"

    if chunks:
        # Build context by adding chunks in rank order, stopping before
        # exceeding MAX_CONTEXT_CHARS.  This avoids cutting a chunk mid-table.
        formatted_chunks = [_format_chunk(i, c) for i, c in enumerate(chunks)]
        separator = "\n\n---\n\n"
        included = []
        total_len = 0
        for fc in formatted_chunks:
            added_len = len(fc) + (len(separator) if included else 0)
            if total_len + added_len > MAX_CONTEXT_CHARS and included:
                break
            included.append(fc)
            total_len += added_len
        context_text = separator.join(included)
    else:
        context_text = ""

    sources = list({c["source"] for c in chunks})

    system_prompt = build_system_prompt(lang)
    messages = [
        {"role": "system", "content": f"{system_prompt}\n\nContext:\n{context_text}"},
        *history,
        {"role": "user", "content": question},
    ]

    prep_time = round(time.time() - start_time, 2)
    print(f"[TIMER] Prep: {prep_time}s | chunks={len(chunks)}")

    async def timed_stream():
        gen_start = time.time()
        async for token in stream_ollama_and_save(messages, session_id, question):
            yield token
        total = round(time.time() - start_time, 2)
        gen   = round(time.time() - gen_start, 2)
        print(f"[TIMER] Total: {total}s (prep={prep_time}s, gen={gen}s)")

    return StreamingResponse(
        timed_stream(),
        media_type="text/event-stream",
        headers={
            "X-Session-ID":    session_id,
            "X-Sources":       json.dumps(sources),
            "X-Response-Time": str(prep_time),
        },
    )


@app.post("/retrieve")
async def retrieve(req: RetrieveRequest):
    retriever = get_retriever()
    k      = req.top_k if req.top_k is not None else TOP_K
    chunks = retriever.search(req.question, top_k=k)
    return {"chunks": chunks}


@app.post("/ingest", response_model=IngestResponse)
async def ingest_pdf(file: UploadFile = File(...)):
    if not file.filename.endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files are supported")

    # Sanitize: strip any path components (prevent path traversal attacks)
    safe_filename = Path(file.filename).name
    save_path = PDF_UPLOAD_DIR / safe_filename
    content   = await file.read()
    with open(save_path, "wb") as f:
        f.write(content)

    try:
        from ingest import ingest
        result = ingest(str(save_path))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ingestion failed: {e}")

    try:
        old_retriever = get_retriever()
        old_retriever.invalidate_bm25_cache()
    except Exception:
        pass
    _refresh_retriever()

    return IngestResponse(
        status="ok",
        chunks_added=result.get("chunks_added", 0),
        message=f"Successfully indexed {result.get('chunks_added', 0)} chunks.",
    )


@app.get("/health")
async def health():
    retriever = get_retriever()

    ollama_ok = False
    try:
        async with httpx.AsyncClient(timeout=httpx.Timeout(5.0)) as client:
            r = await client.get(f"{_OLLAMA_BASE_URL}/api/tags")
            ollama_ok = r.status_code == 200
    except (httpx.HTTPError, OSError):
        pass

    return {
        "status":           "ok" if ollama_ok else "error",
        "ollama_connected": ollama_ok,
        "model":            OLLAMA_MODEL,
        "chunks_indexed":   retriever.collection.count(),
        "sessions_active":  memory.session_count,
    }


@app.delete("/session/{session_id}")
def clear_session(session_id: str):
    memory.clear(session_id)
    return {"status": "cleared", "session_id": session_id}
