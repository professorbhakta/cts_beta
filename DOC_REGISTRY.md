> **Doc:** DOC_REGISTRY.md
> **Updated:** 2026-08-05 11:37 IST
> **Session:** Doc cleanup — added migrated docs, removed talk-guide entries

# Documentation Registry

Central tracker: when each doc was last updated or verified. Update at **end of every session** (see [CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) END PROMPT).

---

## How to update

1. After changing a doc, set its 3-line header: **Updated** timestamp (IST), **Session** note (what changed or "Verified unchanged").
2. Update the matching row in the **Session sync set** table below.
3. Update [PROJECT_BRAIN.md](PROJECT_BRAIN.md) §5 focus, §6 status, §9 session log.
4. If backlog changed, update [PROJECT_TODOS.md](PROJECT_TODOS.md).
5. Do **not** duplicate long specs into PROJECT_BRAIN — pointers only.

---

## Session sync set

Docs that get a header check every session. Attach via task packs in PROJECT_BRAIN §4.

| Doc | Last updated | Session note |
|-----|--------------|--------------|
| [PROJECT_BRAIN.md](PROJECT_BRAIN.md) | 2026-08-05 11:37 IST | Doc cleanup — task packs, §10 pointers |
| [DOC_REGISTRY.md](DOC_REGISTRY.md) | 2026-08-05 11:37 IST | Added migrated docs; removed talk-guide |
| [CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) | 2026-08-05 11:37 IST | Backend pack → LOCAL_DEV + backend/README |
| [PROJECT_TODOS.md](PROJECT_TODOS.md) | 2026-08-05 11:37 IST | Merged open backlog from known-gaps |
| [.cursorrules](.cursorrules) | 2026-08-05 11:30 IST | Verified unchanged |
| [docs/LIB_STRUCTURE.md](docs/LIB_STRUCTURE.md) | 2026-08-05 11:30 IST | Verified unchanged |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 2026-08-05 11:30 IST | Verified unchanged |
| [docs/CODE_MAP.md](docs/CODE_MAP.md) | 2026-08-05 11:37 IST | Replaced FOLDER_GUIDE link with README |
| [docs/FEATURES.md](docs/FEATURES.md) | 2026-08-05 11:30 IST | Verified unchanged |
| [docs/UI_ARCHITECTURE.md](docs/UI_ARCHITECTURE.md) | 2026-08-05 11:30 IST | Verified unchanged |
| [docs/FLOWS_BY_ROLE.md](docs/FLOWS_BY_ROLE.md) | 2026-08-05 11:30 IST | Verified unchanged |
| [docs/API_AND_ENV.md](docs/API_AND_ENV.md) | 2026-08-05 11:30 IST | Verified unchanged |
| [docs/API_CONTRACTS.md](docs/API_CONTRACTS.md) | 2026-08-05 11:37 IST | Fixed backend link path |
| [docs/LOCAL_DEV.md](docs/LOCAL_DEV.md) | 2026-08-05 11:37 IST | Migrated from talk-guide |
| [docs/GLOSSARY.md](docs/GLOSSARY.md) | 2026-08-05 11:37 IST | Migrated from talk-guide |
| [lib/features/d2d/README.md](lib/features/d2d/README.md) | 2026-08-05 11:37 IST | Merged sprint detail from talk-guide |
| [lib/features/batches/README.md](lib/features/batches/README.md) | 2026-08-05 11:37 IST | Merged driver return screen detail |

---

## Reference set

Updated when content changes; not verified every session unless touched.

| Doc | Last updated | Notes |
|-----|--------------|-------|
| [docs/README.md](docs/README.md) | 2026-08-05 11:37 IST | Merged folder tree; added new doc entries |
| [docs/START_HERE.md](docs/START_HERE.md) | 2026-08-05 11:37 IST | Removed FOLDER_GUIDE link |
| [docs/INTEGRATION.md](docs/INTEGRATION.md) | 2026-08-05 11:37 IST | Architecture diagrams + overview |
| [docs/CHANGELOG_SPRINTS.md](docs/CHANGELOG_SPRINTS.md) | 2026-08-05 11:37 IST | Completed sprint history |
| [docs/features/D2D_E2E.md](docs/features/D2D_E2E.md) | 2026-08-05 11:37 IST | Morning E2E flow |
| [docs/features/RETURN_BATCH_E2E.md](docs/features/RETURN_BATCH_E2E.md) | 2026-08-05 11:37 IST | Evening E2E flow |
| [docs/backend/](docs/backend/) | 2026-08-05 11:37 IST | 7 files migrated from talk-guide |
| [docs/OFFLINE_AND_SYNC.md](docs/OFFLINE_AND_SYNC.md) | — | Offline task pack |
| [docs/ROUTING_AND_AUTH.md](docs/ROUTING_AND_AUTH.md) | — | Auth + routes |
| [docs/BUILD_AND_RELEASE.md](docs/BUILD_AND_RELEASE.md) | — | Build / APK |
| [docs/TESTING.md](docs/TESTING.md) | — | Test strategy |
| [docs/guides/](docs/guides/) | 2026-08-05 11:37 IST | Removed FOLDER_GUIDE link |
| [docs/wireframes/](docs/wireframes/) | 2026-08-05 11:37 IST | Removed DOCS_ANALYSIS references |
| [lib/README.md](lib/README.md) | 2026-08-05 11:37 IST | CODE_MAP + LIB_STRUCTURE links |

---

## Removed (2026-08-05 cleanup)

- `project-talk-guide/` — entire folder deleted after migration
- `docs/FOLDER_SUMMARY.md`, `docs/FOLDER_GUIDE.md`, `docs/CursorshortCut.md`
- `docs/wireframes/DOCS_ANALYSIS.md`
