> **Doc:** DOC_REGISTRY.md
> **Updated:** 2026-08-20 23:50 IST
> **Session:** Safe DROP docs prune

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
| [PROJECT_BRAIN.md](PROJECT_BRAIN.md) | 2026-08-20 23:50 IST | DROP prune; next 26d |
| [DOC_REGISTRY.md](DOC_REGISTRY.md) | 2026-08-20 23:50 IST | DROP prune |
| [CHAT_PROMPTS.txt](CHAT_PROMPTS.txt) | 2026-08-20 23:50 IST | Post DROP prune |
| [PROJECT_TODOS.md](PROJECT_TODOS.md) | 2026-08-20 23:50 IST | 26q DROP prune; focus 26d |
| [.cursorrules](.cursorrules) | 2026-08-19 17:55 IST | Verified unchanged |
| [docs/LIB_STRUCTURE.md](docs/LIB_STRUCTURE.md) | 2026-08-20 23:10 IST | offline_module barrel removed note |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 2026-08-19 17:55 IST | Verified unchanged |
| [docs/CODE_MAP.md](docs/CODE_MAP.md) | 2026-08-19 17:55 IST | Verified unchanged |
| [docs/FEATURES.md](docs/FEATURES.md) | 2026-08-19 17:55 IST | Verified unchanged |
| [docs/UI_ARCHITECTURE.md](docs/UI_ARCHITECTURE.md) | 2026-08-19 17:55 IST | Verified unchanged |
| [docs/FLOWS_BY_ROLE.md](docs/FLOWS_BY_ROLE.md) | 2026-08-20 12:20 IST | Verified unchanged |
| [docs/API_AND_ENV.md](docs/API_AND_ENV.md) | 2026-08-19 17:55 IST | Verified unchanged |
| [docs/API_CONTRACTS.md](docs/API_CONTRACTS.md) | 2026-08-20 12:20 IST | Verified unchanged |
| [docs/ROUTING_AND_AUTH.md](docs/ROUTING_AND_AUTH.md) | 2026-08-19 23:25 IST | Verified unchanged |
| [docs/TESTING.md](docs/TESTING.md) | 2026-08-19 23:40 IST | Verified unchanged |
| [lib/features/d2d/README.md](lib/features/d2d/README.md) | 2026-08-19 23:55 IST | Verified unchanged |
| [lib/features/batches/README.md](lib/features/batches/README.md) | 2026-08-20 12:20 IST | Verified unchanged |
| [docs/OFFLINE_AND_SYNC.md](docs/OFFLINE_AND_SYNC.md) | 2026-08-20 00:20 IST | Verified unchanged |
| [docs/LOCAL_DEV.md](docs/LOCAL_DEV.md) | 2026-08-20 22:15 IST | Verified unchanged (lab used 192.168.1.6) |
| [docs/GLOSSARY.md](docs/GLOSSARY.md) | 2026-08-19 17:55 IST | Verified unchanged |

---

## Reference set

Updated when content changes; not verified every session unless touched.

| Doc | Last updated | Notes |
|-----|--------------|-------|
| [docs/README.md](docs/README.md) | 2026-08-14 19:55 IST | Tree includes ROUTING_AND_AUTH |
| [docs/START_HERE.md](docs/START_HERE.md) | 2026-08-14 19:55 IST | Accounts created by admin, not public sign-up |
| [docs/INTEGRATION.md](docs/INTEGRATION.md) | 2026-08-14 21:55 IST | DTODLOG on connect; driver STOP; ADD by user ID |
| [docs/CHANGELOG_SPRINTS.md](docs/CHANGELOG_SPRINTS.md) | — | **Removed** 2026-08-20 |
| [docs/features/D2D_E2E.md](docs/features/D2D_E2E.md) | 2026-08-17 22:15 IST | STOP UX 2-device verified |
| [docs/TESTING.md](docs/TESTING.md) | 2026-08-17 22:15 IST | Wrap; 2-device leftovers passed |
| [docs/features/RETURN_BATCH_E2E.md](docs/features/RETURN_BATCH_E2E.md) | 2026-08-20 12:20 IST | Return list uses isComing pool |
| [docs/backend/](docs/backend/) | 2026-08-20 12:20 IST | Return pool switched to isComing |
| [docs/next-plan/return-trip-allocation-roadmap.txt](docs/next-plan/return-trip-allocation-roadmap.txt) | 2026-08-19 18:25 IST | M4 done; RESUME = M7 |
| [docs/OFFLINE_AND_SYNC.md](docs/OFFLINE_AND_SYNC.md) | 2026-08-20 00:20 IST | P5 degraded mode section |
| [docs/ROUTING_AND_AUTH.md](docs/ROUTING_AND_AUTH.md) | 2026-08-14 19:55 IST | /signUp redirect; sessionid + logout/401 |
| [docs/BUILD_AND_RELEASE.md](docs/BUILD_AND_RELEASE.md) | 2026-08-14 19:55 IST | Release has no cleartext |
| [docs/guides/](docs/guides/) | 2026-08-14 22:00 IST | Driver RETURN LIST confirm/remove |
| [docs/wireframes/](docs/wireframes/) | — | **Removed** 2026-08-20 |
| [lib/README.md](lib/README.md) | 2026-08-05 11:37 IST | CODE_MAP + LIB_STRUCTURE links |

---

## Removed (2026-08-05 cleanup)

- `project-talk-guide/` — entire folder deleted after migration
- `docs/FOLDER_SUMMARY.md`, `docs/FOLDER_GUIDE.md`, `docs/CursorshortCut.md`
- `docs/wireframes/DOCS_ANALYSIS.md`

## Removed (2026-08-20 cleanup)

- `docs/final-gate/` — P1–P9 / Batch-02 phase checklists + smoke prompts (historical; gate closed)
- `qa_lab/`, `qa_screens/` — device UI dumps (gitignored)
- `docs/wireframes/`, `docs/WIREFRAME_GALLERY.md`, `lib/design/` — HTML + Flutter debug galleries
- `docs/CHANGELOG_SPRINTS.md`, `docs/SENIOR_REVIEW_2026-08-19.txt`
- `docs/DESIGN_SYSTEM_REVIEW.md`, `docs/SCREENSHOTS.md`, `docs/assets/screenshots/`
- `docs/backend/05-audit-and-gaps.md`, `docs/backend/06-planned-fixes.md`