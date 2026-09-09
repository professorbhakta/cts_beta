> **Doc:** DOC_REGISTRY.md
> **Updated:** 2026-09-09 08:20 IST
> **Session:** Return QR client lock (morning parity); discuss-only

# Documentation Registry

Update at **end of every session** ([CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) END PROMPT).

**Attach order is locked** in [PROJECT_BRAIN.md](PROJECT_BRAIN.md) Ãƒâ€šÃ‚Â§3 ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â do not invent a new order each chat.

**Story split:** [05](docs/client_req/05-open-decisions.md) = product story/locks Ãƒâ€šÃ‚Â· [DESIGN_SNAPSHOT](docs/client_req/DESIGN_SNAPSHOT.md) = schema/APIs Ãƒâ€šÃ‚Â· [FLOWS](docs/FLOWS_BY_ROLE.md) = journeys Ãƒâ€šÃ‚Â· [07](docs/client_req/07-NEXT-AGENT-PROMPT.md) = smoke Ãƒâ€šÃ‚Â· [DISCUSSION_LOG](docs/client_req/DISCUSSION_LOG.md) = pointer only.

---

## How to update

1. Doc header: **Updated** (IST) + **Session** note.
2. Matching row in **Fast sync** (always) or **On change** (when touched).
3. [PROJECT_BRAIN.md](PROJECT_BRAIN.md) Ãƒâ€šÃ‚Â§5 / Ãƒâ€šÃ‚Â§6 / Ãƒâ€šÃ‚Â§9 (+ Ãƒâ€šÃ‚Â§10 map if ownership moved).
4. [PROMPT_SCOPE.md](PROMPT_SCOPE.md) queue + change log.
5. [PROJECT_TODOS.md](PROJECT_TODOS.md) if backlog moved.
6. If client pack is still queue #1: **always** bump DISCUSSION_LOG (`LAST_SUMMARY` + `NEXT_SUGGEST`).
7. No long specs in PROJECT_BRAIN ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â pointers only.

---

## Fast sync (every session)

| Doc | Last updated | Session note |
|-----|--------------|--------------|
| [PROJECT_BRAIN.md](PROJECT_BRAIN.md) | 2026-09-08 12:45 IST | Role homes + AdminService pointer |
| [PROMPT_SCOPE.md](PROMPT_SCOPE.md) | 2026-09-08 12:45 IST | role UI routing changelog |
| [DOC_REGISTRY.md](DOC_REGISTRY.md) | 2026-09-08 20:20 IST | Return QR client lock discuss |
| [CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) | 2026-08-31 13:45 IST | MIDDLE CONTEXT â€” Phase 3 done |
| [docs/client_req/DISCUSSION_LOG.md](docs/client_req/DISCUSSION_LOG.md) | 2026-08-31 13:45 IST | pointer â†’ STEP 8 |
| [docs/client_req/README.md](docs/client_req/README.md) | 2026-08-26 07:58 IST | read order + snapshot |
| [docs/client_req/DESIGN_SNAPSHOT.md](docs/client_req/DESIGN_SNAPSHOT.md) | 2026-08-26 07:58 IST | Option B inventory |
| [docs/client_req/07-NEXT-AGENT-PROMPT.md](docs/client_req/07-NEXT-AGENT-PROMPT.md) | 2026-08-26 07:53 IST | photo optional smoke |
| [docs/client_req/05-open-decisions.md](docs/client_req/05-open-decisions.md) | 2026-08-26 07:58 IST | + snapshot link |
| [docs/FLOWS_BY_ROLE.md](docs/FLOWS_BY_ROLE.md) | 2026-09-08 12:45 IST | Admin shell roles â€” SUPERVISOR / STAFF |

---

## Ownership (frozen)

| Concern | Owner |
|---------|--------|
| Session / queue | `PROJECT_BRAIN` + `PROMPT_SCOPE` |
| Docker / LAN / backup / nginx | `docs/LOCAL_DEV.md` |
| REST + WS wire | `docs/API_CONTRACTS.md` |
| Morning D2D + client pack UI | `lib/features/d2d/README.md` |
| Return batch | `lib/features/batches/README.md` |
| Operator journeys (incl. QR/KM) | `docs/FLOWS_BY_ROLE.md` |
| Schema / APIs inventory | `docs/client_req/DESIGN_SNAPSHOT.md` |
| Product story + D1ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Å“D10 | `docs/client_req/05-open-decisions.md` |
| Pack handoff pointer | `docs/client_req/DISCUSSION_LOG.md` |
| Smoke script | `docs/client_req/07-NEXT-AGENT-PROMPT.md` |
| Smoke / test how-to | `docs/TESTING.md` |
| BE module index | `docs/backend/README.md` |
| JWT / discussion status | `docs/setup/DISCUSSION_STATUS.md` Â· `docs/setup/JWT_LOGIN_IMPLEMENTATION_NOTES.txt` |
| Setup drafts index | `docs/setup/README.md` Â· `docs/setup/SCHEMA_FINAL_DRAFT.txt` |
| Admin bootstrap | `docs/setup/ADMIN_BOOTSTRAP_DRAFT.md` · `docs/setup/SQLITE_TABLES_COLUMNS.txt` |

**Full BEÃƒÂ¢Ã¢â‚¬Â Ã¢â‚¬ÂFE dot table:** [PROJECT_BRAIN.md Ãƒâ€šÃ‚Â§10](PROJECT_BRAIN.md#10-deep-docs--stable-befe-map).

**Retired:** `docs/backend/01ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Å“04`, `docs/guides/`, client_req `00ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Å“04`+`06`, `test/widget_test.dart`.

---

## On change

| Doc | Last updated | Session note |
|-----|--------------|--------------|
| [docs/setup/ADMIN_BOOTSTRAP_DRAFT.md](docs/setup/ADMIN_BOOTSTRAP_DRAFT.md) | 2026-09-09 08:20 IST | FE wired on feat/admin-bootstrap |
| [docs/setup/DISCUSSION_STATUS.md](docs/setup/DISCUSSION_STATUS.md) | 2026-09-08 20:20 IST | Return QR client lock; F&D hold FE |
| [docs/setup/README.md](docs/setup/README.md) | 2026-09-08 20:20 IST | Index CLIENT_RETURN_QR_NOTE |
| [docs/setup/CLIENT_RETURN_QR_NOTE.md](docs/setup/CLIENT_RETURN_QR_NOTE.md) | 2026-09-08 20:20 IST | Client: return QR = morning boarding (discuss) |
| [docs/LIB_STRUCTURE.md](docs/LIB_STRUCTURE.md) | 2026-08-29 10:02 IST | Target tree aligned to disk; folder law |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 2026-08-29 10:03 IST | Layer mermaid flow names; no folder jargon |
| [docs/LOCAL_DEV.md](docs/LOCAL_DEV.md) | 2026-09-08 12:45 IST | role homes pointer â†’ ROUTING_AND_AUTH |
| [docs/ROUTING_AND_AUTH.md](docs/ROUTING_AND_AUTH.md) | 2026-09-08 12:45 IST | STAFFâ†’commuter; SUPERVISOR AdminService allow-list |
| [docs/INTEGRATION.md](docs/INTEGRATION.md) | 2026-09-08 12:45 IST | user types split |
| [docs/CODE_MAP.md](docs/CODE_MAP.md) | 2026-09-08 12:45 IST | AdminCapabilities map |
| [docs/API_CONTRACTS.md](docs/API_CONTRACTS.md) | 2026-09-09 08:20 IST | Admin bootstrap GET contract + FE wired |
| [docs/client_req/DESIGN_SNAPSHOT.md](docs/client_req/DESIGN_SNAPSHOT.md) | 2026-08-31 13:45 IST | return waiting Redis key |
| [docs/FLOWS_BY_ROLE.md](docs/FLOWS_BY_ROLE.md) | 2026-09-08 12:45 IST | Admin shell roles note |
| [lib/features/batches/README.md](lib/features/batches/README.md) | 2026-09-01 10:20 IST | Phase 3 return waiting shipped |
| [lib/features/d2d/README.md](lib/features/d2d/README.md) | 2026-09-01 10:20 IST | Phase 1+2 morning waiting + scan join_waiting |
| [PROJECT_TODOS.md](PROJECT_TODOS.md) | 2026-09-01 10:20 IST | test count 128; analyze note |
| [docs/D2D_PHASE3_CONTINUE_PROMPT.txt](docs/D2D_PHASE3_CONTINUE_PROMPT.txt) | 2026-08-31 13:20 IST | completed ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â archive reference |
| [docs/TESTING.md](docs/TESTING.md) | 2026-08-25 22:05 IST | ÃƒÂ¢Ã¢â‚¬Â Ã¢â‚¬â„¢ FLOWS smoke |
| [docs/UI_ARCHITECTURE.md](docs/UI_ARCHITECTURE.md) | 2026-08-25 22:05 IST | + `/boardingScan` |
| [docs/README.md](docs/README.md) | 2026-08-25 22:05 IST | FLOWS QR/KM |
| [docs/START_HERE.md](docs/START_HERE.md) | 2026-08-25 22:05 IST | FLOWS QR/KM |
| [docs/backend/README.md](docs/backend/README.md) | 2026-08-25 21:50 IST | odo/boarding modules |
| [docs/FEATURES.md](docs/FEATURES.md) | 2026-09-08 12:45 IST | admin_home supervisor note |
| E2E | D2D_E2E Â· RETURN_BATCH_E2E | when flows change |
| [docs/FEATURES.md](docs/FEATURES.md) | 2026-08-25 21:06 IST | + client pack routes |
| E2E | D2D_E2E Ãƒâ€šÃ‚Â· RETURN_BATCH_E2E | when flows change |



| docs/setup/CREAM_BOARD_SCHEMA_UI.md | Cream-board list/form map + Phase A role homes (STAFF=commuter; SUPERVISOR=shared admin shell; no separate Supervisor UI) (Sat) |
| docs/ROUTING_AND_AUTH.md | Role homes + AdminService allow-list (SUPERVISOR shared shell; STAFFâ†’commuter) |
