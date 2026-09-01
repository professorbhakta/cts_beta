> **Doc:** docs/ARCHITECTURE.md
> **Updated:** 2026-08-29 10:03 IST
> **Session:** Layer mermaid → flow names; no folder jargon

# Architecture

How the CTS (c2s) Flutter app is structured: layers, startup, dependency injection, and data flow.

**See also:** [LIB_STRUCTURE.md](./LIB_STRUCTURE.md) · [CODE_MAP.md](./CODE_MAP.md) · [ROUTING_AND_AUTH.md](./ROUTING_AND_AUTH.md) · [FEATURES.md](./FEATURES.md)

---

## Goals

- **Single codebase** for iOS and Android
- **Module-based layout** under `lib/features/` with familiar folders: `screens/`, `providers/`, `models/`, `repositories/` (see [LIB_STRUCTURE.md](./LIB_STRUCTURE.md))
- **Separation of concerns** — UI → Provider → Repository → API (without `data/domain/presentation` folder jargon)
- **Provider** (`ChangeNotifier`) for app-wide state
- **go_router** for navigation and role guards
- **One canonical path per file** — no re-export stub folders

---

## Startup sequence

```mermaid
sequenceDiagram
  participant main as main.dart
  participant cfg as AppConfig
  participant db as AppDatabase
  participant boot as AppProviders.bootstrapServices
  participant app as CtsApp

  main->>cfg: initialize (.env)
  main->>db: initialize
  main->>boot: api, connectivity, sync, session
  main->>app: runApp(MultiProvider + GoRouter)
```

| Step | Code | Responsibility |
|------|------|----------------|
| 1 | `lib/main.dart` | `WidgetsFlutterBinding`, DB init, bootstrap |
| 2 | `AppConfig.initialize()` | `.env` → API / WebSocket URLs |
| 3 | `AppDatabase` / `OfflineTempDatabase` | SQLite for cache, sync queue, offline temp |
| 4 | `AppProviders.bootstrapServices()` | Network, `SyncManager`, offline-first batches, `SessionAuthNotifier` |
| 5 | `CtsApp` | `MaterialApp.router`, theme, global providers |

---

## Layer diagram

Runtime flow — **not folder names**. On disk, use `features/<name>/screens|providers|models|repositories/` ([LIB_STRUCTURE.md](./LIB_STRUCTURE.md)).

```mermaid
flowchart TB
  subgraph screen [Screen]
    Screens[Screens and Forms]
  end

  subgraph provider [Provider]
    Providers[ChangeNotifier Providers]
  end

  subgraph repository [Repository]
    RepoIf[Repository interfaces]
    RepoImpl[Repository implementations]
    Models[Models]
    UseCases[Use cases e.g. GetInitialRoute]
  end

  subgraph api [API]
    HTTP[NetworkApiServices Dio]
    Local[SQLite cache sync queue]
  end

  Screens --> Providers
  Providers --> RepoIf
  RepoImpl --> RepoIf
  RepoImpl --> HTTP
  RepoImpl --> Local
  UseCases --> RepoIf
```

---

## `lib/` layout

**Human-readable map:** [LIB_STRUCTURE.md](./LIB_STRUCTURE.md) · on-boarding: [../lib/README.md](../lib/README.md)

| Path | Role |
|------|------|
| `lib/app/` | `CtsApp`, theme, router, `AppProviders` |
| `lib/api/` | HTTP client, endpoints, API helpers (canonical; there is no `lib/core/network/` for Dio) |
| `lib/core/sync/` | `SyncManager` — offline mutation queue |
| `lib/features/<name>/` | Business modules: `screens/`, `providers/`, `models/`, `repositories/` — **never** `data/`, `domain/`, or `presentation/` here |
| `lib/widgets/` | Shared UI (canonical) |
| `lib/models/` | Shared models only (e.g. `UserModel`) |
| `lib/screens/` | App-level error / offline screens only |
| `lib/data/` | **Legacy shared only** — session/auth impl + local DB; do **not** copy this pattern into new features |
| `lib/domain/` | **Legacy shared only** — auth/session contracts + use cases; do **not** copy this pattern into new features |
| `lib/offline_temp/` | Prototype offline UI (pending merge or isolation) |
| `lib/appManager/`, legacy `controllers/`, duplicate `screens/` | **Being removed** — re-export stubs only; do not add code here |

---

## Dependency injection (Provider)

All providers are registered in [`lib/app/app_providers.dart`](../lib/app/app_providers.dart).

| Kind | Examples |
|------|----------|
| `Provider<T>` | `BaseApiServices`, repositories, use cases |
| `ChangeNotifierProvider` | Feature controllers, `SyncManager`, `SessionAuthNotifier` |
| `ChangeNotifierProvider` (singleton) | Pre-bootstrapped `OfflineFirstBatchRepository`, `SessionAuthNotifier` |

**Pattern:** Screens call `context.read<X>()` in `initState` / actions and `context.watch` / `Consumer` in build.

**State management:** Provider (`ChangeNotifier`) only — do not introduce Riverpod.

---

## Data flow (typical CRUD feature)

1. **Screen** `initState` → `controller.fetchItems()`
2. **Controller** sets `ViewState.loading` → calls **Repository**
3. **Repository** → Dio API (or cache when offline-first)
4. Controller sets `success` / `error`, `notifyListeners()`
5. **UI** `Consumer` rebuilds: skeleton → list or `StatusMessage`
6. **Form** uses a separate app-scoped `*FormProvider` (`forUpdate` / `updateId` + controllers). Dashboard **Add** and list **+** call `clearAll()` before `push` so create does not PATCH the last edit. Submit → controller create/update → `context.pop()`. List swipe-edit passes the **row model**, not a sorted index.

---

## Offline-first (production scope today)

Only **batches** use full offline-first + sync queue via `OfflineFirstBatchRepository` (see [OFFLINE_AND_SYNC.md](./OFFLINE_AND_SYNC.md)).

Other entities are online-first with standard repositories.

---

## Cross-cutting concerns

| Concern | Location |
|---------|----------|
| UI loading/error states | `ViewState` in `lib/appManager/view_state.dart` |
| Snackbars | `SnackBarService` + global keys |
| Session persistence | `SessionRepositoryImpl` + `SessionManager` (secure storage, in-memory after first read) |
| Auth API | `AuthenticationRepositoryImpl` — public sign-up disabled |
| 401 / logout | `NetworkApiServices` + `AppManager.clearLocalSession()` |
| Connectivity | One `ConnectivityService`; `isOnline` cached — do not add extra listeners |
| Controller reset on logout | `ControllerResetUtil` |

---

## Adding a new feature (checklist)

1. Create `lib/features/<name>/` with `screens/`, `providers/`, `models/`, `repositories/` (see [LIB_STRUCTURE.md](./LIB_STRUCTURE.md)). Do **not** add `data/`, `domain/`, or `presentation/` inside a feature.
2. Add repository interface + impl under `repositories/`
3. Register `Provider` + `ChangeNotifierProvider`s in [`lib/app/app_providers.dart`](../lib/app/app_providers.dart)
4. Add routes in `route_names.dart` and `app_router.dart`
5. Update [FEATURES.md](./FEATURES.md) and [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md)

Root `lib/data/` and `lib/domain/` stay **shared auth/session + local DB only** — not a template for new product features.
