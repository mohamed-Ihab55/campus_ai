# Fix Checklist — Priority Order

## Run summary: 161/166 PASS (97.0%)

## [CRITICAL] WRONG_PROGRAM cases — vectorstore not rebuilt
- [ ] Confirm new ingest_markdown.py is in place (has program_name metadata)
- [ ] Run: rm -rf vectorstore/ && python ingest_markdown.py
- [ ] Confirm retriever.py has _boost_matches() function
- [ ] Affects: 1 cases

## [HIGH] PARTIAL cases — edge rows cut at chunk boundary
- [ ] Confirm CHUNK_SIZE=1600 in ingest_markdown.py
- [ ] Confirm vectorstore rebuilt after CHUNK_SIZE change
- [ ] If still failing: increase CHUNK_SIZE to 1800 for affected tables
- [ ] Affects: 4 cases

