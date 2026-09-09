> **Doc:** DOC_REGISTRY.md
> **Updated:** 2026-09-09 18:55 IST
> **Session:** FE match re-verify END sync

# Documentation Registry

Update at **end of every session** ([CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) END PROMPT).

**Attach order is locked** in [PROJECT_BRAIN.md](PROJECT_BRAIN.md) §3 — do not invent a new order each chat.

**Story split:** [05](docs/client_req/05-open-decisions.md) = product story/locks · [DESIGN_SNAPSHOT](docs/client_req/DESIGN_SNAPSHOT.md) = schema/APIs · [FLOWS](docs/FLOWS_BY_ROLE.md) = journeys · [07](docs/client_req/07-NEXT-AGENT-PROMPT.md) = smoke · [DISCUSSION_LOG](docs/client_req/DISCUSSION_LOG.md) = pointer only.

---

## How to update

1. Doc header: **Updated** (IST) + **Session** note.
2. Matching row in **Fast sync** (always) or **On change** (when touched).
3. [PROJECT_BRAIN.md](PROJECT_BRAIN.md) §5 / §6 / §9 (+ §10 map if ownership moved).
4. [PROMPT_SCOPE.md](PROMPT_SCOPE.md) queue + change log.
5. [PROJECT_TODOS.md](PROJECT_TODOS.md) if backlog moved.
6. If client pack is still queue #1: **always** bump DISCUSSION_LOG (`LAST_SUMMARY` + `NEXT_SUGGEST`).
7. No long specs in PROJECT_BRAIN — pointers only.

---

## Fast sync (every session)

| Doc | Last updated | Session note |
|-----|--------------|--------------|
| [CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) | 2026-09-09 18:55 IST | FE match re-verify; next lab migrate |
| [PROJECT_BRAIN.md](PROJECT_BRAIN.md) | 2026-09-09 18:55 IST | §5/§9 return-scan FE_FIX |
| [PROMPT_SCOPE.md](PROMPT_SCOPE.md) | 2026-09-09 18:55 IST | Q-fe-match-be done (re-verify) |
| [DOC_REGISTRY.md](DOC_REGISTRY.md) | 2026-09-09 18:55 IST | FE match re-verify END |
| [docs/client_req/DISCUSSION_LOG.md](docs/client_req/DISCUSSION_LOG.md) | 2026-09-09 18:55 IST | FE match done; lab migrate next |
| [docs/client_req/README.md](docs/client_req/README.md) | 2026-08-26 07:58 IST | read order + snapshot |
| [docs/client_req/DESIGN_SNAPSHOT.md](docs/client_req/DESIGN_SNAPSHOT.md) | 2026-08-26 07:58 IST | Option B inventory |
| [docs/client_req/07-NEXT-AGENT-PROMPT.md](docs/client_req/07-NEXT-AGENT-PROMPT.md) | 2026-08-26 07:53 IST | photo optional smoke |
| [docs/client_req/05-open-decisions.md](docs/client_req/05-open-decisions.md) | 2026-08-26 07:58 IST | + snapshot link |
| [docs/FLOWS_BY_ROLE.md](docs/FLOWS_BY_ROLE.md) | 2026-09-08 23:50 IST | Return QR Phase 2 mint/scan |

---

## Ownership (frozen)

| Concern | Owner |
|---------|--------|
| Session / queue | `PROJECT_BRAIN` + `PROMPT_SCOPE` |
| Docker / LAN / backup / nginx | `docs/LOCAL_DEV.md` |
| REST + WS wire | `docs/API_CONTRACTS.md` |
| Morning D2D + client pack UI | `lib/features/d2d/README.md` |
| Return batch | `lib/features/batches/README.md` |
| Return QR UI / Phase 2 | `docs/setup/RETURN_QR_UI_PREP.md` · `docs/setup/RETURN_TRIP_API_GAP.md` |
| Operator journeys (incl. QR/KM) | `docs/FLOWS_BY_ROLE.md` |
| Schema / APIs inventory | `docs/client_req/DESIGN_SNAPSHOT.md` |
| Product story + D1–D10 | `docs/client_req/05-open-decisions.md` |
| Pack handoff pointer | `docs/client_req/DISCUSSION_LOG.md` |
| Smoke script | `docs/client_req/07-NEXT-AGENT-PROMPT.md` |
| Smoke / test how-to | `docs/TESTING.md` |
| BE module index | `docs/backend/README.md` |
| JWT / discussion status | `docs/setup/DISCUSSION_STATUS.md` · `docs/setup/JWT_LOGIN_IMPLEMENTATION_NOTES.txt` |
| Branch map (FE+BE) | `docs/setup/BRANCH_HOLD_NOTES.md` |
| Setup drafts index | `docs/setup/README.md` · `docs/setup/SCHEMA_FINAL_DRAFT.txt` |
| Admin bootstrap | `docs/setup/ADMIN_BOOTSTRAP_DRAFT.md` · `docs/setup/SQLITE_TABLES_COLUMNS.txt` |

**Full BE↔FE dot table:** [PROJECT_BRAIN.md §10](PROJECT_BRAIN.md#10-deep-docs--stable-befe-map).

**Retired:** `docs/backend/01–04`, `docs/guides/`, client_req `00–04`+`06`, `test/widget_test.dart`.

---

## On change

| Doc | Last updated | Session note |
|-----|--------------|--------------|
| [docs/setup/ADMIN_BOOTSTRAP_DRAFT.md](docs/setup/ADMIN_BOOTSTRAP_DRAFT.md) | 2026-09-09 08:20 IST | FE wired (now on professor-cts) |
| [docs/setup/FE_MATCH_BE_TIP_CONTINUE_PROMPT.txt](docs/setup/FE_MATCH_BE_TIP_CONTINUE_PROMPT.txt) | 2026-09-09 10:10 IST | FE match vs BE tip — next chat START |
| [docs/setup/BRANCH_HOLD_NOTES.md](docs/setup/BRANCH_HOLD_NOTES.md) | 2026-09-09 10:05 IST | FE keep-5 + BE keep-4 remotes |
| [docs/setup/DISCUSSION_STATUS.md](docs/setup/DISCUSSION_STATUS.md) | 2026-09-09 18:10 IST | FE match gap table + FE_FIX |
| [docs/setup/README.md](docs/setup/README.md) | 2026-09-09 10:10 IST | Index FE match continue prompt |
| [docs/setup/CLIENT_RETURN_QR_NOTE.md](docs/setup/CLIENT_RETURN_QR_NOTE.md) | 2026-09-08 20:20 IST | Client: return QR = morning boarding |
| [docs/setup/RETURN_QR_UI_PREP.md](docs/setup/RETURN_QR_UI_PREP.md) | 2026-09-08 23:50 IST | Phase 2 wired |
| [docs/setup/RETURN_TRIP_API_GAP.md](docs/setup/RETURN_TRIP_API_GAP.md) | 2026-09-08 23:50 IST | Dock green-flag contract |
| [docs/LIB_STRUCTURE.md](docs/LIB_STRUCTURE.md) | 2026-08-29 10:02 IST | Target tree aligned to disk; folder law |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 2026-08-29 10:03 IST | Layer mermaid flow names; no folder jargon |
| [docs/LOCAL_DEV.md](docs/LOCAL_DEV.md) | 2026-09-08 12:45 IST | role homes pointer → ROUTING_AND_AUTH |
| [docs/ROUTING_AND_AUTH.md](docs/ROUTING_AND_AUTH.md) | 2026-09-08 15:18 IST | returnBoardingQr / returnBoardingScan prefixes |
| [docs/INTEGRATION.md](docs/INTEGRATION.md) | 2026-09-08 12:45 IST | user types split |
| [docs/CODE_MAP.md](docs/CODE_MAP.md) | 2026-09-08 12:45 IST | AdminCapabilities map |
| [docs/API_CONTRACTS.md](docs/API_CONTRACTS.md) | 2026-09-09 18:10 IST | Login profile stub + bootstrap soft-fail |
| [docs/client_req/DESIGN_SNAPSHOT.md](docs/client_req/DESIGN_SNAPSHOT.md) | 2026-08-31 13:45 IST | return waiting Redis key |
| [docs/FLOWS_BY_ROLE.md](docs/FLOWS_BY_ROLE.md) | 2026-09-08 23:50 IST | Return QR Phase 2 mint/scan |
| [lib/features/batches/README.md](lib/features/batches/README.md) | 2026-09-08 23:50 IST | Phase 2 return QR wired |
| [lib/features/d2d/README.md](lib/features/d2d/README.md) | 2026-09-08 23:50 IST | getBoardingQr({trip}) |
| [PROJECT_TODOS.md](PROJECT_TODOS.md) | 2026-09-08 23:50 IST | return QR Phase 2 done |
| [docs/D2D_PHASE3_CONTINUE_PROMPT.txt](docs/D2D_PHASE3_CONTINUE_PROMPT.txt) | 2026-08-31 13:20 IST | completed — archive reference |
| [docs/TESTING.md](docs/TESTING.md) | 2026-08-25 22:05 IST | → FLOWS smoke |
| [docs/UI_ARCHITECTURE.md](docs/UI_ARCHITECTURE.md) | 2026-09-08 23:50 IST | return QR Phase 2 live |
| [docs/FEATURES.md](docs/FEATURES.md) | 2026-09-08 23:50 IST | return QR Phase 2 |
| [docs/README.md](docs/README.md) | 2026-09-08 15:18 IST | + docs/setup folder |
| [docs/START_HERE.md](docs/START_HERE.md) | 2026-08-25 22:05 IST | FLOWS QR/KM |
| [docs/backend/README.md](docs/backend/README.md) | 2026-08-25 21:50 IST | odo/boarding modules |
| E2E | D2D_E2E · RETURN_BATCH_E2E | when flows change |
