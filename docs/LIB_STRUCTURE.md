> **Doc:** docs/LIB_STRUCTURE.md
> **Updated:** 2026-08-14 22:00 IST
> **Session:** Verified unchanged

# Library structure (human-friendly)

This document replaces the confusing **Clean Architecture folder names** (`data/`, `domain/`, `presentation/`) with names any developer already knows from the original CTS layout.

**Principle:** *One place per file. Familiar names. Group by business area, not by technical layer at the root.*

---

## Problem with the current migration

The repo ended up with **two structures at once**:

```text
lib/screens/batch_screen.dart          → export stub → features/.../presentation/screens/...
lib/controllers/batch_controller.dart    → export stub → features/.../presentation/providers/...
lib/data/repositories/...              → export stub → features/.../data/repositories/...
```

That makes debugging painful: search hits multiple paths, “Go to definition” lands on a one-line export, and juniors cannot tell which file is real.

---

## Target layout (recommended)

### Root — same mental model as the original app

```text
lib/
├── main.dart
│
├── app/                    # Bootstrap: CtsApp, router, theme, Provider DI
│   ├── cts_app.dart
│   ├── di/app_providers.dart
│   ├── router/
│   ├── theme/
│   └── services/           # Session, snackbar, view state (from appManager)
│
├── api/                    # Network layer (Dio, endpoints, API result types)
│
├── core/                   # Infrastructure devs rarely edit day-to-day
│   ├── network/            # (merge into api/ over time, or keep as impl detail)
│   ├── sync/               # SyncManager
│   └── storage/            # SQLite helpers if split from data/local
│
├── widgets/                # Shared UI (buttons, cards, drawer, shell…)
│
├── models/                 # Shared models ONLY (UserModel, app-wide DTOs)
│
├── screens/                # App-level screens ONLY
│   ├── splash_screen.dart
│   ├── error_page.dart
│   └── no_internet_screen.dart
│
└── features/               # Business modules — main place for product code
    ├── auth/
    ├── batches/
    ├── drivers/
    ├── commuters/
    ├── routes/
    ├── pops/
    ├── cabs/
    ├── admin_home/
    ├── d2d/
    └── profile/
```

### Inside every feature — flat, predictable

```text
features/batches/
├── screens/                # Pages
├── forms/                  # Optional: create/edit UI
├── providers/              # ChangeNotifier classes (old “controllers”)
├── models/                 # batch_model.dart, etc.
└── repositories/           # API + cache; interfaces can live here too
```

| Old name (original app) | New name (inside feature) | Notes |
|-------------------------|---------------------------|--------|
| `screens/` | `features/<x>/screens/` | Scoped per module |
| `controllers/` | `features/<x>/providers/` | Provider package naming |
| `models/` | `features/<x>/models/` | Entity models stay with the feature |
| `api/` calls | `features/<x>/repositories/` | Hides HTTP/SQLite details from UI |

**Do not use** `presentation/`, `domain/`, or `data/` in new code.

---

## Side-by-side: old app vs new app

### Original (easy to read, hard to scale)

```text
lib/
├── api/
├── appManager/
├── controllers/     # all controllers mixed together
├── models/          # all models mixed together
├── screens/         # all screens mixed together
├── widgets/
└── main.dart
```

### Proposed (still easy to read, scales with team size)

```text
lib/
├── api/             # still obvious
├── app/             # appManager split into app + services
├── widgets/         # still obvious
├── models/          # only shared models
├── screens/         # only global screens
└── features/
    └── batches/
        ├── screens/
        ├── providers/
        ├── models/
        └── repositories/
```

**What changed:** screens/controllers/models are **grouped by feature**, not dumped in one giant folder. Everything else keeps familiar names.

---

## Where to look when debugging

| Symptom | Start here |
|---------|------------|
| UI layout / navigation | `features/<name>/screens/` or `app/router/` |
| Button does nothing / state wrong | `features/<name>/providers/` |
| Wrong data / API error | `features/<name>/repositories/` then `api/` |
| Login / session | `app/services/` + `features/auth/` |
| Shared list card, drawer | `widgets/` |
| Offline sync badge | `core/sync/` + `features/batches/repositories/` |

---

## Migration plan (phased)

### Phase A — Stop the confusion (no behavior change)

1. Add this doc + `lib/README.md` (done).
2. **New code only** in `features/<x>/screens|providers|models|repositories/`.
3. Do not add re-export stub files.

### Phase B — Flatten feature internals

For each feature, rename folders (git mv):

| From | To |
|------|-----|
| `presentation/screens/` | `screens/` |
| `presentation/forms/` | `forms/` |
| `presentation/providers/` | `providers/` |
| `domain/models/` | `models/` |
| `domain/repositories/` + `data/repositories/` | `repositories/` |

Update imports + barrel `index.dart` files. Order: `auth` → `splash` → CRUD features → `admin_home` / `d2d` / `profile`.

### Phase C — Collapse legacy root folders

1. Move `shared/widgets/*` → `widgets/` (canonical).
2. Move `appManager/*` → `app/services/` (keep thin re-exports temporarily if needed).
3. Move `core/network/*` implementation under `api/` OR document `api/` as the public import path.
4. Delete stub folders: legacy `screens/`, `controllers/`, duplicate `data/repositories/` exports.

### Phase D — Naming cleanup

| Current | Target |
|---------|--------|
| `BatchController` / `batch_controller.dart` | `BatchProvider` / `batch_provider.dart` |
| `AdminProvider` in `controllers/admin_controller.dart` | `features/admin_home/providers/admin_provider.dart` |
| `AppClass` static globals | `SessionRepository` + providers |

### Phase E — Offline

Either merge `offline_temp/` into feature repositories or isolate it behind a single `features/offline/` module with the same internal layout.

---

## Rules for the team

1. **One canonical path** — no duplicate re-export files.
2. **Feature first** — batch code lives under `features/batches/`, not root `screens/`.
3. **Familiar names** — `screens`, `providers`, `models`, `repositories`, `widgets`, `api`.
4. **Shared only when truly shared** — if only batches use it, keep it in `features/batches/`.
5. **Imports** — prefer `package:cts/features/batches/screens/...`, not `package:cts/screens/...`.

---

## FAQ

**Why not pure layer-based (`screens/` + `controllers/` at root)?**  
With 15+ entities and 3 roles, flat folders become unsearchable. Module folders keep the old names without the sprawl.

**Why `providers/` instead of `controllers/`?**  
The app uses the **Provider** package. File names should match what’s inside (`ChangeNotifier` providers).

**Is Clean Architecture gone?**  
No — repositories still hide API/DB; UI still doesn’t call Dio directly. We only removed jargon from **folder names**.

---

## Related docs

- [ARCHITECTURE.md](./ARCHITECTURE.md) — startup, DI, data flow
- [CODE_MAP.md](./CODE_MAP.md) — file index (update after Phase B)
- [PROJECT_TODOS.md](../PROJECT_TODOS.md) — migration checklist
