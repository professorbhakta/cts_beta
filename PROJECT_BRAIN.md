> **Doc:** PROJECT_BRAIN.md
> **Updated:** 2026-08-20 23:30 IST
> **Session:** Removed qa_lab/ + qa_screens/ from repo

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
- **Quality:** `flutter analyze`, `flutter pub get`, `flutter test` after code changes
- **Pre-push device smoke (required):** both lab devices — emulator admin + phone driver — manual login via `flutter run`; see [docs/TESTING.md](docs/TESTING.md) § Pre-push gate. Unit tests alone are not enough before `git push`.
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
| **Return allocation** | @docs/next-plan/return-trip-allocation-roadmap.txt @docs/backend/README.md @docs/API_CONTRACTS.md |

---

## 5. Current focus

**Next:** Product backlog — 26d Commuter POST intent or A6–A9. Do **not** re-create deleted P1–P9 branches.

**This session:** Removed `qa_lab/` (158) + `qa_screens/` (52) from git; gitignored both so local dumps stay local. P7 already on `cts-docker` `p7-rule-integrity-r4-r9` @ `783e5ef` (no main merge).

| Device | Last role | Login |
|--------|-----------|--------|
| `emulator-5554` | Admin | `7069036462` / `password` |
| Phone `5f36af49` | Driver 2 | **`9876544112`** (Batch-02 / id **5**) |

| State | Detail |
|-------|--------|
| `.env` | LAN **`192.168.1.6`** (home Wi-Fi; hotspot `172.20.10.2` was down) |
| Return Batch #5 | UG2 confirmed (`user id 22`); seats 52/53; trip active |
| Backend | `isComing` pool live; Available(196) after UG12 remove |
| Flutter role UI | **PASS** — Admin Confirm/view-only/no End; Driver Confirm/Remove/End FAB |
| Git | `beta-ver` @ **`849115f`** (+ local unused-file cleanup dirty); tag **`p1-p9-merged`** on origin |

---

## 6. Status snapshot

### Done (Aug 2026)

- Morning D2D Fix 1 — ended-trip guard (WS close 4001) + Flutter `isTripEnded`
- Morning D2D Fix 2 — Redis live DS `d2d:live:…`
- Morning D2D Fix 4 — unique DTODLOG/day + status API
- Flutter WS action error handling — SnackBar on admin + driver
- Return batch backend R1–R6 + Flutter (tabs, confirm/remove/end)
- Driver return screen — confirm/remove/end on `/driverReturnCommuter/:batchId` (admin add/view; End driver)
- Backend hardening — `test_d2d_fixes.py` (**11/11**, includes anonymous WS 4401 + STOP close 4001), `test_return_batch_fixes.py` (10/10)
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
- Driver return ADD — confirm/remove via REST; available = org commuters not confirmed today; End FAB is driver-only (admin add/view)
- 2-device QA lab online (phone `5f36af49` + Pixel_10_Pro); off-screen window + 0.25 scale for 1536×816 laptop documented in LOCAL_DEV
- Dummy org bulk-loaded (admin `7069036462`; dump org untouched)
- Admin on-channel STOP (2026-08-17 code): `isActive: false` → `isTripEnded`; running batches refresh; STOP FAB hidden; Django group close **4001**
- Return allocation adapter — `return_pool.py`; STOP-gated CList; extras `home_hold` / `overflow_confirmed` / `overflow_remaining`; fail closed omits extras
- Return allocation M3 — GET status merges those extras; `remaining_capacity` / `available_count` unchanged; `get_commuter` unchanged
- Flutter M3 — picker + return banner show Home hold / Overflow in / Overflow open when extras present; Seats left still empty-cab seats
- Return allocation M4 — GET view `home[]` / `overflow[]`; Flutter Available Home then Overflow. Empty if no CList. Not M7.
- Return allocation M7 — `validate_add_commuter()` enforces R2–R5 on POST add_commuter. Flutter error surfacing + overflow disable.
- P1 Truth Contract — `ApiResponseContract`; C1 fixed (200+status:error → failure); 33 flutter tests
- P2 Security Boundary — backend POST/PATCH userType gates; Flutter session role refresh + fail-secure 401/4401 redirect; 46 flutter tests
- P3 Lifecycle resilience — AppLifecycleCoordinator; D2D WS reconnect on resume; connection-lost banner; return batch resume guard; 59 flutter tests
- P4 Channel role governance — `D2dChannelRolePolicy`; provider + UI gating; WS `already_in` Already IN section; driver add FAB; backend action role gates; 68 flutter tests
- P5 Degraded network UX — `NetworkActionGuard`; app offline banner; D2D + return batch pre-checks; offline_temp auto-redirect deferred; 66 flutter tests
- P6 State lifecycle hygiene — batch switch clear, load generation, dispose/reset; no stale flash; 72 flutter tests
- P8 Scale/layout stability — batched status fetch (10 concurrent); return picker list on narrow/extras; no nested card scroll; 94 flutter tests
- P9 Debt/health burndown — dio 5.11, secure_storage 11, firebase_messaging 16.5; CRUD SnackBar moved to UI; sort_utils stub removed; offline_temp isolated; compileSdk 37; 101 tests
- A1 Track Cab vehicle — cab `trackingVehicleId` wired to Fleet Edge URL; admin cab form; fallback banner; 106 tests; **on `beta-ver` `72b6aa5`**
- Return list realignment — available pool now follows current `isComing=True` commuters, confirmed hydration preserves ID order, admin return screen is add/view, driver return screen can confirm/remove/end
- Batch-02 / Driver 2 role UI smoked and pushed (`72b6aa5`)
- Flutter git cleanup — tag `p1-p9-merged`; P1–P9 + integration branches deleted local/remote

### Open backlog (from PROJECT_TODOS)

- Commuter POST intent (skip/home/earlier) + cutoff/no-show release.
- Remaining Application High: A6–A9
- Expand automated tests (P1 added contract + return batch repo tests)
- Phase 9 / E: promote or isolate `offline_temp` (drawer-scoped; full promote deferred)
- Phase C–D: `appManager` → `app/services`; rename `*_controller.dart` (widgets + `lib/api/` already canonical)
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
| 2026-08-20 | QA dump purge | Removed `qa_lab/` + `qa_screens/` from git; gitignored |
| 2026-08-20 | Unused-file cleanup | final-gate XML/PNG gone; seed `_*.png` gone; dead Dart stubs |
| 2026-08-20 | Git cleanup APPLY | Tag `p1-p9-merged`; deleted P1–P9 + integration local/remote |

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
