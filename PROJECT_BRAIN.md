> **Doc:** PROJECT_BRAIN.md
> **Updated:** 2026-09-09 09:50 IST
> **Session:** FE branch clear — extras merged into professor-cts (keep 5)

# PROJECT_BRAIN — CTS Flutter

Single entry file for every AI + human chat. Keep under ~250 lines; pointers only — no long specs.

---

## 1. What this is (30 sec)

**CTS (Commuter Transport System)** — cross-platform Flutter app (iOS/Android) for **Admin**, **Supervisor** (filtered admin shell), **Staff** (commuter UX), **Driver**, and **Commuter** roles. Manages morning D2D live trips (WebSocket), evening return batches (REST), routes, POPs, cabs, drivers, and commuters. Role homes + `AdminService` allow-list: [docs/ROUTING_AND_AUTH.md](docs/ROUTING_AND_AUTH.md).

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

**Locked order — do not reshuffle.** Same list in PROMPT_SCOPE, client_req README, 07, CHAT_PROMPTS.

**Always:**
```
@PROJECT_BRAIN.md
@PROMPT_SCOPE.md
```

**Client pack / STEP 8 (append in this order):**
```
@docs/client_req/DISCUSSION_LOG.md
@docs/client_req/07-NEXT-AGENT-PROMPT.md
@lib/features/d2d/README.md
@docs/API_CONTRACTS.md
@docs/TESTING.md
@docs/LOCAL_DEV.md
```

Optional: `@docs/client_req/05-open-decisions.md` (D1–D10) · `@docs/client_req/DESIGN_SNAPSHOT.md` (schema/APIs) · `@docs/client_req/README.md` (index)

**Return work:**
```
@docs/next-plan/return-trip-allocation-roadmap.txt
@docs/API_CONTRACTS.md
@lib/features/batches/README.md
```

**Gate:** pack opened with `let's start client feature`. Device smoke = STEP 8 only after user **go**.

---

## 4. Task packs (@ paths)

| Task | Attach (in order) |
|------|-------------------|
| **App-wide** | @docs/LIB_STRUCTURE.md @docs/ARCHITECTURE.md @docs/CODE_MAP.md |
| **D2D** | @lib/features/d2d/README.md @docs/API_CONTRACTS.md @docs/TESTING.md |
| **Return batch** | @lib/features/batches/README.md @docs/API_CONTRACTS.md @docs/FLOWS_BY_ROLE.md |
| **New UI** | @docs/FLOWS_BY_ROLE.md @docs/UI_ARCHITECTURE.md @docs/FEATURES.md |
| **Backend / lab** | @docs/LOCAL_DEV.md @docs/API_CONTRACTS.md @docs/backend/README.md |
| **Offline** | @docs/OFFLINE_AND_SYNC.md @docs/ARCHITECTURE.md |
| **Client req** | Same as §3 client-pack list; add @docs/FLOWS_BY_ROLE.md for QA/smoke journeys; optional @docs/client_req/05-open-decisions.md |

---

## 5. Current focus

**Session (2026-09-09):** Admin bootstrap FE wired on `feat/admin-bootstrap` — login → `GET /user/admin-bootstrap/` → SQLite v2 (snake_case). JWT passport remains. BE endpoint may still lag.

| Piece | Detail |
|-------|--------|
| Admin bootstrap FE | Branch `feat/admin-bootstrap`. Feature `lib/features/admin_bootstrap/` (Provider; no screens). Schema v2 tables + DAO. Draft: [ADMIN_BOOTSTRAP_DRAFT](docs/setup/ADMIN_BOOTSTRAP_DRAFT.md) |
| JWT FE | Secure storage + Bearer + refresh-on-401 (merged lineage on professor-cts) |
| Setup drafts | [docs/setup/](docs/setup/) — ADMIN_BOOTSTRAP_DRAFT, SQLITE_TABLES_COLUMNS, SCHEMA_FINAL_DRAFT |

**Also open:** BE `GET /user/admin-bootstrap/` implement + device smoke · schema Phase B orgs · STEP 8

| Repo | Branch | Tip |
|------|--------|-----|
| `D:\cts_beta` | `feat/admin-bootstrap` | FE bootstrap sync after ADMIN/SUPERVISOR login |

---

## 6. Status snapshot

### Done (Aug 2026)

- Client pack BE (MEDIA, DTODLOG odo cols, 7 REST, board_commuter) + Flutter BUILD UI STEPS 1–7
- Admin one-click Mark all coming — `PATCH …/admin/commuter/<adminCode>/isComing`
- **R7** return cutoff T−15 — `cutoff_applied` on status
- Morning D2D Fix 1 — ended-trip guard (WS close 4001) + Flutter `isTripEnded`
- Return batch backend R1–R6 + Flutter; **26d** return intent
- Ops: nginx `client_max_body_size 8m`; Postgres backup sidecar
- Docs consolidation — no `backend/01–04`, no `guides/`; FLOWS owns journeys
- Agent fast-path attach + DOC_REGISTRY fast/on-change split; `widget_test` removed
- Agent role cards + LIB_STRUCTURE + ARCHITECTURE — Provider/folder law locked; five `.cursor/rules/*_agent.md` (2026-08-29)
- Full-cycle smoke PASS (2026-08-23) Batch-01 D2D + return end

### Open backlog (from PROJECT_TODOS)

- **JWT Phase A** device `flutter run` smoke + Admin password reset
- **Client pack STEP 8** device smoke (user go)
- Schema / SQLite role tables — discuss-only until green flag ([docs/setup/](docs/setup/))
- **Return QR Phase 2 wired** — mint `?trip=return` + shared `boarding_scan`; live **RCList** = ID list on return trip row; **On End** BE archives — **FE no archive UI** — [docs/setup/RETURN_QR_UI_PREP.md](docs/setup/RETURN_QR_UI_PREP.md) · [RETURN_TRIP_API_GAP.md](docs/setup/RETURN_TRIP_API_GAP.md)
- Parked UI: return-leg KM, admin org odometer list, unboard UI
- **Decide next:** Confirm “API every time” (26d-discuss)
- Batch-wise Mark all coming (`CommuterListScreen`)
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
| Network guard | `lib/core/network/network_action_guard.dart` |
| Concurrency | `lib/core/concurrency/batched_runner.dart` |
| Router | `lib/app/router/app_router.dart` |
| Network | `lib/api/` |
| D2D live + client pack | `lib/features/d2d/` |
| Batches + return | `lib/features/batches/` |
| Shared widgets | `lib/widgets/` |

---

## 8. Glossary (short)

| Term | Meaning |
|------|---------|
| **D2D** | Door-to-door morning live trip — WebSocket-driven commuter queue |
| **POP** | Point of pickup — commuter boarding location |
| **Batch** | Scheduled route run (morning or evening) with assigned driver/cab |
| **isComing** | Commuter flagged as riding today (queue eligibility; not return intent) |
| **Return batch** | Evening REST-only trip — confirm/remove commuters, end trip |

---

## 9. Session handoff log (max 3 entries)

| Date | Session | Outcome |
|------|---------|---------|
| 2026-09-09 | FE branch clear | Merged admin-bootstrap + return QR into professor-cts; keep only 5 remotes |
| 2026-09-08 | Return QR Phase 2 | Wired GET boarding_qr?trip=return + POST boarding_scan; return_trip_id |
| 2026-09-07 | JWT Phase A + docs path | FE PR #4 cream merged; lab login/refresh OK; `docs/setup` synced |

---

## 10. Deep docs + stable BE↔FE map

| Area | Entry |
|------|-------|
| Flutter docs hub | [docs/README.md](docs/README.md) · [docs/START_HERE.md](docs/START_HERE.md) |
| Architecture | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) · [docs/CODE_MAP.md](docs/CODE_MAP.md) |
| API wire | [docs/API_CONTRACTS.md](docs/API_CONTRACTS.md) |
| Lab / Docker | [docs/LOCAL_DEV.md](docs/LOCAL_DEV.md) · [docs/backend/README.md](docs/backend/README.md) |
| **UI / flows** | [docs/FLOWS_BY_ROLE.md](docs/FLOWS_BY_ROLE.md) (QR/KM + smoke) · [docs/UI_ARCHITECTURE.md](docs/UI_ARCHITECTURE.md) |
| Feature owners | [lib/features/d2d/README.md](lib/features/d2d/README.md) · [lib/features/batches/README.md](lib/features/batches/README.md) |
| Client pack | [DISCUSSION_LOG](docs/client_req/DISCUSSION_LOG.md) (pointer) · [05 story/locks](docs/client_req/05-open-decisions.md) · [DESIGN_SNAPSHOT](docs/client_req/DESIGN_SNAPSHOT.md) · [07 smoke](docs/client_req/07-NEXT-AGENT-PROMPT.md) |
| Testing | [docs/TESTING.md](docs/TESTING.md) |
| Registry / prompts | [DOC_REGISTRY.md](DOC_REGISTRY.md) · [CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) |
| Backlog | [PROJECT_TODOS.md](PROJECT_TODOS.md) |

### Client pack — every dot (BE + FE)

| Dot | Backend (`cts-docker`) | Frontend (`cts_beta`) | Doc owner |
|-----|------------------------|----------------------|-----------|
| Waiting pool + FCFS (morning) | `waiting_pool.py` + `live_state.py` · `boarding_scan` `action=join_waiting` | `waitingCommuters` · scan join dialog | d2d README + API_CONTRACTS |
| Trip-end isComing | `set_commuters_is_coming(scope=trip_end)` on STOP + return end | — | API_CONTRACTS + batches README |
| Waiting pool + FCFS (return) | `return_waiting_pool.py` · `add_commuter` `action=join_waiting` | `waitingCommuters` · commuter join button | batches README + API_CONTRACTS |
| DTODLOG odo cols | `d2d_log/models.py` | `odometer_models.dart` | API_CONTRACTS |
| Odometer REST | `odometer_views.py` + `urls.py` | `ApiUrl` + `submitOdometer*` / `getOdometer*` | API_CONTRACTS |
| QR + scan REST | `boarding_views.py` + tokens | `getBoardingQr` / `boardingScan` / unboard | API_CONTRACTS |
| Scan = boarded | `board_commuter` + WS REMOVE | swipe REMOVE + scan success → Already IN | API_CONTRACTS + d2d README |
| Morning WS | `consumers.py` + `live_state.py` | `D2dChannelProvider` | d2d README + API_CONTRACTS |
| Driver UI | — | `d2d_log_screen` + odo sheet + QR panel | d2d README |
| Commuter UI | — | `/boardingScan` + Mark Coming | d2d README · FEATURES |
| Return evening | `return_batch_*` | batches feature | batches README + API_CONTRACTS |
| Product locks | — | — | client_req/05 |
| Schema / API inventory | — | — | client_req/DESIGN_SNAPSHOT |
| Smoke / tests | `test_odometer.py`, `test_boarding_scan.py` | `test/features/d2d/` | TESTING · 07 |

**Retired (do not recreate):** `docs/backend/01–04`, `docs/guides/`, client_req `00–04`+`06`, `test/widget_test.dart`.
