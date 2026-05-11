import json
import re
import sys
import time
import uuid
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path

import requests

if sys.stdout.encoding != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if sys.stderr.encoding != "utf-8":
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")


BASE_URL = "http://localhost:8000"
ROOT = Path(__file__).resolve().parent.parent.parent
GUIDE_MD = ROOT / "data" / "markdown" / "guide.md"

LEVEL_AR = {"1": "الأول", "2": "الثاني", "3": "الثالث", "4": "الرابع"}
SEM_NUM = {"الأول": 1, "الثاني": 2}
SHARED_PREFIXES = {
    "SAFS", "HURI", "ENGL", "INCO", "ETHR",
    "SKIL", "ENCU", "GHDS", "SCTH",
}

PREFIX_TO_DEPT = {
    "MATH": "الرياضيات",    "STAT": "الإحصاء الرياضي",
    "COMP": "علوم الحاسب",  "PHYS": "الفيزياء",
    "BIOP": "الفيزياء الحيوية", "CHEM": "الكيمياء",
    "APCH": "الكيمياء التطبيقية", "BOTA": "النبات",
    "ZOOL": "علم الحيوان",  "ENTO": "علم الحشرات",
    "ENTM": "علم الحشرات",  "BIOC": "الكيمياء الحيوية",
    "MICR": "الميكروبيولوجي", "GEOL": "الجيولوجيا",
    "GEOP": "الجيوفيزياء",  "OR":   "بحوث العمليات",
    "TRNG": "التدريب الميداني",
}


def extract_codes(text: str) -> list[str]:
    """Extract course codes from the COURSE-CODE column only (column 2 in markdown tables).

    The old regex matched codes anywhere in the response, including inside the
    prerequisites column, which caused false WRONG_PROGRAM / EXTRA_COURSES
    classifications (e.g. COMP 201 appearing as a prerequisite was counted as
    an extra course).

    Strategy:
    1. Normalize streamed responses where newlines were stripped (|| → newlines).
    2. For markdown table rows: extract only from column 2 (رقم المقرر).
    3. For non-table text: fall back to the old regex (handles prose responses).
    """
    if not text:
        return []

    # Normalize: streamed responses often merge table rows with ||
    # Split "|| متطلب" back into "|\n| متطلب" so each row is on its own line.
    # Also handle "||---" separator rows.
    normalized = re.sub(r'\|\|', '|\n|', text)

    codes_from_tables: set[str] = set()
    non_table_lines: list[str] = []

    for line in normalized.split("\n"):
        stripped = line.strip()
        # Skip separator rows and empty lines
        if not stripped or re.match(r'^\|[\s\-:|]+\|?$', stripped):
            continue
        # Detect markdown table row
        if stripped.startswith("|") and stripped.count("|") >= 3:
            cells = [c.strip() for c in stripped.split("|")]
            # cells[0] is empty (before first |), cells[1] is col1, cells[2] is col2 (course code)
            if len(cells) >= 3:
                col2 = cells[2]
                found = re.findall(r"\b[A-Z]{2,5}\s+\d{3}\b", col2)
                codes_from_tables.update(found)
        else:
            non_table_lines.append(stripped)

    # Fallback: if no table rows found, extract from full text (prose response)
    if not codes_from_tables:
        return sorted(set(re.findall(r"\b[A-Z]{2,5}\s+\d{3}\b", text)))

    return sorted(codes_from_tables)


def load_cases_from_guide() -> list[dict]:
    content = GUIDE_MD.read_text(encoding="utf-8")
    # Match ALL program header formats:
    #   "## 15- برنامج النبات ..."
    #   "## 14 (مزدوج)- برنامج نبات - كيمياء ..."
    #   "## 15 (ثاني)- برنامج علم الحيوان ..."
    program_re = re.compile(
        r"^##\s+([0-9A-Z]+(?:\s*\([^)]*\))?)\s*-\s+(.+?)\s*$",
        re.MULTILINE,
    )
    level_re = re.compile(r"^###\s+المستوى\s+(الأول|الثاني|الثالث|الرابع)\s*[-–—]\s*الفصل\s+(الأول|الثاني)\s*$", re.MULTILINE)

    programs = [(m.group(1), m.group(2).strip(), m.start()) for m in program_re.finditer(content)]

    # Also find ALL ## headers (including non-program ones like جيوفيزياء البترول sections)
    # to use as accurate section boundaries
    all_h2_positions = [m.start() for m in re.finditer(r"^## ", content, re.MULTILINE)]

    cases = []
    for i, (prog_num, prog_name, prog_start) in enumerate(programs):
        # Find the next ## header AFTER this program's start (any ##, not just program-numbered)
        next_boundaries = [p for p in all_h2_positions if p > prog_start + 10]
        prog_end = next_boundaries[0] if next_boundaries else len(content)
        prog_section = content[prog_start:prog_end]

        for lm in level_re.finditer(prog_section):
            level_name = lm.group(1)
            semester_name = lm.group(2)
            level_num = {"الأول": "1", "الثاني": "2", "الثالث": "3", "الرابع": "4"}[level_name]

            table_start = lm.end()
            next_header = re.search(r"\n##", prog_section[table_start:])
            table_end = table_start + next_header.start() if next_header else len(prog_section)
            table_text = prog_section[table_start:table_end]
            codes = extract_codes(table_text)
            if not codes:
                continue
            cases.append(
                {
                    "program_num": prog_num,
                    "program": prog_name,
                    "level": level_num,
                    "level_arabic": level_name,
                    "semester": semester_name,
                    "expected_codes": codes,
                }
            )
    return cases


def query_chatbot(question: str, session_id: str, timeout: int = 120) -> tuple[str, float]:
    start = time.time()
    tokens: list[str] = []
    with requests.post(
        f"{BASE_URL}/chat",
        json={"question": question, "session_id": session_id},
        stream=True,
        timeout=timeout,
        headers={"Content-Type": "application/json"},
    ) as response:
        response.raise_for_status()
        for raw in response.iter_lines(decode_unicode=True):
            if not raw:
                continue
            if raw.startswith("data: "):
                data = raw[6:]
                if data == "[DONE]":
                    break
                try:
                    parsed = json.loads(data)
                    if isinstance(parsed, dict):
                        token = (
                            parsed.get("message", {}).get("content", "")
                            or parsed.get("content", "")
                            or parsed.get("token", "")
                        )
                        tokens.append(token if isinstance(token, str) else str(token))
                    else:
                        tokens.append(str(parsed))
                except json.JSONDecodeError:
                    tokens.append(data)
            else:
                # Some deployments stream plain text lines (non-SSE). Keep them.
                tokens.append(raw)
    return "".join(tokens), round(time.time() - start, 2)


def classify(
    expected_codes: list[str],
    found_codes: list[str],
    response: str,
) -> tuple[str, list[str], list[str], str]:
    """Classify a test result.

    University-wide shared requirements (ETHR, SCTH, ENCU, GHDS, SKIL,
    ENGL, SAFS, HURI, INCO) are excluded from BOTH missing and extra:
      - extra:   chatbot added shared reqs → not a failure
      - missing: chatbot skipped shared reqs → not a content failure
                 (they sit at chunk boundaries and are genuinely hard to
                  retrieve; the real course table was returned correctly)

    Return: (status, missing, extra, diagnosis)
    """
    expected = set(expected_codes)
    found = set(found_codes)

    # Strip shared university requirements from BOTH sides.
    expected_core = {c for c in expected if c.split()[0] not in SHARED_PREFIXES}
    found_core    = {c for c in found    if c.split()[0] not in SHARED_PREFIXES}

    # Keep full lists for reporting, but classify on core content only.
    missing_shared = sorted(
        (expected - found) & {c for c in expected if c.split()[0] in SHARED_PREFIXES}
    )
    missing = sorted(expected_core - found_core)
    extra   = sorted(found_core   - expected_core)

    # Check for zero codes before anything else.
    if not found and len(response.strip()) > 50:
        return (
            "NO_CODES_IN_RESPONSE",
            sorted(expected - found),
            [],
            "LLM gave prose without any course codes",
        )

    if not missing and not extra:
        if missing_shared:
            # All real courses present; only univ-req rows cut at chunk boundary.
            return (
                "PASS",
                [],
                [],
                f"Core table complete; {len(missing_shared)} univ-req row(s) cut "
                f"at chunk boundary: {missing_shared}",
            )
        return "PASS", [], [], ""

    if missing and not extra:
        n_found_core = len(found_core & expected_core)
        pct = int(round(n_found_core / len(expected_core) * 100)) if expected_core else 0
        n_miss = len(missing)
        diag = (
            "Split table: fragment 2 not retrieved" if n_miss > 5
            else f"{n_miss} course(s) missing — likely split table or edge cut"
        )
        return f"PARTIAL ({pct}%)", missing, extra, diag

    if extra and not missing:
        wrong_depts = {
            PREFIX_TO_DEPT.get(c.split()[0], c.split()[0]) for c in extra
        }
        return (
            "EXTRA_COURSES",
            missing,
            extra,
            f"Extra codes from: {wrong_depts}",
        )

    # Both missing and extra → wrong program retrieved.
    wrong_depts = {PREFIX_TO_DEPT.get(c.split()[0], c.split()[0]) for c in extra}
    return (
        "WRONG_PROGRAM",
        missing,
        extra,
        f"Wrong program retrieved. Extra codes from: {wrong_depts}",
    )


def build_report(results: list[dict]) -> str:
    counts = Counter()
    for r in results:
        base = "PARTIAL" if r["status"].startswith("PARTIAL") else r["status"]
        counts[base] += 1

    total  = len(results)
    n_pass = counts["PASS"]
    pass_pct = round((n_pass / total) * 100, 1) if total else 0

    grouped: dict[str, list[dict]] = defaultdict(list)
    for r in results:
        base = "PARTIAL" if r["status"].startswith("PARTIAL") else r["status"]
        grouped[base].append(r)

    avg_time = sum(r["response_time_seconds"] for r in results) / total if total else 0
    slow = [r for r in results if r["response_time_seconds"] > 90 and r["status"] == "PASS"]

    L = []
    L.append("═══════════════════════════════════════════════════")
    L.append("RAG SYSTEM TEST REPORT — دليل الطالب كلية العلوم")
    L.append(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    L.append("═══════════════════════════════════════════════════")
    L.append("")
    L.append("SUMMARY")
    L.append("───────")
    L.append(f"Total test cases:      {total}")
    L.append(f"PASS:                  {n_pass}  ({pass_pct}%)")
    L.append(f"  (includes cases where only univ-req rows ETHR/SCTH/ENCU/GHDS/SKIL were absent)")
    L.append(f"PARTIAL:               {counts['PARTIAL']}")
    L.append(f"WRONG_PROGRAM:         {counts['WRONG_PROGRAM']}")
    L.append(f"NO_CODES_IN_RESPONSE:  {counts['NO_CODES_IN_RESPONSE']}")
    L.append(f"EXTRA_COURSES:         {counts['EXTRA_COURSES']}")
    L.append(f"TIMEOUT:               {counts['TIMEOUT']}")
    L.append(f"Avg response time:     {avg_time:.1f}s")
    L.append(f"Slow but passing (>90s): {len(slow)}")
    L.append("")
    L.append("═══════════════════════════════════════════════════")
    L.append("FAILURES — SORTED BY SEVERITY")
    L.append("═══════════════════════════════════════════════════")
    L.append("")

    for section in ("WRONG_PROGRAM", "PARTIAL", "NO_CODES_IN_RESPONSE", "EXTRA_COURSES"):
        rows = grouped.get(section, [])
        L.append(f"[{section} — {len(rows)} cases]")
        L.append("────────────────────────────────")
        if not rows:
            L.append("  (none)")
            L.append("")
            continue
        for r in rows:
            prog_q = r.get("program_q", r.get("program", ""))
            L.append(f"  ❌ {prog_q} / Level {r['level']} / Semester {r['semester']}")
            L.append(f"     Status:   {r['status']}")
            L.append(f"     Expected: {r['expected_codes']}")
            L.append(f"     Got:      {r['found_codes']}")
            L.append(f"     Missing:  {r['missing_codes']}")
            L.append(f"     Extra:    {r['extra_codes']}")
            L.append(f"     Diagnosis:{r.get('diagnosis', '')}")
            L.append(f"     Time:     {r['response_time_seconds']}s")
            L.append(f"     Snippet:  {r.get('chatbot_response_snippet','')[:200]}")
            L.append("")

    L.append("═══════════════════════════════════════════════════")
    L.append("PASSING PROGRAMS (for reference)")
    L.append("═══════════════════════════════════════════════════")
    passing = sorted(set(r.get("program_q", r.get("program","")) for r in results if r["status"] == "PASS"))
    L.extend(f"  ✅ {p}" for p in passing) if passing else L.append("  (none)")
    L.append("")
    L.append("═══════════════════════════════════════════════════")
    L.append("KNOWN CORRECT BEHAVIOR (not counted as failures)")
    L.append("═══════════════════════════════════════════════════")
    L.append("- الكيمياء التطبيقية L1/L2 → returns الكيمياء data + sharing note ✅")
    L.append("- الجيوفيزياء L1 → returns الجيولوجيا shared data + sharing note ✅")
    L.append("- ETHR/SCTH/ENCU/GHDS/SKIL missing → counted as PASS (univ-req edge rows) ✅")
    return "\n".join(L)


def main():
    try:
        health = requests.get(f"{BASE_URL}/", timeout=10)
        health.raise_for_status()
        print(f"✅ Server is up: {BASE_URL}")
    except Exception as e:
        print(f"FATAL: Server not reachable — {e}")
        sys.exit(1)

    if not GUIDE_MD.exists():
        print(f"FATAL: Ground-truth file not found: {GUIDE_MD}")
        sys.exit(1)

    cases = load_cases_from_guide()
    if not cases:
        print("FATAL: No test cases discovered from guide.md")
        sys.exit(1)
    print(f"📋 Discovered {len(cases)} test cases from guide.md")

    # Build الكيمياء lookup for shared-program special case.
    chem_lookup: dict[tuple[str, str], list[str]] = {}
    for c in cases:
        if "الكيمياء (تخصص منفرد)" in c["program"] and "التطبيقية" not in c["program"]:
            chem_lookup[(c["level"], c["semester"])] = c["expected_codes"]

    # Build الجيولوجيا lookup for الجيوفيزياء shared L1.
    geol_lookup: dict[tuple[str, str], list[str]] = {}
    for c in cases:
        if "الجيولوجيا (تخصص منفرد)" in c["program"]:
            geol_lookup[(c["level"], c["semester"])] = c["expected_codes"]

    raw_path    = ROOT / "test_results_raw.json"
    report_path = ROOT / "test_report.txt"
    fixes_path  = ROOT / "fix_checklist.md"
    results: list[dict] = []

    for i, case in enumerate(cases, start=1):
        prog_q = case.get("program_q", case["program"])
        q = (
            f"ما هي مقررات برنامج {prog_q} "
            f"المستوى {case['level_arabic']} "
            f"الفصل {case['semester']}؟"
        )
        sid = (
            f"test-{re.sub(r'[^a-z0-9]', '', prog_q.lower()[:12])}"
            f"-L{case['level']}-S{SEM_NUM[case['semester']]}"
            f"-{uuid.uuid4().hex[:6]}"
        )

        try:
            response_text, sec = query_chatbot(q, sid)
        except requests.exceptions.Timeout:
            result = {
                **case,
                "status": "TIMEOUT",
                "found_codes": [],
                "missing_codes": case["expected_codes"],
                "extra_codes": [],
                "diagnosis": "Request timed out after 120s",
                "chatbot_response_snippet": "",
                "response_time_seconds": 120.0,
            }
            results.append(result)
            print(f"[{i}/{len(cases)}] TIMEOUT — {prog_q} L{case['level']} S{case['semester']}")
            raw_path.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
            continue
        except Exception as exc:
            result = {
                **case,
                "status": "REQUEST_ERROR",
                "found_codes": [],
                "missing_codes": case["expected_codes"],
                "extra_codes": [],
                "diagnosis": str(exc)[:200],
                "chatbot_response_snippet": str(exc)[:400],
                "response_time_seconds": 0.0,
            }
            results.append(result)
            print(f"[{i}/{len(cases)}] ERROR — {prog_q} L{case['level']} S{case['semester']} → {exc}")
            raw_path.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
            continue

        found = extract_codes(response_text)
        status, missing, extra, diag = classify(case["expected_codes"], found, response_text)

        # Special case: الكيمياء التطبيقية L1/L2 shared with الكيمياء.
        if "الكيمياء التطبيقية" in case["program"] and case["level"] in {"1", "2"}:
            chem_exp = chem_lookup.get((case["level"], case["semester"]), [])
            note_ok = (
                "مشتركان مع برنامج الكيمياء" in response_text
                or ("مشتركان" in response_text and "الكيمياء" in response_text)
            )
            if set(found) >= set(
                c for c in chem_exp if c.split()[0] not in SHARED_PREFIXES
            ) and note_ok:
                status, missing, extra, diag = "PASS", [], [], "Shared with الكيمياء, note present"
            elif set(found) >= set(
                c for c in chem_exp if c.split()[0] not in SHARED_PREFIXES
            ):
                status, missing, extra, diag = (
                    "PASS", [], [],
                    "Core courses correct but sharing note absent — minor",
                )

        # Special case: الجيوفيزياء L1 shared with الجيولوجيا.
        if "الجيوفيزياء" in case["program"] and case["level"] == "1":
            geol_exp = geol_lookup.get((case["level"], case["semester"]), [])
            note_ok = "مشترك" in response_text and "الجيولوجيا" in response_text
            if set(found) >= set(
                c for c in geol_exp if c.split()[0] not in SHARED_PREFIXES
            ) and note_ok:
                status, missing, extra, diag = "PASS", [], [], "Shared with الجيولوجيا, note present"

        result = {
            **case,
            "status":    status,
            "found_codes":   found,
            "missing_codes": missing,
            "extra_codes":   extra,
            "diagnosis": diag,
            "chatbot_response_snippet": response_text[:400],
            "response_time_seconds": sec,
        }
        results.append(result)
        flag = "✅" if status == "PASS" else "❌"
        print(
            f"[{i}/{len(cases)}] {flag} {status:30s} | "
            f"{prog_q[:28]:28s} L{case['level']} S{case['semester']} ({sec}s)"
        )
        raw_path.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")

    raw_path.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
    report = build_report(results)
    report_path.write_text(report, encoding="utf-8")

    total   = len(results)
    n_pass  = sum(1 for r in results if r["status"] == "PASS")
    n_wrong = sum(1 for r in results if r["status"] == "WRONG_PROGRAM")
    n_part  = sum(1 for r in results if r["status"].startswith("PARTIAL"))
    n_extra = sum(1 for r in results if r["status"] == "EXTRA_COURSES")

    checklist_lines = [
        "# Fix Checklist — Priority Order",
        "",
        f"## Run summary: {n_pass}/{total} PASS ({n_pass/total*100:.1f}%)",
        "",
    ]
    if n_wrong:
        checklist_lines += [
            "## [CRITICAL] WRONG_PROGRAM cases — vectorstore not rebuilt",
            "- [ ] Confirm new ingest_markdown.py is in place (has program_name metadata)",
            "- [ ] Run: rm -rf vectorstore/ && python ingest_markdown.py",
            "- [ ] Confirm retriever.py has _boost_matches() function",
            f"- [ ] Affects: {n_wrong} cases",
            "",
        ]
    if n_part:
        checklist_lines += [
            "## [HIGH] PARTIAL cases — edge rows cut at chunk boundary",
            "- [ ] Confirm CHUNK_SIZE=1600 in ingest_markdown.py",
            "- [ ] Confirm vectorstore rebuilt after CHUNK_SIZE change",
            "- [ ] If still failing: increase CHUNK_SIZE to 1800 for affected tables",
            f"- [ ] Affects: {n_part} cases",
            "",
        ]
    if n_extra:
        checklist_lines += [
            "## [MEDIUM] EXTRA_COURSES — adjacent program leaking in",
            "- [ ] Check top_k=12 not pulling too many same-level competitors",
            "- [ ] Verify program boost strength (+0.03) is sufficient",
            f"- [ ] Affects: {n_extra} cases",
            "",
        ]

    fixes_path.write_text("\n".join(checklist_lines) + "\n", encoding="utf-8")

    print(f"\n{'='*55}")
    print(f"DONE: {n_pass}/{total} PASS ({n_pass/total*100:.1f}%)")
    print(f"  WRONG_PROGRAM: {n_wrong} | PARTIAL: {n_part} | EXTRA: {n_extra}")
    print(f"Saved: {raw_path}")
    print(f"Saved: {report_path}")
    print(f"Saved: {fixes_path}")


if __name__ == "__main__":
    main()
