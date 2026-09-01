> **Doc:** PROMPT_SCOPE.md
> **Updated:** 2026-09-01 10:20 IST
> **Session:** Doc header sync; UI updates next

# PROMPT SCOPE — CTS

## Attach order (LOCKED — same as PROJECT_BRAIN §3)

**Every chat:**
```
@PROJECT_BRAIN.md
@PROMPT_SCOPE.md
```

**Client pack / STEP 8 (append — do not reshuffle):**
```
@docs/client_req/DISCUSSION_LOG.md
@docs/client_req/07-NEXT-AGENT-PROMPT.md
@lib/features/d2d/README.md
@docs/API_CONTRACTS.md
@docs/TESTING.md
@docs/LOCAL_DEV.md
```

Add for journeys/QA: `@docs/FLOWS_BY_ROLE.md`  
Optional: `@docs/client_req/05-open-decisions.md` · `@docs/client_req/README.md`

| File | Owns |
|------|------|
| [PROJECT_BRAIN.md](PROJECT_BRAIN.md) | Product + devices + §5/§9 + BE↔FE §10 |
| [PROJECT_TODOS.md](PROJECT_TODOS.md) | Long-lived backlog |
| **This file** | Prompt gate, ordered queue, change log |

**Story split:** 05 = product story/locks · FLOWS = click-paths · 07 = smoke · DISCUSSION_LOG = pointer only.

---

## 1. Prompt check

| # | Check | Pass? | Note |
|---|--------|-------|------|
| P1 | Goal clear? | yes | Phase 3 complete; session closed |
| P2 | Role / surface? | yes | Extend return_batch + batches UI; mirror morning Phase 2 |
| P3 | Non-negotiables? | yes | No new REST unless needed; Provider; locked Q1–Q4 product |
| P4 | Both ends? | yes | `cts-docker` return pool + `cts_beta` return screens |
| P5 | R10 isComing? | yes | Return confirm ≠ isComing; End clears via trip_end scope |
| P6 | Git branch? | yes | beta-ver; no commit unless asked |
| P7 | Docs policy? | yes | Update API_CONTRACTS + batches README; handoff in D2D_PHASE3_CONTINUE_PROMPT |
| P8 | Out of scope? | yes | Do not redo morning Phase 1+2; STEP 8 only on **go** |

**This prompt:** Phase 3 — return trip waiting + FCFS → [docs/D2D_PHASE3_CONTINUE_PROMPT.txt](docs/D2D_PHASE3_CONTINUE_PROMPT.txt).

---

## 2. Ordered work queue

| Order | ID | Item | Status | Owner |
|------:|----|------|--------|-------|
| 1 | Q-client-qr-odo | Client pack STEP 8 device smoke | **next** (on **go**) | [07](docs/client_req/07-NEXT-AGENT-PROMPT.md) · [LAB_SMOKE_ISSUES](docs/LAB_SMOKE_ISSUES.txt) |
| 2 | Q-client-tests | New tests under `test/features/d2d/` | open | TESTING |
| 3 | Q-26d | Confirm “API every time” discuss | pending | return add UI |
| 4 | Q-batch-coming | Mark all coming **per batch** | future | `CommuterListScreen` |
| 5 | Q-r7-tests | Django lazy cutoff + Flutter `cutoff_applied` | future | BE tests |
| — | Q-d2d-phase3 | Return waiting pool + FCFS parity | **done** | batches README + API_CONTRACTS |
| — | Q-d2d-phase1-2 | Morning cross-batch + waiting + FCFS | **done** | d2d README + API_CONTRACTS |
| — | Q-docs-consol / story-split / nginx / backup | shipped | **done** | — |

---

## 3. Future scope (parked)

| Idea | Notes |
|------|-------|
| Return-leg KM / org odometer / unboard UI | After STEP 8 |
| Batch-wise Mark all coming | Org-wide already shipped |
| Wire CList into return pool (R2/R9) | Roadmap ahead of code |
| Healthchecks / TLS / CI | Lab-only for now |

---

## 4. Change log

| When (IST) | Change | Repos |
|------------|--------|-------|
| 2026-09-01 10:20 | Doc header sync — API_CONTRACTS view/ waiting[] example; feature READMEs; FLOWS; PROJECT_TODOS 128 tests | `cts_beta` |
| 2026-08-31 13:45 | D2D Phase 3 shipped — return waiting Redis + join_waiting + FCFS + FE waiting UI | both |
| 2026-08-31 13:20 | D2D Phase 1+2 shipped (morning); Phase 3 handoff prompt + brain/scope/registry sync | both |
| 2026-08-29 13:25 | STEP 8 resume go — fix ISSUE-008 (driver adminCode); finish M6/M7|R5 + return R1–R8 | both |
| 2026-08-29 10:27 | END sync: PROJECT_BRAIN §5/§6/§9; DOC_REGISTRY fast+on-change; CHAT_PROMPTS; DISCUSSION_LOG pointer | `cts_beta` |
| 2026-08-29 10:02 | LIB_STRUCTURE.md: target tree aligned to disk; Phase B done; legacy root folders documented | `cts_beta` |
| 2026-08-29 10:16 | reviewer_agent.md: role card — LIB_STRUCTURE law; no Riverpod; no data/domain/presentation | `cts_beta` |
| 2026-08-29 10:10 | test_agent.md: role card — TESTING.md owner; test/features/<name>/; unit tests ≠ push gate | `cts_beta` |
| 2026-08-29 10:06 | ui_agent.md: role card — PROJECT_BRAIN first; features/screens + lib/widgets; Material only; no presentation/ | `cts_beta` |
| 2026-08-29 10:03 | main_agent.md: orchestrator role card — PROJECT_BRAIN/.cursorrules first; attach §3; END sync; Provider only | `cts_beta` |
| 2026-08-29 10:03 | ARCHITECTURE.md: layer mermaid → Screen/Provider/Repository/API; flow ≠ folders; legacy lib/data|domain loud; Provider only | `cts_beta` |
| 2026-08-29 09:35 | logic_agent.md: full replace — Provider (ChangeNotifier) only; never Riverpod; module paths locked | `cts_beta` |
| 2026-08-26 08:50 | migrate-widgets + migrate-features done; analyze 0 errors; 128 tests pass | `cts_beta` |
| 2026-08-26 08:40 | Features/offline: fix Theme migration scope/const; 0 analyze errors | `cts_beta` |
| 2026-08-26 08:35 | Widgets + appManager off AppColors → Theme (scheme/cts) | `cts_beta` |
| 2026-08-26 08:35 | Theme migration: UI off AppColors → ColorScheme + CtsColors extension | `cts_beta` |
| 2026-08-26 08:26 | Hold firebase_messaging as-is (planned FCM later; no remove/bump) | `cts_beta` |
| 2026-08-26 08:15 | Phase C: permission_handler 13, go_router 18, dropdown_search 7 (+ widget API adapt) | `cts_beta` |
| 2026-08-26 08:05 | Phase B: dotenv 6, shimmer 4, easyloading 4; 128 tests pass | `cts_beta` |
| 2026-08-26 07:57 | Phase A: `flutter pub upgrade` (31 patches); analyze OK (pre-existing infos); 128 tests pass | `cts_beta` |
| 2026-08-26 07:52 | Dep coupling map before upgrades (clusters + dry-run) | `cts_beta` |
| 2026-08-26 07:46 | Checked `flutter pub outdated` (report only; no bumps) | `cts_beta` |
| 2026-08-25 22:15 | Session rest — docs complete; no further churn | `cts_beta` |
| 2026-08-25 22:05 | FLOWS QR/KM+smoke; 05 product story; DISCUSSION_LOG pointer-only | `cts_beta` |
| 2026-08-25 21:50 | Stability lock + BE↔FE §10 | both docs |
| 2026-08-25 21:45 | Fast-path + delete widget_test | `cts_beta` |
| 2026-08-25 21:40 | Docs consol 01–04 + guides | `cts_beta` |

---

## 5. Agent sync rules

**START:** attach locked list; fill §1; align §2.  
**During:** update §2–§4 async.  
**END:** brain / registry / todos; if Q-client is #1 → **always** bump DISCUSSION_LOG pointer.  
**STEP 8:** only on user **go**.  
**Do not** invent a new attach order; **do not** put product rules in DISCUSSION_LOG.
