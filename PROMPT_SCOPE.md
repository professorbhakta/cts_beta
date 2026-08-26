> **Doc:** PROMPT_SCOPE.md
> **Updated:** 2026-08-26 08:40 IST
> **Session:** AppColors → Theme (features fixup)

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
| P1 | Goal clear? | yes | migrate-widgets + migrate-features: AppColors → Theme/CtsColors |
| P2 | Role / surface? | yes | Shared widgets, snackbar/tools, all feature screens |
| P3 | Non-negotiables? | yes | AppColors seed only in theme; analyze + test |
| P4 | Both ends? | n/a | |
| P5 | R10 isComing? | n/a | |
| P6 | Git branch? | yes | No commit unless asked |
| P7 | Docs policy? | yes | No new md; update PROMPT_SCOPE |
| P8 | Out of scope? | yes | Keep AppColors file; no redesign; no google_fonts bump |

**This prompt:** Theme token migration (widgets + features).

---

## 2. Ordered work queue

| Order | ID | Item | Status | Owner |
|------:|----|------|--------|-------|
| 1 | Q-client-qr-odo | Client pack STEP 8 device smoke | **await go** | [07](docs/client_req/07-NEXT-AGENT-PROMPT.md) · [FLOWS](docs/FLOWS_BY_ROLE.md) |
| 2 | Q-client-tests | New tests under `test/features/d2d/` | open | TESTING |
| 3 | Q-26d | Confirm “API every time” discuss | pending | return add UI |
| 4 | Q-batch-coming | Mark all coming **per batch** | future | `CommuterListScreen` |
| 5 | Q-r7-tests | Django lazy cutoff + Flutter `cutoff_applied` | future | BE tests |
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
