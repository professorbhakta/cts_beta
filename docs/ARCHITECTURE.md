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

```mermaid
flowchart TB
  subgraph presentation [Presentation]
    Screens[Screens and Forms]
    Providers[ChangeNotifier Providers]
    Screens --> Providers
  end

  subgraph domain [Domain]
    RepoIf[Repository interfaces]
    Models[Domain models]
    UseCases[Use cases e.g. GetInitialRoute]
  end

  subgraph data [Data]
    RepoImpl[Repository implementations]
    API[NetworkApiServices Dio]
    Local[SQLite cache sync queue]
  end

  Providers --> RepoIf
  RepoImpl --> RepoIf
  RepoImpl --> API
  RepoImpl --> Local
  UseCases --> RepoIf
```

---

## `lib/` layout

**Human-readable map:** [LIB_STRUCTURE.md](./LIB_STRUCTURE.md) · on-boarding: [../lib/README.md](../lib/README.md)

| Path | Role |
|------|------|
| `lib/app/` | `CtsApp`, theme, router, `AppProviders` |
| `lib/api/` | HTTP client, endpoints, API helpers |
| `lib/core/sync/` | `SyncManager` — offline mutation queue |
| `lib/core/network/` | Dio implementation (import via `api/` where possible) |
| `lib/features/<name>/` | Business modules: `screens/`, `providers/`, `models/`, `repositories/` |
| `lib/widgets/` | Shared UI (canonical; `shared/widgets/` merging here) |
| `lib/models/` | Shared models only (e.g. `UserModel`) |
| `lib/screens/` | App-level screens only (splash, errors) |
| `lib/data/` | Shared session/auth impl + local DB (app infrastructure) |
| `lib/domain/` | Shared auth/session contracts + use cases |
| `lib/offline_temp/` | Prototype offline UI (pending merge or isolation) |
| `lib/design/wireframes/` | Debug layout gallery only |
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

**Decision (documented in code):** Riverpod deferred; Provider kept for migration cost vs benefit.

---

## Data flow (typical CRUD feature)

1. **Screen** `initState` → `controller.fetchItems()`
2. **Controller** sets `ViewState.loading` → calls **Repository**
3. **Repository** → Dio API (or cache when offline-first)
4. Controller sets `success` / `error`, `notifyListeners()`
5. **UI** `Consumer` rebuilds: skeleton → list or `StatusMessage`
6. **Form** uses separate `*FormProvider` for controllers; submit → controller create/update → `context.pop()`

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
| Session persistence | `SessionRepositoryImpl`, secure/local storage |
| Auth API | `AuthenticationRepositoryImpl` |
| Controller reset on logout | `ControllerResetUtil` |

---

## Adding a new feature (checklist)

1. Create `lib/features/<name>/` with `data`, `domain`, `presentation`
2. Add repository interface + impl
3. Register `Provider` + `ChangeNotifierProvider`s in `app_providers.dart`
4. Add routes in `route_names.dart` and `app_router.dart`
5. Update [FEATURES.md](./FEATURES.md) and [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md)
