> **Doc:** PROJECT_BRAIN.md
> **Updated:** 2026-09-17 22:45 IST
> **Session:** splash camera deferred (web+mobile); QR/odometer point-of-use only

# PROJECT_BRAIN — CTS Flutter

Single entry file for every AI + human chat. Keep under ~250 lines; pointers only — no long specs.

---

## 1. What this is (30 sec)

**CTS (Commuter Transport System)** — cross-platform Flutter app (iOS/Android) for **Admin**, **Super Admin** (full shell; web org ops via Django `/void/`), **Supervisor** (filtered admin shell), **Staff** (commuter UX), **Driver**, and **Commuter** roles. Manages morning D2D live trips (WebSocket), evening return batches (REST), routes, POPs, cabs, drivers, and commuters. Role homes + `AdminService` allow-list: [docs/ROUTING_AND_AUTH.md](docs/ROUTING_AND_AUTH.md).

| Repo | Path | Role |
|------|------|------|
| Flutter app | `D:\cts_beta` | Mobile client |
| Backend (Docker) | `D:\cts-docker` | Django REST + WebSocket + Postgres + Redis |

---

## 1b. Live FE work

- Daily trip report + edit end_km + odometer photo thumbs (prefer A; silent B) + **boarded[]** + enrichment: `lib/features/trip_report/`. Contract: [docs/setup/TRIP_AUTO_CLOSE_CONTRACT.md](docs/setup/TRIP_AUTO_CLOSE_CONTRACT.md). Dock tip: `934fb02`.
- **Camera permissions:** never at splash (web no-op; mobile notifications only). Camera only at boarding QR / odometer capture (`boarding_scan_screen`, `odometer_camera_helper`). Trip report uses network images only.
- D2D cream + other-batch red + board beeps — [lib/features/d2d/README.md](lib/features/d2d/README.md); WS live `batchId` — [API_CONTRACTS](docs/API_CONTRACTS.md).

## 2. Non-negotiables

- **State:** Provider (not Riverpod)
- **Routing:** go_router with role-protected redirects
- **Layout:** module-based per [docs/LIB_STRUCTURE.md](docs/LIB_STRUCTURE.md) — `screens/`, `providers/`, `models/`, `repositories/` inside each feature
- **No re-export stubs** — one canonical path per file
- **Quality:** `flutter analyze`, `flutter pub get`, `flutter test` after code changes
- **Pre-push device smoke (required):** both lab devices — emulator admin + phone driver — manual login via `flutter run`; see [docs/TESTING.md](docs/TESTING.md) § Pre-push gate. Unit tests alone are not enough before `git push`.
- **End-of-session doc sync** via [CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) + [DOC_REGISTRY.md](DOC_REGISTRY.md)
- **Git:** keep remotes `main` · `professor-cts` · `gb-f&d` · `p&gb-merger` · `beta-ver` — **do not day-work or push to `main`**
- **This machine day sync:** FE → [`professor-cts`](https://github.com/professorbhakta/cts_beta/tree/professor-cts) · BE → [`professor-dock`](https://github.com/professorbhakta/cts-docker/tree/professor-dock) — pull on start, push on stop

---

## 3. Attach on every chat

**Locked order — do not reshuffle.** Same list in PROMPT_SCOPE, CHAT_PROMPTS.

**Always:**
```
@PROJECT_BRAIN.md
@PROMPT_SCOPE.md
```

**Client pack / STEP 8 (append in this order — only on go):**
```
@docs/setup/DISCUSSION_STATUS.md
@docs/FLOWS_BY_ROLE.md
@docs/STEP8_DEVICE_SMOKE_CHECKLIST.txt
@lib/features/d2d/README.md
@docs/API_CONTRACTS.md
@docs/TESTING.md
@docs/LOCAL_DEV.md
```

**Return work:**
```
@docs/next-plan/return-trip-allocation-roadmap.txt
@docs/API_CONTRACTS.md
@lib/features/batches/README.md
```

**Setup drafts (append after Always when doing JWT/bootstrap/schema — order locked):**
```
@CHAT_PROMPTS.txt
@docs/setup/DISCUSSION_STATUS.md
@docs/setup/BRANCH_HOLD_NOTES.md
@docs/API_CONTRACTS.md
@docs/setup/JWT_LOGIN_IMPLEMENTATION_NOTES.txt
@docs/setup/ADMIN_BOOTSTRAP_DRAFT.md
@docs/setup/LOGIN_JSON_FIELDS.txt
@docs/setup/SQLITE_TABLES_COLUMNS.txt
@docs/setup/SCHEMA_FINAL_DRAFT.txt
@docs/setup/RETURN_TRIP_API_GAP.md
@docs/setup/RETURN_QR_UI_PREP.md
@docs/ROUTING_AND_AUTH.md
@lib/features/batches/README.md
@lib/features/d2d/README.md
@docs/LOCAL_DEV.md
@docs/TESTING.md
```

**Gate:** Device smoke = STEP 8 only after user **go**. Product locks D1–D10 live in FLOWS.

---

## 4. Task packs (@ paths)

| Task | Attach (in order) |
|------|-------------------|
| **App-wide** | @docs/LIB_STRUCTURE.md @docs/ARCHITECTURE.md @docs/CODE_MAP.md |
| **D2D** | @lib/features/d2d/README.md @docs/API_CONTRACTS.md @docs/TESTING.md |
| **Return batch** | @lib/features/batches/README.md @docs/API_CONTRACTS.md @docs/FLOWS_BY_ROLE.md |
| **New UI** | @docs/FLOWS_BY_ROLE.md @docs/UI_ARCHITECTURE.md @docs/FEATURES.md |
| **Backend / lab** | @docs/LOCAL_DEV.md @docs/API_CONTRACTS.md |
| **Offline** | @docs/OFFLINE_AND_SYNC.md @docs/ARCHITECTURE.md |
| **Setup / JWT / bootstrap** | Same as §3 setup drafts pack · start [DISCUSSION_STATUS](docs/setup/DISCUSSION_STATUS.md) |
| **FE prod inspection** | [FE_PRODUCTION_INSPECTION_CONTINUE_PROMPT](docs/setup/FE_PRODUCTION_INSPECTION_CONTINUE_PROMPT.txt) + [CHECKLIST](docs/FE_PRODUCTION_INSPECTION_CHECKLIST.md) · stay Main Agent mindset |
| **Client / STEP 8** | Same as §3 client-pack list |

---

## 5. Current focus

**Session (2026-09-16):** D2D cream + beeps pushed; BE `batchId` hydrate pushed — restart dock before smoke.

| Piece | Detail |
|-------|--------|
| FE tip | `professor-cts` **30909b8** — cream shared body; FAB-only Add; red + one tone/delta; WS `batchId` parse |
| BE tip | `professor-dock` **66c89e9** — WS live entries include **`batchId`** — **restart/redeploy dock** for driver red/beeps |
| Focus | Human device smoke (admin cream, driver no Add, red rows, both-phone beeps) |
| Docs | [d2d README](lib/features/d2d/README.md) · [API_CONTRACTS](docs/API_CONTRACTS.md) live entry `batchId` |
| Keep remotes | `main` · `professor-cts` · `gb-f&d` · `p&gb-merger` · `beta-ver` |
| Day sync | pull on start / push on stop for professor-cts / professor-dock |

**Next:** Restart BE stack on lab/VPS; human smoke both phones.

| Repo | Branch | Tip |
|------|--------|-----|
| `D:\cts_beta` | `professor-cts` | **30909b8** cream + beeps (+ trip report) |
| `D:\cts-docker` | `professor-dock` | **66c89e9** WS `batchId` hydrate |

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

- **JWT Phase A** / **P8** / **STEP 8** device smoke — human + real devices **after push** (not agent) + Admin password reset
- Phase B: richer org fill on login (bootstrap already returns organizations[] on lab)
- **Return QR Phase 2 wired** — mint `?trip=return` + shared `boarding_scan`; Dart `returnTripLogId`/`tripLeg`; **FE no archive UI** — [RETURN_QR_UI_PREP](docs/setup/RETURN_QR_UI_PREP.md) · [GAP](docs/setup/RETURN_TRIP_API_GAP.md)
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
| **returnTripLogId** | Dart name for wire `return_trip_id` (ReturnTripLog PK / RCList row) |
| **tripLeg** | Dart name for wire `trip` (`morning` \| `return`) |
| **SUPER_ADMIN** | Full mobile admin shell; web org portal = Django `/void/` |

---

## 9. Session handoff log (max 3 entries)

| Date | Session | Outcome |
|------|---------|---------|
| 2026-09-15 ~22:35 | D2D cream + audit docs | Cream UI; Driver no Add; red + beeps; WS `batchId` FE+BE; scan beep uses prefs; docs synced |
| 2026-09-11 ~12:40 | Dock P0 security | JWT WS middleware; GET `/user/` dump closed; return end/add/remove role-gated; SUPER_ADMIN/SUPERVISOR; **20** tests OK |
| 2026-09-10 ~23:15 | Prune superseded continues | Deleted FE_MATCH / D2D_PHASE3 / LAB_SMOKE_CONTINUE; scrubbed attach lists; kept client_req + inspection + LAB_SMOKE_ISSUES |

---

## 10. Deep docs + stable BE↔FE map

| Area | Entry |
|------|-------|
| Flutter docs hub | [docs/README.md](docs/README.md) · [docs/START_HERE.md](docs/START_HERE.md) |
| Architecture | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) · [docs/CODE_MAP.md](docs/CODE_MAP.md) |
| API wire | [docs/API_CONTRACTS.md](docs/API_CONTRACTS.md) |
| Lab / Docker | [docs/LOCAL_DEV.md](docs/LOCAL_DEV.md) |
| **UI / flows** | [docs/FLOWS_BY_ROLE.md](docs/FLOWS_BY_ROLE.md) (QR/KM + D1–D10 + smoke) · [docs/UI_ARCHITECTURE.md](docs/UI_ARCHITECTURE.md) |
| Feature owners | [lib/features/d2d/README.md](lib/features/d2d/README.md) · [lib/features/batches/README.md](lib/features/batches/README.md) |
| Client / STEP 8 | [DISCUSSION_STATUS](docs/setup/DISCUSSION_STATUS.md) · [FLOWS](docs/FLOWS_BY_ROLE.md) · [STEP8 checklist](docs/STEP8_DEVICE_SMOKE_CHECKLIST.txt) · [API_CONTRACTS](docs/API_CONTRACTS.md) |
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
| Morning WS | `consumers.py` + `live_state.py` + live `batchId` on entries | `D2dChannelProvider` + `homeBatchId` | d2d README + API_CONTRACTS |
| Driver UI | — | `d2d_log_screen` + cream body + QR; **no Add**; red/beeps | d2d README |
| Admin live UI | — | `d2d_channel` cream body; Add if operator; no QR | d2d README |
| Commuter UI | — | `/boardingScan` + Mark Coming + board beep | d2d README · FEATURES |
| Return evening | `return_batch_*` | batches feature | batches README + API_CONTRACTS |
| Product locks | — | — | FLOWS_BY_ROLE (D1–D10) |
| Schema / API inventory | — | — | API_CONTRACTS |
| Smoke / tests | `test_odometer.py`, `test_boarding_scan.py` | `test/features/d2d/` | TESTING · STEP8 checklist · FLOWS |

**Retired (do not recreate):** `docs/backend/`, `docs/client_req/`, `docs/guides/`,
setup drafts `CLIENT_RETURN_QR_NOTE` · `RETURN_TRIP_COLUMNS_DRAFT` · `ROLE_ACCESS_PHASE_A` ·
`USER_ROLES_DISCUSSION` · `CREAM_BOARD_SCHEMA_UI`, `test/widget_test.dart`, `integration_test/`.
