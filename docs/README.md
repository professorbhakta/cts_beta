> **Doc:** docs/README.md
> **Updated:** 2026-08-20 23:40 IST
> **Session:** Wireframes removed (HTML + Flutter debug gallery)

# CTS (c2s) — Documentation

> **New here?** → **[START_HERE.md](./START_HERE.md)** · **Full index:** this file

---

## Folder tree

```text
docs/
├── START_HERE.md          ← begin here
├── README.md              ← full library index (this file)
├── LOCAL_DEV.md           ← Docker + Flutter .env setup
├── GLOSSARY.md            ← terms (D2D, POP, CList, etc.)
├── INTEGRATION.md         ← full-stack overview + diagrams
├── API_CONTRACTS.md       ← REST + WebSocket contracts
├── CHANGELOG_SPRINTS.md   ← completed sprint history
├── backend/               ← Django/Docker deep docs
├── features/              ← E2E flow docs (D2D, return batch)
├── FLOWS_BY_ROLE.md       ← click paths by role
├── UI_ARCHITECTURE.md     ← screens + providers + ASCII layouts
├── CODE_MAP.md            ← where code lives in lib/
├── ARCHITECTURE.md        ← layers, DI, data flow
├── ROUTING_AND_AUTH.md    ← go_router, session, logout/401, no public sign-up
├── OFFLINE_AND_SYNC.md    ← batches sync + offline_temp
├── BUILD_AND_RELEASE.md   ← APK / iOS / .env
├── TESTING.md             ← analyze, test, QA checklists
├── API_AND_ENV.md         ← API_BASE_URL, WebSocket
└── guides/                ← Admin / Driver / Commuter how-tos
```

---

## Read by role

| Role | Start here |
|------|------------|
| Anyone new | [START_HERE.md](./START_HERE.md) |
| Admin operator | [guides/ADMIN_USER_GUIDE.md](./guides/ADMIN_USER_GUIDE.md) |
| Driver | [guides/DRIVER_USER_GUIDE.md](./guides/DRIVER_USER_GUIDE.md) |
| Commuter | [guides/COMMUTER_USER_GUIDE.md](./guides/COMMUTER_USER_GUIDE.md) |
| Developer | [CODE_MAP.md](./CODE_MAP.md) → [ARCHITECTURE.md](./ARCHITECTURE.md) |
| Designer / QA | [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) + [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md) |

---

## Full library

### Onboarding & UI

| Document | Description |
|----------|-------------|
| [START_HERE.md](./START_HERE.md) | Entry paths and 1-minute overview |
| [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) | Click-path diagrams by role |
| [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md) | Navigation matrix, controls, ASCII layouts |
| [CODE_MAP.md](./CODE_MAP.md) | `lib/` folder map |
| [SCREENSHOTS.md](./SCREENSHOTS.md) | Screenshot checklist & assets folder |
| [guides/README.md](./guides/README.md) | Admin / Driver / Commuter how-tos |

### P1 — Architecture & product

| Document | Status |
|----------|--------|
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Published |
| [ROUTING_AND_AUTH.md](./ROUTING_AND_AUTH.md) | Published |
| [FEATURES.md](./FEATURES.md) | Published |
| [DESIGN_SYSTEM_REVIEW.md](./DESIGN_SYSTEM_REVIEW.md) | Published — maintainability + color psychology |

### P2 — Operations

| Document | Status |
|----------|--------|
| [OFFLINE_AND_SYNC.md](./OFFLINE_AND_SYNC.md) | Published |
| [BUILD_AND_RELEASE.md](./BUILD_AND_RELEASE.md) | Published |
| [TESTING.md](./TESTING.md) | Published |
| [API_AND_ENV.md](./API_AND_ENV.md) | Published |
| [API_CONTRACTS.md](./API_CONTRACTS.md) | Published |
| [LOCAL_DEV.md](./LOCAL_DEV.md) | Published |
| [GLOSSARY.md](./GLOSSARY.md) | Published |
| [INTEGRATION.md](./INTEGRATION.md) | Published |
| [CHANGELOG_SPRINTS.md](./CHANGELOG_SPRINTS.md) | Published |
| [backend/](./backend/) | Django/Docker detail |
| [features/](./features/) | D2D + return E2E flows |

### P3 — Guides & visuals

| Item | Status |
|------|--------|
| [guides/](./guides/) role user guides | Done |
| [SCREENSHOTS.md](./SCREENSHOTS.md) | Published (PNG capture optional) |
| HTML / Flutter wireframe galleries | Removed 2026-08-20 |

---

## Related root docs

- [PROJECT_BRAIN.md](../PROJECT_BRAIN.md) — session handoff
- [DOC_REGISTRY.md](../DOC_REGISTRY.md) — sync tracker
- [PROJECT_TODOS.md](../PROJECT_TODOS.md) — backlog
