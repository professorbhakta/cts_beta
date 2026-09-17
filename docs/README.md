> **Doc:** docs/README.md
> **Updated:** 2026-09-12 16:00 IST
> **Session:** Checklist under docs/; E2E thinned

# CTS (c2s) — Documentation

> **New here?** → **[START_HERE.md](./START_HERE.md)** · **Full index:** this file

---

## Folder tree

```text
docs/
├── START_HERE.md
├── README.md
├── LOCAL_DEV.md          ← Docker / LAN / backup + d2d_log module map
├── GLOSSARY.md
├── INTEGRATION.md
├── API_CONTRACTS.md      ← REST + WS wire + schema inventory
├── features/             ← thin E2E pointers only (D2D + return)
├── next-plan/            ← return allocation roadmap
├── setup/                ← JWT / bootstrap / return QR drafts
├── FE_PRODUCTION_INSPECTION_CHECKLIST.md
├── FLOWS_BY_ROLE.md      ← journeys + D1–D10 + smoke short
├── STEP8_DEVICE_SMOKE_CHECKLIST.txt
├── LAB_SMOKE_ISSUES.txt
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
| Product / QA / operators | [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) (QR/KM + D1–D10) |
| Developer | [CODE_MAP.md](./CODE_MAP.md) → [ARCHITECTURE.md](./ARCHITECTURE.md) |
| Designer | [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) + [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md) |
| Agent / STEP 8 | [DISCUSSION_STATUS](./setup/DISCUSSION_STATUS.md) → FLOWS → [STEP8 checklist](./STEP8_DEVICE_SMOKE_CHECKLIST.txt) |

---

## Full library

### Onboarding & UI

| Document | Description |
|----------|-------------|
| [START_HERE.md](./START_HERE.md) | Entry paths and 1-minute overview |
| [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) | Click-paths + product locks + smoke short |
| [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md) | Navigation matrix, controls, ASCII layouts |
| [CODE_MAP.md](./CODE_MAP.md) | `lib/` folder map |

### Architecture & product

| Document | Status |
|----------|--------|
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Published |
| [LIB_STRUCTURE.md](./LIB_STRUCTURE.md) | Published |
| [ROUTING_AND_AUTH.md](./ROUTING_AND_AUTH.md) | Published |
| [FEATURES.md](./FEATURES.md) | Published |

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
| [setup/](./setup/) | JWT · bootstrap · return QR drafts |
| [features/](./features/) | Thin E2E pointers → FLOWS + contracts + READMEs |
| [FE_PRODUCTION_INSPECTION_CHECKLIST.md](./FE_PRODUCTION_INSPECTION_CHECKLIST.md) | FE prod inspection (P8 on go) |
| [next-plan/](./next-plan/) | Return allocation roadmap |

---

## Related root docs

- [PROJECT_BRAIN.md](../PROJECT_BRAIN.md) — session handoff
- [DOC_REGISTRY.md](../DOC_REGISTRY.md) — sync tracker
- [PROJECT_TODOS.md](../PROJECT_TODOS.md) — backlog
