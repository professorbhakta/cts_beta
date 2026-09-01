> **Doc:** DOC_REGISTRY.md
> **Updated:** 2026-09-01 10:20 IST
> **Session:** Doc header sync — API_CONTRACTS, feature READMEs, FLOWS, TODOS

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
| [PROJECT_BRAIN.md](PROJECT_BRAIN.md) | 2026-08-31 13:45 IST | Phase 3 done; STEP 8 next on go |
| [PROMPT_SCOPE.md](PROMPT_SCOPE.md) | 2026-09-01 10:20 IST | doc sync changelog |
| [DOC_REGISTRY.md](DOC_REGISTRY.md) | 2026-08-31 13:45 IST | Phase 3 END sync |
| [CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) | 2026-08-31 13:45 IST | MIDDLE CONTEXT — Phase 3 done |
| [docs/client_req/DISCUSSION_LOG.md](docs/client_req/DISCUSSION_LOG.md) | 2026-08-31 13:45 IST | pointer → STEP 8 |
| [docs/client_req/README.md](docs/client_req/README.md) | 2026-08-26 07:58 IST | read order + snapshot |
| [docs/client_req/DESIGN_SNAPSHOT.md](docs/client_req/DESIGN_SNAPSHOT.md) | 2026-08-26 07:58 IST | Option B inventory |
| [docs/client_req/07-NEXT-AGENT-PROMPT.md](docs/client_req/07-NEXT-AGENT-PROMPT.md) | 2026-08-26 07:53 IST | photo optional smoke |
| [docs/client_req/05-open-decisions.md](docs/client_req/05-open-decisions.md) | 2026-08-26 07:58 IST | + snapshot link |
| [docs/FLOWS_BY_ROLE.md](docs/FLOWS_BY_ROLE.md) | 2026-09-01 10:20 IST | return waiting line + commuter join |

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
| Product story + D1–D10 | `docs/client_req/05-open-decisions.md` |
| Pack handoff pointer | `docs/client_req/DISCUSSION_LOG.md` |
| Smoke script | `docs/client_req/07-NEXT-AGENT-PROMPT.md` |
| Smoke / test how-to | `docs/TESTING.md` |
| BE module index | `docs/backend/README.md` |

**Full BE↔FE dot table:** [PROJECT_BRAIN.md §10](PROJECT_BRAIN.md#10-deep-docs--stable-befe-map).

**Retired:** `docs/backend/01–04`, `docs/guides/`, client_req `00–04`+`06`, `test/widget_test.dart`.

---

## On change

| Doc | Last updated | Session note |
|-----|--------------|--------------|
| [docs/LIB_STRUCTURE.md](docs/LIB_STRUCTURE.md) | 2026-08-29 10:02 IST | Target tree aligned to disk; folder law |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 2026-08-29 10:03 IST | Layer mermaid flow names; no folder jargon |
| [docs/LOCAL_DEV.md](docs/LOCAL_DEV.md) | 2026-08-25 21:36 IST | canonical stack |
| [docs/API_CONTRACTS.md](docs/API_CONTRACTS.md) | 2026-09-01 10:20 IST | view/ waiting[] JSON example + header sync |
| [docs/client_req/DESIGN_SNAPSHOT.md](docs/client_req/DESIGN_SNAPSHOT.md) | 2026-08-31 13:45 IST | return waiting Redis key |
| [docs/FLOWS_BY_ROLE.md](docs/FLOWS_BY_ROLE.md) | 2026-09-01 10:20 IST | return waiting line + commuter join |
| [lib/features/batches/README.md](lib/features/batches/README.md) | 2026-09-01 10:20 IST | Phase 3 return waiting shipped |
| [lib/features/d2d/README.md](lib/features/d2d/README.md) | 2026-09-01 10:20 IST | Phase 1+2 morning waiting + scan join_waiting |
| [PROJECT_TODOS.md](PROJECT_TODOS.md) | 2026-09-01 10:20 IST | test count 128; analyze note |
| [docs/D2D_PHASE3_CONTINUE_PROMPT.txt](docs/D2D_PHASE3_CONTINUE_PROMPT.txt) | 2026-08-31 13:20 IST | completed — archive reference |
| [docs/TESTING.md](docs/TESTING.md) | 2026-08-25 22:05 IST | → FLOWS smoke |
| [docs/UI_ARCHITECTURE.md](docs/UI_ARCHITECTURE.md) | 2026-08-25 22:05 IST | + `/boardingScan` |
| [docs/README.md](docs/README.md) | 2026-08-25 22:05 IST | FLOWS QR/KM |
| [docs/START_HERE.md](docs/START_HERE.md) | 2026-08-25 22:05 IST | FLOWS QR/KM |
| [docs/backend/README.md](docs/backend/README.md) | 2026-08-25 21:50 IST | odo/boarding modules |
| [docs/FEATURES.md](docs/FEATURES.md) | 2026-08-25 21:06 IST | + client pack routes |
| E2E | D2D_E2E · RETURN_BATCH_E2E | when flows change |
