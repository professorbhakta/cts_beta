> **Doc:** PROJECT_BRAIN.md
> **Updated:** 2026-08-14 22:00 IST
> **Session:** Driver return ADD — any-batch pool, hide confirmed

# PROJECT BRAIN — CTS Flutter

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
- **Quality:** `flutter analyze`, `flutter pub get`, test on iOS + Android after code changes
- **End-of-session doc sync** via [CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) + [DOC_REGISTRY.md](DOC_REGISTRY.md)

---

## 3. Attach on every chat

```
@PROJECT_BRAIN.md
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

---

## 5. Current focus

**Idle after driver return ADD (2026-08-14):** Driver can confirm/remove on `/driverReturnCommuter` (End remains admin). Evening available pool is all org commuters except anyone already confirmed today (any batch; not gated on `isComing`). Django restarted; `test_return_batch_fixes.py` 14/14. Next: remaining Application High (A1, A6–A9) or R4/R5 STOP flush.

---

## 6. Status snapshot

### Done (Aug 2026)

- Morning D2D Fix 1 — ended-trip guard (WS close 4001) + Flutter `isTripEnded`
- Morning D2D Fix 2 — Redis live DS `d2d:live:…`
- Morning D2D Fix 4 — unique DTODLOG/day + status API
- Flutter WS action error handling — SnackBar on admin + driver
- Return batch backend R1–R6 + Flutter (tabs, confirm/remove/end)
- Driver return screen — confirm/remove on `/driverReturnCommuter/:batchId` (End admin-only)
- Backend hardening — `test_d2d_fixes.py` (10/10, includes anonymous WS 4401), `test_return_batch_fixes.py` (10/10)
- Flutter UX polish — driver log badge, swipe labels, return cards
- Phase 7 batches migration; go_router; Provider retained; `flutter analyze` clean
- Phase 8 polish — admin home partial-load UX, D2D status via `D2dRepository`, ProfileProvider + logout confirm
- P1 docs freeze — feature folders are `screens/` / `providers/` / `models/` / `repositories/`
- Return-batch REST — all six `/d2d/return_batch/` endpoints wired (view, status, get_commuter, add, remove, POST end)
- Auth security wave — public sign-up disabled; TLS schemes kept; logout/401 clear cookies; D2D WS session + Django 4401/4403
- Application wave Slice 1 (A2) — batch commuter swipe-edit and route edit/delete pass the model, not the sorted index
- Application wave Slice 2 (A3) — commuter Email/Address restored; empty create address → email; update uses last saved
- Application wave Slice 3 (A4) — dashboard Add Batch/Commuter/Driver/Cab/Route/POP call matching `clearAll()`
- Same-class wave — A5 pop-reload by list scope; A10 commuter not wrapped in OfflineAutoRedirect; R6 unknown sync types fail once, connectivity disposed on app teardown
- Admin nested `CommuterListScreen` Coming-today switch — was `onChanged: null`; now uses `updateCommuterIsComing` like `CommuterScreen`
- Admin Coming switch actually persists — switch outside InkWell/Slidable; PATCH `{isComing}` by user ID; Django returns `{status, isComing}`
- Admin D2D ADD — lookup by user ID (not batch-only); Http404 no longer drops the socket; success toast after live list updates
- Driver return ADD — confirm/remove via REST; available = org commuters not confirmed today; End FAB still admin-only

### Open backlog (from PROJECT_TODOS)

- Remaining Application High: A1 Track Cab vehicle, A6–A9
- Deferred Reliability: R4 logout reset, R5 STOP flush
- Backend `POST /user/` still trusts client `userType`
- Phase 9: promote `offline_temp` entity coverage
- Phase C–E restructure: delete re-export stubs, naming, offline merge
- Admin CRUD placeholder screens / TODOs
- Expand automated tests
- REST d2d view permissions still open in dev
- Screenshot PNGs; semantic color tokens pilot
- `channels_redis` for WS broadcast (backend backlog)

---

## 7. Architecture (minimal)

```
Screens → Provider → Repository → API (REST / WebSocket)
```

| Area | Path |
|------|------|
| App shell | `lib/app/cts_app.dart`, `lib/app/app_providers.dart` |
| Router | `lib/app/router/app_router.dart` |
| Network | `lib/core/network/` |
| API constants | `lib/api/api_list.dart` |
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
| 2026-08-14 | Driver return ADD | Driver confirm/remove; pool is any org commuter; confirmed IDs hidden from all return available lists |
| 2026-08-14 | Doc sync | Coming switch, STOP vs disconnect/4001, D2D ADD user-ID lookup written into owners |
| 2026-08-14 | Admin D2D ADD | Sheet listed all commuters; WS ADD 404-crashed. Lookup by user ID; toast only if list updates |

---

## 10. Deep docs (pointers only)

| Area | Entry |
|------|-------|
| Flutter docs hub | [docs/README.md](docs/README.md) · [docs/START_HERE.md](docs/START_HERE.md) |
| Architecture | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) · [docs/CODE_MAP.md](docs/CODE_MAP.md) |
| API | [docs/API_AND_ENV.md](docs/API_AND_ENV.md) · [docs/API_CONTRACTS.md](docs/API_CONTRACTS.md) |
| UI / flows | [docs/UI_ARCHITECTURE.md](docs/UI_ARCHITECTURE.md) · [docs/FLOWS_BY_ROLE.md](docs/FLOWS_BY_ROLE.md) |
| Guides | [docs/guides/](docs/guides/) |
| Wireframes | [docs/wireframes/index.html](docs/wireframes/index.html) |
| Backend detail | [docs/backend/README.md](docs/backend/README.md) · [docs/INTEGRATION.md](docs/INTEGRATION.md) |
| Local dev | [docs/LOCAL_DEV.md](docs/LOCAL_DEV.md) · [docs/GLOSSARY.md](docs/GLOSSARY.md) |
| E2E flows | [docs/features/D2D_E2E.md](docs/features/D2D_E2E.md) · [docs/features/RETURN_BATCH_E2E.md](docs/features/RETURN_BATCH_E2E.md) |
| Sprint history | [docs/CHANGELOG_SPRINTS.md](docs/CHANGELOG_SPRINTS.md) |
| Doc registry | [DOC_REGISTRY.md](DOC_REGISTRY.md) |
| Chat templates | [CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) |
| Live backlog | [PROJECT_TODOS.md](PROJECT_TODOS.md) |
