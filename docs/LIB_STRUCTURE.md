> **Doc:** docs/LIB_STRUCTURE.md
> **Updated:** 2026-08-29 10:02 IST
> **Session:** Target tree aligned to disk; folder law only

# Library structure (human-friendly)

This document replaces the confusing **Clean Architecture folder names** (`data/`, `domain/`, `presentation/`) with names any developer already knows from the original CTS layout.

**Principle:** *One place per file. Familiar names. Group by business area, not by technical layer at the root.*

---

## Legacy migration (features resolved)

The repo previously had **two structures at once** — root stubs re-exporting into `features/.../presentation/|domain/|data/`. That is **gone on disk**: every feature uses flat `screens/`, `providers/`, `models/`, `repositories/` (plus optional `forms/`, `widgets/`, `helpers/`, `utils/`, `constants/` scoped to one feature).

**Still on disk — legacy only; do not copy into new features:**

```text
lib/data/ + lib/domain/     → shared session/auth (root-level contracts + impl)
lib/appManager/             → session, snackbar, config (target: fold into app/ over time)
lib/core/network/           → one file (`network_action_guard.dart`); HTTP lives in lib/api/
lib/offline_temp/           → prototype offline UI (pending merge or isolation)
```

No re-export stub files remain. **New product code** goes only under `features/<name>/`.

---

## Target layout (recommended)

### Root — same mental model as the original app

```text
lib/
├── main.dart
│
├── app/                    # Bootstrap: CtsApp, router, Provider DI
│   ├── cts_app.dart
│   ├── app_providers.dart  # DI — single file; no di/ subfolder
│   ├── app_lifecycle_host.dart
│   ├── router/
│   └── …                   # session_invalidation, etc.
│
├── api/                    # Network layer (Dio, endpoints, API result types) — canonical HTTP
│
├── core/                   # Infrastructure devs rarely edit day-to-day
│   ├── sync/               # SyncManager
│   ├── lifecycle/          # Foreground / background / resume
│   └── concurrency/        # BatchedRunner
│
├── widgets/                # Shared UI (buttons, cards, drawer, shell…)
│
├── models/                 # Shared models ONLY (UserModel, app-wide DTOs)
│
├── theme/                  # AppTheme / ColorScheme tokens
├── utils/                  # Validators, sort helpers
│
├── screens/                # App-level screens ONLY (errors, no internet)
│   ├── error_page.dart
│   └── no_internet_screen.dart
│
├── data/                   # Legacy shared: session/auth impl + local SQLite (root only)
├── domain/                 # Legacy shared: auth/session contracts + use cases (root only)
├── appManager/             # Legacy session, snackbar, config — migrate to app/ over time
├── offline_temp/           # Offline prototype (pending merge or isolation)
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
    ├── profile/
    └── splash/
```

### Inside every feature — flat, predictable

```text
features/batches/
├── screens/                # Pages
├── forms/                  # Optional: create/edit UI
├── providers/              # ChangeNotifier classes (old “controllers”)
├── models/                 # batch_model.dart, etc.
├── repositories/           # API + cache; interfaces can live here too
├── widgets/                # Optional: feature-scoped UI (e.g. d2d/, batches/)
├── helpers/                # Optional: non-UI helpers scoped to this feature
├── utils/                  # Optional: sort/filter helpers for this feature
└── constants/              # Optional: layout URLs, CSS tokens, etc.
```

| Old name (original app) | New name (inside feature) | Notes |
|-------------------------|---------------------------|--------|
| `screens/` | `features/<x>/screens/` | Scoped per module |
| `controllers/` | `features/<x>/providers/` | Provider package naming |
| `models/` | `features/<x>/models/` | Entity models stay with the feature |
| `api/` calls | `features/<x>/repositories/` | Hides HTTP/SQLite details from UI |

**Do not use** `presentation/`, `domain/`, or `data/` **inside `features/`**. (Root `lib/data/` and `lib/domain/` are legacy shared session/auth — not a pattern for new modules.)

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
├── api/             # still obvious — canonical HTTP (no lib/core/network/ for Dio)
├── app/             # CtsApp, app_providers.dart, router
├── widgets/         # still obvious
├── models/          # only shared models
├── screens/         # only global error / offline screens
├── theme/ + utils/  # app-wide tokens and helpers
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
| Login / session | `features/auth/` + legacy `appManager/` / root `data/` + `domain/` |
| Shared list card, drawer | `widgets/` |
| Offline sync badge | `core/sync/` + `features/batches/repositories/` |

---

## Migration plan (phased)

### Phase A — Stop the confusion (no behavior change)

1. Add this doc + `lib/README.md` (done).
2. **New code only** in `features/<x>/screens|providers|models|repositories/`.
3. Do not add re-export stub files.

### Phase B — Flatten feature internals — **done**

Feature folders on disk use `screens/`, `forms/`, `providers/`, `models/`, `repositories/` only — no `presentation/`, `domain/`, or `data/` subfolders inside `features/`.

(Historical rename map, already applied:)

| From | To |
|------|-----|
| `presentation/screens/` | `screens/` |
| `presentation/forms/` | `forms/` |
| `presentation/providers/` | `providers/` |
| `domain/models/` | `models/` |
| `domain/repositories/` + `data/repositories/` | `repositories/` |

### Phase C — Collapse legacy root folders — **partial**

1. Move `shared/widgets/*` → `widgets/` (canonical) — **done**.
2. Move `appManager/*` → `app/services/` — **open** (`appManager/` still on disk).
3. HTTP under `lib/api/` — **done**; lone `core/network/network_action_guard.dart` may move to `api/` or `core/` root later.
4. Delete stub folders — **done** (no re-export stubs; root `controllers/` gone; `lib/screens/` is error + no-internet only; splash lives in `features/splash/`).

**As of 2026-08-29:** Phase B complete. Phase C items (2) and (3) guard-file tidy still open. `offline_temp/` drawer-scoped; unused `offline_module.dart` barrel removed.

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
No — repositories still hide API/DB; UI still doesn’t call Dio directly. We only removed jargon from **feature folder names**. Root `lib/data/` and `lib/domain/` keep contract/impl split for shared session/auth only.

**Why is `app_providers.dart` directly under `app/`?**  
Startup and DI wiring are documented in [ARCHITECTURE.md](./ARCHITECTURE.md). This file owns **where folders live**, not bootstrap sequence.

---

## Related docs

- [ARCHITECTURE.md](./ARCHITECTURE.md) — startup, DI, data flow (not folder names)
- [CODE_MAP.md](./CODE_MAP.md) — file index (update after major layout moves)
- [PROJECT_TODOS.md](../PROJECT_TODOS.md) — migration checklist
