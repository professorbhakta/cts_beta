> **Doc:** DOC_REGISTRY.md
> **Updated:** 2026-09-17 12:30 IST
> **Session:** Trip report odometer photo thumbnails docs sync

# Documentation Registry

Update at **end of every session** ([CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) END PROMPT).

**Attach order is locked** in [PROJECT_BRAIN.md](PROJECT_BRAIN.md) §3 — do not invent a new order each chat.

**Story split:** [FLOWS](docs/FLOWS_BY_ROLE.md) = journeys + D1–D10 · [API_CONTRACTS](docs/API_CONTRACTS.md) = wire/schema · [DISCUSSION_STATUS](docs/setup/DISCUSSION_STATUS.md) = handoff · [STEP8 checklist](docs/STEP8_DEVICE_SMOKE_CHECKLIST.txt) = smoke.

---

## How to update

1. Doc header: **Updated** (IST) + **Session** note.
2. Matching row in **Fast sync** (always) or **On change** (when touched).
3. [PROJECT_BRAIN.md](PROJECT_BRAIN.md) §5 / §6 / §9 (+ §10 map if ownership moved).
4. [PROMPT_SCOPE.md](PROMPT_SCOPE.md) queue + change log.
5. [PROJECT_TODOS.md](PROJECT_TODOS.md) if backlog moved.
6. If client/STEP 8 pack touched: bump [DISCUSSION_STATUS](docs/setup/DISCUSSION_STATUS.md).
7. No long specs in PROJECT_BRAIN — pointers only.

---

## Fast sync (every session)

| Doc | Last updated | Session note |
|-----|--------------|--------------|
| [CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) | 2026-09-12 15:55 IST | setup merge noted |
| [PROJECT_BRAIN.md](PROJECT_BRAIN.md) | 2026-09-17 12:30 IST | Trip report odo photo thumbs |
| [PROMPT_SCOPE.md](PROMPT_SCOPE.md) | 2026-09-17 12:30 IST | Q-trip-odo-thumbs done |
| [DOC_REGISTRY.md](DOC_REGISTRY.md) | 2026-09-17 12:30 IST | this sync |
| [docs/setup/DISCUSSION_STATUS.md](docs/setup/DISCUSSION_STATUS.md) | 2026-09-17 12:30 IST | trip report odo thumbs |
| [docs/FLOWS_BY_ROLE.md](docs/FLOWS_BY_ROLE.md) | 2026-09-15 22:35 IST | Admin/Driver D2D cream + no driver Add |

---

## Ownership (frozen)

| Concern | Owner |
|---------|--------|
| Session / queue | `PROJECT_BRAIN` + `PROMPT_SCOPE` |
| Docker / LAN / backup / nginx + `d2d_log` module map | `docs/LOCAL_DEV.md` |
| REST + WS wire + schema inventory | `docs/API_CONTRACTS.md` |
| Morning D2D + client pack UI | `lib/features/d2d/README.md` |
| Return batch | `lib/features/batches/README.md` |
| Return QR UI / Phase 2 + client locks | `docs/setup/RETURN_QR_UI_PREP.md` · `docs/setup/RETURN_TRIP_API_GAP.md` |
| Operator journeys + product locks D1–D10 | `docs/FLOWS_BY_ROLE.md` |
| Roles / homes / allow-list | `docs/ROUTING_AND_AUTH.md` |
| Admin list/form field map | `docs/UI_ARCHITECTURE.md` §8 |
| Pack handoff pointer | `docs/setup/DISCUSSION_STATUS.md` |
| Smoke checklist | `docs/STEP8_DEVICE_SMOKE_CHECKLIST.txt` · FLOWS QA section |
| Smoke / test how-to | `docs/TESTING.md` |
| JWT / discussion status | `docs/setup/DISCUSSION_STATUS.md` · `docs/setup/JWT_LOGIN_IMPLEMENTATION_NOTES.txt` |
| Branch map (FE+BE) | `docs/setup/BRANCH_HOLD_NOTES.md` |
| Setup drafts index | `docs/setup/README.md` · `docs/setup/SCHEMA_FINAL_DRAFT.txt` |
| Admin bootstrap | `docs/setup/ADMIN_BOOTSTRAP_DRAFT.md` · `docs/setup/SQLITE_TABLES_COLUMNS.txt` |
| FE prod inspection checklist | [docs/FE_PRODUCTION_INSPECTION_CHECKLIST.md](docs/FE_PRODUCTION_INSPECTION_CHECKLIST.md) |
| FE inspect continue prompt | [docs/setup/FE_PRODUCTION_INSPECTION_CONTINUE_PROMPT.txt](docs/setup/FE_PRODUCTION_INSPECTION_CONTINUE_PROMPT.txt) |

**Full BE↔FE dot table:** [PROJECT_BRAIN.md §10](PROJECT_BRAIN.md#10-deep-docs--stable-befe-map).

**Retired:** entire `docs/backend/`, entire `docs/client_req/`, `docs/guides/`, `test/widget_test.dart`,
`integration_test/`, setup drafts `CLIENT_RETURN_QR_NOTE`, `RETURN_TRIP_COLUMNS_DRAFT`,
`ROLE_ACCESS_PHASE_A`, `USER_ROLES_DISCUSSION`, `CREAM_BOARD_SCHEMA_UI`,
`docs/D2D_PHASE3_CONTINUE_PROMPT.txt`, `docs/LAB_SMOKE_CONTINUE_PROMPT.txt`,
`docs/setup/FE_MATCH_BE_TIP_CONTINUE_PROMPT.txt`.

---

## On change

| Doc | Last updated | Session note |
|-----|--------------|--------------|
| [docs/setup/ADMIN_BOOTSTRAP_DRAFT.md](docs/setup/ADMIN_BOOTSTRAP_DRAFT.md) | 2026-09-09 20:15 IST | SUPER_ADMIN + SQLite v3 |
| [docs/setup/DISCUSSION_STATUS.md](docs/setup/DISCUSSION_STATUS.md) | 2026-09-12 15:55 IST | setup prune |
| [docs/setup/README.md](docs/setup/README.md) | 2026-09-12 15:55 IST | 10 live drafts only |
| [docs/setup/BRANCH_HOLD_NOTES.md](docs/setup/BRANCH_HOLD_NOTES.md) | 2026-09-09 20:30 IST | tip SHAs |
| [docs/setup/RETURN_QR_UI_PREP.md](docs/setup/RETURN_QR_UI_PREP.md) | 2026-09-12 15:55 IST | Absorbed CLIENT_RETURN locks |
| [docs/setup/RETURN_TRIP_API_GAP.md](docs/setup/RETURN_TRIP_API_GAP.md) | 2026-09-09 20:15 IST | FE agent name map |
| [docs/setup/LOGIN_JSON_FIELDS.txt](docs/setup/LOGIN_JSON_FIELDS.txt) | 2026-09-09 20:15 IST | SUPER_ADMIN profile |
| [docs/setup/SQLITE_TABLES_COLUMNS.txt](docs/setup/SQLITE_TABLES_COLUMNS.txt) | 2026-09-09 19:50 IST | schema v3 |
| [docs/setup/SCHEMA_FINAL_DRAFT.txt](docs/setup/SCHEMA_FINAL_DRAFT.txt) | 2026-09-12 15:55 IST | Absorbed return columns draft |
| [docs/setup/JWT_LOGIN_IMPLEMENTATION_NOTES.txt](docs/setup/JWT_LOGIN_IMPLEMENTATION_NOTES.txt) | 2026-09-09 20:15 IST | SUPER_ADMIN userType |
| [docs/LIB_STRUCTURE.md](docs/LIB_STRUCTURE.md) | 2026-09-10 19:40 IST | offline_temp removed |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 2026-08-29 10:03 IST | Layer mermaid |
| [docs/LOCAL_DEV.md](docs/LOCAL_DEV.md) | 2026-09-12 15:45 IST | + d2d_log module map |
| [docs/ROUTING_AND_AUTH.md](docs/ROUTING_AND_AUTH.md) | 2026-09-12 15:55 IST | Absorbed ROLE_ACCESS + USER_ROLES |
| [docs/INTEGRATION.md](docs/INTEGRATION.md) | 2026-09-12 15:45 IST | Drop backend/README link |
| [docs/CODE_MAP.md](docs/CODE_MAP.md) | 2026-09-08 12:45 IST | AdminCapabilities map |
| [docs/API_CONTRACTS.md](docs/API_CONTRACTS.md) | 2026-09-17 12:30 IST | Trip report photo URL A + B pointer |
| [docs/setup/TRIP_AUTO_CLOSE_CONTRACT.md](docs/setup/TRIP_AUTO_CLOSE_CONTRACT.md) | 2026-09-17 12:30 IST | start/end_photo_url + thumbnail UX |
| [docs/FLOWS_BY_ROLE.md](docs/FLOWS_BY_ROLE.md) | 2026-09-15 22:35 IST | Cream channel; Driver no Add; other-batch red/beeps |
| [docs/UI_ARCHITECTURE.md](docs/UI_ARCHITECTURE.md) | 2026-09-15 22:35 IST | D2D cream Admin/Driver wireframes |
| [lib/features/batches/README.md](lib/features/batches/README.md) | 2026-09-09 20:15 IST | returnTripLogId naming |
| [lib/features/d2d/README.md](lib/features/d2d/README.md) | 2026-09-15 22:35 IST | Cream UI; other-batch; beeps; WS `batchId` |
| [PROJECT_TODOS.md](PROJECT_TODOS.md) | 2026-09-15 22:35 IST | D2D cream + beeps checked |
| [docs/FE_PRODUCTION_INSPECTION_CHECKLIST.md](docs/FE_PRODUCTION_INSPECTION_CHECKLIST.md) | 2026-09-12 16:00 IST | Moved under docs/; P0–P7 PASS; Next P8 |
| [docs/setup/FE_PRODUCTION_INSPECTION_CONTINUE_PROMPT.txt](docs/setup/FE_PRODUCTION_INSPECTION_CONTINUE_PROMPT.txt) | 2026-09-12 16:00 IST | Checklist path → docs/ |
| [docs/TESTING.md](docs/TESTING.md) | 2026-09-12 15:45 IST | STEP 8 → FLOWS + checklist |
| [docs/BUILD_AND_RELEASE.md](docs/BUILD_AND_RELEASE.md) | 2026-09-10 23:05 IST | P7 SDK pins |
| [docs/FEATURES.md](docs/FEATURES.md) | 2026-09-10 19:40 IST | offline_temp removed |
| [docs/README.md](docs/README.md) | 2026-09-12 16:00 IST | Checklist under docs; E2E thinned |
| [docs/START_HERE.md](docs/START_HERE.md) | 2026-09-12 15:45 IST | Drop client_req paths |
| [docs/features/D2D_E2E.md](docs/features/D2D_E2E.md) | 2026-09-12 16:00 IST | Thinned to pointer |
| [docs/features/RETURN_BATCH_E2E.md](docs/features/RETURN_BATCH_E2E.md) | 2026-09-12 16:00 IST | Thinned to pointer |
| E2E | D2D_E2E · RETURN_BATCH_E2E | pointer-only; owners = FLOWS + contracts + READMEs |
