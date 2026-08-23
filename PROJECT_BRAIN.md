> **Doc:** PROJECT_BRAIN.md
> **Updated:** 2026-08-23 23:10 IST
> **Session:** R7 T−15 cutoff shipped; 26d-discuss next

# PROJECT_BRAIN — CTS Flutter

Single entry file for every AI + human chat. Keep under ~250 lines; pointers only — no long specs.

---

## 1. What this is (30 sec)

**CTS (Commuter Transport System)** — cross-platform Flutter app (iOS/Android) for **Admin**, **Driver**, and **Commuter** roles. Manages morning D2D live trips (WebSocket), evening return batches (REST), routes, POPs, cabs, drivers, and commuters.

| Repo | Path | Role |
|------|------|------|
| Flutter app | `D:\cts_beta` | Mobile client |
| Backend (Docker) | `D:\cts-docker` | Django REST + WebSocket + Postgres + Redis |

---

## 2. Non-negotiables

- **State:** Provider (not Riverpod)
- **Routing:** go_router with role-protected redirects
- **Layout:** module-based per [docs/LIB_STRUCTURE.md](docs/LIB_STRUCTURE.md) — `screens/`, `providers/`, `models/`, `repositories/` inside each feature
- **No re-export stubs** — one canonical path per file
- **Quality:** `flutter analyze`, `flutter pub get`, `flutter test` after code changes
- **Pre-push device smoke (required):** both lab devices — emulator admin + phone driver — manual login via `flutter run`; see [docs/TESTING.md](docs/TESTING.md) § Pre-push gate. Unit tests alone are not enough before `git push`.
- **End-of-session doc sync** via [CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) + [DOC_REGISTRY.md](DOC_REGISTRY.md)
- **Git:** feature / `beta-ver` only — **do not merge or push to `main`**

---

## 3. Attach on every chat

```
@PROJECT_BRAIN.md
@PROMPT_SCOPE.md
```

[PROMPT_SCOPE.md](PROMPT_SCOPE.md) — prompt gate, ordered queue, future scope, change log (update **async** during the chat).

For return work also attach:
```
@docs/next-plan/return-trip-allocation-roadmap.txt
@docs/API_CONTRACTS.md
```

---

## 4. Task packs (@ paths)

| Task | Attach |
|------|--------|
| **App-wide** | @docs/LIB_STRUCTURE.md @docs/ARCHITECTURE.md @docs/CODE_MAP.md |
| **D2D** | @lib/features/d2d/README.md @docs/API_CONTRACTS.md @docs/UI_ARCHITECTURE.md |
| **Return batch** | @lib/features/batches/README.md @docs/API_CONTRACTS.md @docs/FLOWS_BY_ROLE.md |
| **New UI** | @docs/FLOWS_BY_ROLE.md @docs/UI_ARCHITECTURE.md @docs/FEATURES.md @docs/LIB_STRUCTURE.md |
| **Backend** | @docs/API_CONTRACTS.md @docs/LOCAL_DEV.md @docs/backend/README.md |
| **Offline** | @docs/OFFLINE_AND_SYNC.md @docs/ARCHITECTURE.md |
| **Return allocation** | @docs/next-plan/return-trip-allocation-roadmap.txt @docs/backend/README.md @docs/API_CONTRACTS.md |

---

## 5. Current focus

**This session (2026-08-23 ~23:10 IST):** **R7 cutoff** shipped — D3 = **T−15** lazy on pool compute; Flutter shows “Holds released”.

| Piece | Detail |
|-------|--------|
| Backend | `is_past_return_cutoff` + `cutoff_batch_ids` in allocator; `return_pool` applies live clock |
| Status | Optional `cutoff_applied: true` with pool extras |
| Tests | `test_return_allocator.py` **19/19** (cases 17–19 R7) |

**Also this session:** Admin Mark all coming (org); PROMPT_SCOPE created.

**Next session:** Confirm “API every time” (**26d-discuss**) or batch-wise Mark all. Do not redo 26d intent product.

| Repo | Branch | Tip |
|------|--------|-----|
| `D:\cts_beta` | `beta-ver` | (uncommitted mark-all coming) |
| `D:\cts-docker` | (local) | `AdminCommuterIsComing` view + tests |

**26d facts (do not redo):**
- Intent ≠ confirm. Admin/driver still `POST add_commuter`. Do **not** reuse `isComing` as return intent (R10).
- Redis: `d2d:return_intent:{dd-mm-yyyy}` → `home` \| `skip` \| `earlier:{batch_id}`
- API: `GET/POST /d2d/return_batch/intent`, `GET /d2d/return_batch/intent_options`

| Device | Last role | Login |
|--------|-----------|--------|
| `emulator-5554` | **Admin (logged in)** | `7069036462` / `password` |
| Phone `5f36af49` | **Driver 1 (logged in)** | **`9876544111`** (Driver 2 is `9876544112` / Batch-02) |

| State | Detail |
|-------|--------|
| `.env` | LAN **`192.168.1.15`** (check `docs/LOCAL_DEV.md` if Wi‑Fi changed) |
| Backend containers | Up: `C2S-Nginx` / `C2S-Django` / `C2S-redis` / `C2S-PostgresDB` |

---

## 6. Status snapshot

### Done (Aug 2026)

- Admin one-click Mark all coming — `PATCH …/admin/commuter/<adminCode>/isComing` + `CommuterScreen` AppBar
- **R7** return cutoff T−15 — unconfirmed home holds release; `cutoff_applied` on status
- Morning D2D Fix 1 — ended-trip guard (WS close 4001) + Flutter `isTripEnded`
- Return batch backend R1–R6 + Flutter; **26d** return intent
- P1–P9 waves, A1 Track Cab, return list realignment, auth security wave
- Full-cycle smoke PASS (2026-08-23) Batch-01 D2D + return end

### Open backlog (from PROJECT_TODOS)

- **Decide next:** Confirm “API every time” (26d-discuss) — R7 done
- Batch-wise Mark all coming (`CommuterListScreen`)
- Optional: Commuter 26d **Return today** chip smoke
- Remaining Application High: A6–A9

---

## 7. Architecture (minimal)

```
Screens → Provider → Repository → API (REST / WebSocket)
```

| Area | Path |
|------|------|
| App shell | `lib/app/cts_app.dart`, `lib/app/app_providers.dart`, `lib/app/app_lifecycle_host.dart` |
| Lifecycle | `lib/core/lifecycle/` — foreground/background/resume coordinator |
| Network guard | `lib/core/network/network_action_guard.dart` — pre-check before live/return mutations |
| Concurrency | `lib/core/concurrency/batched_runner.dart` — capped parallel task runner (P8 status fetch) |
| Router | `lib/app/router/app_router.dart` |
| Network | `lib/api/` (canonical Dio client; not `core/network/`) |
| API constants | `lib/api/api_list.dart` |
| Response contract | `lib/api/api_response_contract.dart` — status/message/code truth layer |
| Config | `AppConfig` in `lib/appManager/app_class.dart` |
| D2D live | `lib/features/d2d/` |
| Batches + return | `lib/features/batches/` |
| Shared widgets | `lib/widgets/` |

---

## 8. Glossary (short)

| Term | Meaning |
|------|---------|
| **D2D** | Door-to-door morning live trip — WebSocket-driven commuter queue |
| **POP** | Point of pickup — commuter boarding location |
| **Batch** | Scheduled route run (morning or evening) with assigned driver/cab |
| **isComing** | Commuter flagged as en route / picked up in live D2D queue |
| **Return batch** | Evening REST-only trip — confirm/remove commuters, end trip |

---

## 9. Session handoff log (max 3 entries)

| Date | Session | Outcome |
|------|---------|---------|
| 2026-08-23 | R7 T−15 cutoff | Allocator + pool lazy release; Flutter cutoff badge; 19/19 allocator tests |
| 2026-08-23 | PROMPT_SCOPE | Created attachable prompt gate + ordered queue |
| 2026-08-23 | Mark all coming | Backend PATCH + Flutter AppBar; Django 6/6 tests |

---

## 10. Deep docs (pointers only)

| Area | Entry |
|------|-------|
| Flutter docs hub | [docs/README.md](docs/README.md) · [docs/START_HERE.md](docs/START_HERE.md) |
| Architecture | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) · [docs/CODE_MAP.md](docs/CODE_MAP.md) |
| API | [docs/API_AND_ENV.md](docs/API_AND_ENV.md) · [docs/API_CONTRACTS.md](docs/API_CONTRACTS.md) |
| UI / flows | [docs/UI_ARCHITECTURE.md](docs/UI_ARCHITECTURE.md) · [docs/FLOWS_BY_ROLE.md](docs/FLOWS_BY_ROLE.md) |
| Guides | [docs/guides/](docs/guides/) |
| Wireframes | — (removed; use live app + [docs/UI_ARCHITECTURE.md](docs/UI_ARCHITECTURE.md)) |
| Backend detail | [docs/backend/README.md](docs/backend/README.md) · [docs/INTEGRATION.md](docs/INTEGRATION.md) |
| Local dev | [docs/LOCAL_DEV.md](docs/LOCAL_DEV.md) · [docs/GLOSSARY.md](docs/GLOSSARY.md) |
| E2E flows | [docs/features/D2D_E2E.md](docs/features/D2D_E2E.md) · [docs/features/RETURN_BATCH_E2E.md](docs/features/RETURN_BATCH_E2E.md) |
| Sprint history | — (removed; use [PROJECT_TODOS.md](PROJECT_TODOS.md) / brain §9) |
| Doc registry | [DOC_REGISTRY.md](DOC_REGISTRY.md) |
| Chat templates | [CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) |
| Live backlog | [PROJECT_TODOS.md](PROJECT_TODOS.md) |
