> **Doc:** docs/README.md
> **Updated:** 2026-08-25 22:05 IST
> **Session:** FLOWS owns QR/KM journeys

# CTS (c2s) — Documentation

> **New here?** → **[START_HERE.md](./START_HERE.md)** · **Full index:** this file

---

## Folder tree

```text
docs/
├── START_HERE.md
├── README.md
├── LOCAL_DEV.md          ← Docker / LAN / backup (canonical stack)
├── GLOSSARY.md
├── INTEGRATION.md
├── API_CONTRACTS.md      ← REST + WS wire
├── backend/README.md     ← thin pointers only
├── features/
├── next-plan/
├── client_req/           ← QR + KM (log, 05 story, STEP 8 smoke)
├── FLOWS_BY_ROLE.md      ← operator click-paths incl. QR + KM (no guides/)
├── UI_ARCHITECTURE.md
├── CODE_MAP.md
├── ARCHITECTURE.md
├── ROUTING_AND_AUTH.md
├── OFFLINE_AND_SYNC.md
├── BUILD_AND_RELEASE.md
├── TESTING.md
├── API_AND_ENV.md
├── LIB_STRUCTURE.md
└── FEATURES.md
```

---

## Read by role

| Role | Start here |
|------|------------|
| Anyone new | [START_HERE.md](./START_HERE.md) |
| Product / QA / operators | [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) (QR/KM morning + roles) |
| Developer | [CODE_MAP.md](./CODE_MAP.md) → [ARCHITECTURE.md](./ARCHITECTURE.md) |
| Designer | [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) + [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md) |
| Agent / client pack | [DISCUSSION_LOG](./client_req/DISCUSSION_LOG.md) → [05](./client_req/05-open-decisions.md) → FLOWS → [07](./client_req/07-NEXT-AGENT-PROMPT.md) |

---

## Full library

### Onboarding & UI

| Document | Description |
|----------|-------------|
| [START_HERE.md](./START_HERE.md) | Entry paths and 1-minute overview |
| [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) | Click-paths by role + morning QR/KM + smoke table |
| [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md) | Navigation matrix, controls, ASCII layouts |
| [CODE_MAP.md](./CODE_MAP.md) | `lib/` folder map |

### Architecture & product

| Document | Status |
|----------|--------|
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Published |
| [LIB_STRUCTURE.md](./LIB_STRUCTURE.md) | Published |
| [ROUTING_AND_AUTH.md](./ROUTING_AND_AUTH.md) | Published |
| [FEATURES.md](./FEATURES.md) | Published |
| [client_req/README.md](./client_req/README.md) | QR + KM — UI shipped; STEP 8 smoke pending |

### Operations

| Document | Status |
|----------|--------|
| [OFFLINE_AND_SYNC.md](./OFFLINE_AND_SYNC.md) | Published |
| [BUILD_AND_RELEASE.md](./BUILD_AND_RELEASE.md) | Published |
| [TESTING.md](./TESTING.md) | Published |
| [API_AND_ENV.md](./API_AND_ENV.md) | Published |
| [API_CONTRACTS.md](./API_CONTRACTS.md) | Published |
| [LOCAL_DEV.md](./LOCAL_DEV.md) | Canonical Docker/stack |
| [GLOSSARY.md](./GLOSSARY.md) | Published |
| [INTEGRATION.md](./INTEGRATION.md) | Optional overview |
| [backend/README.md](./backend/README.md) | Pointers only |
| [features/](./features/) | D2D + return E2E flows |
| [next-plan/](./next-plan/) | Return allocation roadmap |

---

## Related root docs

- [PROJECT_BRAIN.md](../PROJECT_BRAIN.md) — session handoff
- [DOC_REGISTRY.md](../DOC_REGISTRY.md) — sync tracker
- [PROJECT_TODOS.md](../PROJECT_TODOS.md) — backlog
