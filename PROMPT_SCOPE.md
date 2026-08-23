> **Doc:** PROMPT_SCOPE.md
> **Updated:** 2026-08-23 23:20 IST
> **Session:** Wrap-up — Mark all, R7, C1 done; next 26d-discuss

# PROMPT SCOPE — CTS

Attach **every chat** with the brain:

```
@PROJECT_BRAIN.md
@PROMPT_SCOPE.md
```

**Role split**
| File | Owns |
|------|------|
| [PROJECT_BRAIN.md](PROJECT_BRAIN.md) | What the product is, non-negotiables, session handoff (§5 / §9) |
| [PROJECT_TODOS.md](PROJECT_TODOS.md) | Long-lived backlog checkboxes |
| **This file** | Prompt gate, ordered work queue, future scope, session change log |

Keep this file short. Agents **update it async** during the chat (not only at END).

---

## 1. Prompt check (run before coding)

| # | Check | Pass? | Note |
|---|--------|-------|------|
| P1 | Goal clear? | yes | Session wrap + doc sync |
| P2 | Role / surface? | yes | Docs |
| P3 | Non-negotiables? | yes | |
| P4 | Both ends? | n/a | Doc only |
| P5 | R10 isComing? | yes | |
| P6 | Git branch? | yes | Uncommitted until user asks |
| P7 | Docs policy? | yes | Existing owners only |
| P8 | Out of scope? | yes | No new features this wrap |

**This prompt:** End-of-session sync. Next chat starts at **Q-26d**.

---

## 2. Ordered work queue (async)

| Order | ID | Item | Status | Owner file / API |
|------:|----|------|--------|------------------|
| 1 | Q-26d | Confirm “API every time” discuss (then fix or skip) | **pending** | Confirm UI / return add |
| 2 | Q-batch-coming | Admin Mark all coming **per batch** | future | nested `CommuterListScreen` |
| 3 | Q-r7-tests | Django live lazy cutoff + Flutter `cutoff_applied` tests | future | `d2d_log/tests.py` |
| 4 | Q-26d-chip | Optional Commuter “Return today” chip smoke | optional | Commuter home |
| — | Q-C1 | TIME_ZONE Asia/Kolkata for R7 T−15 | **done** | `c2s/settings.py` |
| — | Q-R7 | Cutoff T−15 lazy + `cutoff_applied` | **done** | return_allocator / return_pool |
| — | Q-mark-all | Org Mark all coming | **done** | admin PATCH + CommuterScreen |

---

## 3. Future scope (parked)

| Idea | Why | Notes |
|------|-----|-------|
| Batch-wise Mark all coming | One morning batch ON | Org-wide already shipped |
| Reset-all `isComing=false` | Pair to Mark all true | Not requested |
| Wire CList into return pool (R2/R9) | Eligibility = morning STOP | Roadmap still reads ahead of code |
| Driver “start boarding” early cutoff | Alternate D3 | T−15 locked for v1 |
| Fail-closed `validate_add_commuter` on compute errors | Hardening | Pre-existing fail-open |
| Optional `DJANGO_TIME_ZONE` in live `.env` | Explicit override | Default already Asia/Kolkata |

---

## 4. Change / modification log (session)

| When (IST) | Change | Repos |
|------------|--------|-------|
| 2026-08-23 23:20 | **C1** `TIME_ZONE` default `Asia/Kolkata` (+ `DJANGO_TIME_ZONE` env); TZ tests 20/20 + 2/2 | `cts-docker` |
| 2026-08-23 23:10 | **R7** T−15 cutoff + Flutter “Holds released” | both |
| 2026-08-23 22:45 | **PROMPT_SCOPE** created + wired | `cts_beta` |
| 2026-08-23 22:30 | Admin org **Mark all coming** | both |

---

## 5. Agent sync rules

**On START:** attach brain + this file; fill §1; align §2.  
**During chat:** update §2–§4 async.  
**On END:** sync brain / registry / todos.
