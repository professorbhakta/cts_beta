> **Doc:** PROJECT_BRAIN.md
> **Updated:** 2026-08-25 22:15 IST
> **Session:** Rest — docs complete; STEP 8 still on go

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

**Session wrap (2026-08-25):** Docs/structure complete (ownership + story split + FLOWS QR/KM). **Resting.** Next product move: STEP 8 smoke on user **go**.

| Piece | Detail |
|-------|--------|
| Specs | API_CONTRACTS + d2d README + 05 story/locks |
| Journeys | FLOWS_BY_ROLE — morning QR+KM |
| Stack | LOCAL_DEV (nginx 8m + Postgres backup) |
| Next | **go** → STEP 8 · then Q-26d / d2d tests / commit when asked |

**Also open:** Confirm “API every time” (**26d-discuss**) or batch-wise Mark all — do not redo 26d intent product.

| Repo | Branch | Tip |
|------|--------|-----|
| `D:\cts_beta` | `beta-ver` | Uncommitted client-pack UI + docs consolidation |
| `D:\cts-docker` | (local) | nginx body + backup compose; uncommitted |

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
| Backend containers | Up: Nginx / Django / redis / Postgres / **PostgresBackup** |

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
- Full-cycle smoke PASS (2026-08-23) Batch-01 D2D + return end

### Open backlog (from PROJECT_TODOS)

- **Client pack STEP 8** device smoke (user go)
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
| 2026-08-25 | Rest / wrap | Docs complete; STEP 8 still blocked on **go** |
| 2026-08-25 | Story split + FLOWS QR/KM | 05 / FLOWS / 07 / DISCUSSION_LOG roles locked |
| 2026-08-25 | Consol + client pack UI | 01–04/guides retired; BUILD UI 1–7; nginx/backup |

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
| Stack / LAN / nginx 8m / backup | compose, `nginx.conf`, `C2S-PostgresBackup` | `.env` LAN | LOCAL_DEV |
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
