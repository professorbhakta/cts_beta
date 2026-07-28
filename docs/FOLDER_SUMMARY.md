# Folder summary — code overview, usage & structure

Agent reference for the CTS (c2s) Flutter app. Describes **what each folder contains**, **how it is used**, and **file layout**.

**Related:** [LIB_STRUCTURE.md](./LIB_STRUCTURE.md) · [ARCHITECTURE.md](./ARCHITECTURE.md) · [lib/README.md](../lib/README.md)

---

## Quick mental model

```text
UI (features/*/screens) → Provider (features/*/providers) → Repository (features/*/repositories) → API (lib/api) / SQLite (lib/data)
```

**Startup:** `main.dart` → DB init → `AppProviders.bootstrapServices()` → `CtsApp` (router + theme + all providers)

**Roles:** ADMIN (CRUD + dashboard), DRIVER (home + batches + D2D), COMMUTER (home + batches)

---

## Root entry points

| File | Purpose |
|------|---------|
| `lib/main.dart` | Production entry: env, `AppDatabase`, `OfflineTempDatabase`, bootstrap services, run `CtsApp` |
| `lib/main_offline.dart` | Debug-only entry: offline temp module without API/sync stack |

---

## `lib/app/` — Application bootstrap

**Overview:** App shell only — no screens, no shared widgets. Wires MaterialApp, theme, router, and Provider DI.

**Usage:** Start here for startup flow, navigation, and global provider registration.

```text
app/
├── cts_app.dart              # MaterialApp.router + MultiProvider + EasyLoading
├── app_providers.dart        # Composition root: all repositories + ChangeNotifiers
└── router/
    ├── app_router.dart       # GoRouter routes, role-based redirects
    ├── route_names.dart      # Path constants, role → home mapping
    └── session_auth_notifier.dart  # Auth state for router refreshListenable
```

| File | Role |
|------|------|
| `cts_app.dart` | Creates `GoRouter`, applies `AppTheme`, registers `AppProviders.build()` |
| `app_providers.dart` | `bootstrapServices()` creates API, sync, offline-first batches, session; `build()` registers ~25 providers |
| `app_router.dart` | Maps paths → screens; guards ADMIN/DRIVER/COMMUTER routes |
| `session_auth_notifier.dart` | Reads session; triggers redirect on login/logout |

---

## `lib/api/` — Network layer

**Overview:** HTTP client (Dio), endpoint paths, connectivity, and typed API results. Single place for outbound network calls.

**Usage:** Repositories call `NetworkApiServices`; never call Dio from screens/providers directly.

```text
api/
├── base_api_services.dart      # Abstract API interface (get/post/put/delete)
├── network_api_services.dart   # Dio implementation (+ inline Dio setup)
├── api_list.dart               # ApiUrl path constants (login, batch, route, cab, etc.)
├── api_result.dart             # Success/failure wrapper for API responses
├── api_exceptions_handler.dart # Maps Dio errors → user-facing messages
├── connectivity_service.dart   # Online/offline stream (connectivity_plus)
└── logging_interceptor.dart    # Request/response logging
```

**Env config:** Base URLs come from `AppConfig` in `appManager/app_class.dart` (`.env` via flutter_dotenv).

---

## `lib/appManager/` — Legacy app helpers

**Overview:** Session globals, colors, snackbars, view state, device utils. Being gradually replaced by `domain/` + `data/` repositories and providers.

**Usage:** Still widely imported for `AppClass` statics, `AppManager` prefs, `ViewState`, `SnackBarService`, theme colors.

```text
appManager/
├── app_class.dart              # AppClass static globals (userId, batchId, etc.) + AppConfig/AppManager
├── session_manager.dart        # Session read/write helpers
├── snackbar_service.dart       # Global scaffold messenger + navigator key
├── view_state.dart             # idle | loading | success | error enum
├── colors.dart                 # Brand color constants
├── functions_and_tools.dart    # Misc helpers
├── device_utils.dart           # Device ID, permissions
├── d2d_route_args.dart         # Route args for D2D WebSocket screen
└── controller_reset_util.dart  # Resets providers on logout
```

---

## `lib/core/` — Infrastructure

**Overview:** Cross-cutting infrastructure not tied to one feature.

**Usage:** Offline sync queue processing; extend here for new infra (storage helpers, etc.).

```text
core/
└── sync/
    └── sync_manager.dart       # Processes SQLite sync queue when back online
```

| Concept | Detail |
|---------|--------|
| `SyncManager` | Listens to connectivity; runs registered handlers per `EntityType` |
| Handlers | Registered by `OfflineFirstBatchRepository.registerSyncHandlers()` |

---

## `lib/data/` — Shared persistence & auth impl

**Overview:** SQLite database, cache, sync queue, and implementations for session/authentication repositories.

**Usage:** Bootstrap initializes `AppDatabase`; auth flows use `AuthenticationRepositoryImpl` / `SessionRepositoryImpl`.

```text
data/
├── repositories/
│   ├── authentication_repository_impl.dart  # Login/signup API calls
│   └── session_repository_impl.dart         # SharedPreferences session storage
└── local/
    ├── database/
    │   ├── app_database.dart       # SQLite singleton + DAO accessors
    │   └── database_schema.dart    # Table definitions
    ├── dao/
    │   ├── cache_dao.dart          # Entity cache CRUD
    │   └── sync_queue_dao.dart     # Offline mutation queue
    ├── cache/
    │   └── cache_service.dart      # High-level cache API for repositories
    ├── models/
    │   └── sync_queue_record.dart  # Queued mutation record
    └── entity_type.dart            # Enum: batch, commuter, etc.
```

---

## `lib/domain/` — Shared contracts & use cases

**Overview:** Repository interfaces and small use cases shared across features (mainly auth/session).

**Usage:** Inject interfaces in providers; implementations live in `data/` or feature `repositories/`.

```text
domain/
├── repositories/
│   ├── authentication_repository.dart  # Login/signup contract
│   └── session_repository.dart         # Session read/write contract
└── usecases/
    └── get_initial_route_usecase.dart  # Splash → sign-in vs role home
```

---

## `lib/features/` — Product modules (main code zone)

**Overview:** Business logic grouped by area. Each feature follows the same flat layout:

```text
features/<name>/
├── screens/        # Pages
├── forms/          # Create/edit forms (CRUD features)
├── providers/      # ChangeNotifier state (old "controllers")
├── models/         # Feature-specific models (when not in lib/models)
├── repositories/   # API + optional cache; interface + impl together
└── utils/          # Feature-only helpers (sort options, etc.)
```

**Debug flow:** `screens/` → `providers/` → `repositories/` → `api/`

---

### `features/auth/`

**Purpose:** Sign in and sign up.

```text
auth/
├── screens/sign_in.dart, sign_up.dart
├── providers/sign_up_sign_in_controller.dart   # SignInProvider, SignUpProvider
```

**Usage:** Public routes `/signIn`, `/signUp`. Uses `AuthenticationRepository`.

---

### `features/splash/`

**Purpose:** Initial loading; resolves session and navigates to correct home.

```text
splash/
├── screens/splash_screen.dart
├── providers/splash_provider.dart              # Uses GetInitialRouteUseCase
```

---

### `features/admin_home/`

**Purpose:** Admin dashboard with entity counts and quick navigation.

```text
admin_home/
├── screens/admin_home_screen.dart
├── providers/admin_provider.dart               # Aggregates counts from all repos
```

**Usage:** ADMIN home after login. Reads batch, commuter, driver, cab, route, pop, running batch repos.

---

### `features/batches/`

**Purpose:** Batch CRUD, running batches, return batches. Only feature with offline-first repository.

```text
batches/
├── screens/
│   ├── batch_screen.dart
│   ├── running_batch_screen.dart
│   └── returning_batch_screen.dart
├── forms/batch_form.dart
├── providers/
│   ├── batch_controller.dart         # BatchProvider — list CRUD
│   ├── batch_form_provider.dart
│   ├── running_batch_provider.dart
│   └── return_batch_provider.dart
├── models/batch_model.dart
├── repositories/
│   ├── batch_repository.dart + batch_repository_impl.dart
│   ├── offline_first_batch_repository.dart   # Cache + sync queue wrapper
│   ├── running_batch_repository.dart + impl
│   └── return_batch_repository.dart + impl
```

**Usage:** Admin batch management; driver/commuter batch views. `OfflineFirstBatchRepository` is the DI default for `BatchRepository`.

---

### `features/cabs/`

**Purpose:** Cab (vehicle) CRUD for admins.

```text
cabs/
├── screens/cab_screen.dart
├── forms/cab_form.dart
├── providers/cab_controller.dart, cab_form_provider.dart
├── repositories/cab_repository.dart + cab_repository_impl.dart
```

**Model:** Shared `lib/models/cab_model.dart`

---

### `features/commuters/`

**Purpose:** Commuter CRUD (admin) and commuter home/batch views.

```text
commuters/
├── screens/
│   ├── commuter_screen.dart          # Admin list
│   ├── commuter_list_screen.dart
│   ├── commuter_home_page.dart       # Commuter role home
│   └── return_batch_commuter_screen.dart
├── forms/commuter_form.dart
├── providers/
│   ├── commuter_controller.dart
│   ├── commuter_form_provider.dart
│   └── commuter_home_provider.dart
├── models/commuter_model.dart
├── utils/commuter_sort_options.dart, commuter_sort_utils.dart
├── repositories/commuter_repository.dart + impl
```

---

### `features/drivers/`

**Purpose:** Driver CRUD (admin) and driver home.

```text
drivers/
├── screens/driver_screen.dart, driver_home_page.dart
├── forms/driver_form.dart
├── providers/
│   ├── driver_controller.dart
│   ├── driver_form_provider.dart
│   └── driver_home_provider.dart
├── models/driver_model.dart
├── utils/driver_sort_options.dart, driver_sort_utils.dart
├── repositories/driver_repository.dart + impl
```

---

### `features/routes/`

**Purpose:** Route CRUD — links batches to paths.

```text
routes/
├── screens/route_screen.dart
├── forms/route_form.dart
├── providers/route_controller.dart, route_form_provider.dart
├── repositories/route_repository.dart + impl
```

**Model:** Shared `lib/models/route_model.dart`

---

### `features/pops/`

**Purpose:** Pick-up point (POP) CRUD.

```text
pops/
├── screens/pop_screen.dart
├── forms/pop_form.dart
├── providers/pop_controller.dart, pop_form_provider.dart
├── repositories/pop_repository.dart + impl
```

**Model:** Shared `lib/models/pop_model.dart`

---

### `features/d2d/`

**Purpose:** Door-to-door live tracking via WebSocket.

```text
d2d/
├── screens/d2d_channel.dart          # Live map/channel UI
├── screens/d2d_log_screen.dart
├── providers/d2d_channel_provider.dart
```

**Usage:** Driver D2D flow. Uses `AppClass.webSocBatchToken`, `d2d_route_args.dart`.

---

### `features/profile/`

**Purpose:** User profile screen (all roles).

```text
profile/
├── screens/profile_screen.dart
```

---

## `lib/models/` — Shared data models

**Overview:** DTOs used by multiple features or repositories. Feature-specific models (batch, commuter, driver) live inside their feature folders.

```text
models/
├── user_model.dart
├── cab_model.dart
├── route_model.dart
├── pop_model.dart
└── d2d_commuter_model.dart
```

**Usage:** Parsed from JSON in repositories; passed to providers/screens.

---

## `lib/widgets/` — Shared UI components

**Overview:** Reusable widgets used across features. Canonical location (not `shared/widgets/`).

**Usage:** Import from `package:cts/widgets/...` for lists, forms, shell layout, loading states.

```text
widgets/
├── dashboard_shell.dart        # Admin layout: drawer/rail + content
├── app_drawer.dart             # Side navigation
├── brand_app_bar.dart          # Top bar for driver/commuter/D2D
├── admin_form_header.dart      # CRUD form title row
├── admin_search_sort_row.dart  # Search + sort toolbar
├── modern_list_card.dart       # List row card + InfoRow helper
├── search_bar_widget.dart
├── sort_dropdown_widget.dart
├── searchable_dropdown.dart
├── common_button.dart
├── common_text_formfield.dart
├── confirmation_dialog.dart
├── loading_indicator.dart
├── skeleton_loader.dart
├── skeleton_list.dart
├── status_message.dart
├── no_data_found.dart
├── headline_widget.dart
├── dashboard_stat_card.dart
├── quick_action_button.dart
└── provider_listener.dart      # Listens to provider ViewState
```

---

## `lib/screens/` — App-wide screens

**Overview:** Screens not owned by a single feature (errors, connectivity).

```text
screens/
├── error_page.dart
└── no_internet_screen.dart
```

**Usage:** `ErrorPage` is the GoRouter `errorBuilder`; `NoInternetScreen` is shown on connectivity loss.

---

## `lib/theme/`

**Overview:** Material theme definitions.

```text
theme/
└── app_theme.dart              # AppTheme.light() / AppTheme.dark()
```

---

## `lib/utils/`

**Overview:** Cross-feature utilities.

```text
utils/
├── validators.dart             # Form validation helpers
├── sort_utils.dart             # Generic sort helpers
├── cab_sort_options.dart
└── pop_sort_options.dart
```

**Note:** Commuter/driver sort utils live in their feature folders.

---

## `lib/design/` — Wireframe gallery (debug only)

**Overview:** Non-production UI prototypes for layout review without backend.

**Usage:** Route `/designWireframes` (debug builds). Not part of production user flows.

```text
design/
├── README.md
└── wireframes/
    ├── wireframe_gallery_screen.dart
    ├── wireframe_catalog.dart
    ├── wireframe_primitives.dart
    └── screens/
        ├── admin_dashboard_wireframe.dart
        ├── auth_sign_in_wireframe.dart
        ├── crud_list_wireframe.dart
        ├── crud_form_wireframe.dart
        ├── driver_home_wireframe.dart
        ├── commuter_home_wireframe.dart
        ├── profile_wireframe.dart
        ├── d2d_live_wireframe.dart
        └── offline_home_wireframe.dart
```

---

## `lib/offline_temp/` — Offline prototype module

**Overview:** Self-contained offline CRUD prototype with its own SQLite DB. Separate from production sync (`core/sync/`).

**Usage:** `main_offline.dart` entry; also reachable from main app router for admin offline routes.

```text
offline_temp/
├── offline_auto_redirect.dart
├── data/
│   ├── offline_temp_database.dart
│   ├── offline_temp_schema.dart
│   ├── offline_temp_repository.dart
│   ├── offline_seed_data.dart
│   └── offline_seed_importer.dart
├── models/
│   ├── offline_batch.dart, offline_commuter.dart
│   ├── offline_route.dart, offline_pop.dart
│   └── offline_commuter_filter.dart
├── providers/offline_temp_provider.dart
├── services/offline_export_service.dart
├── utils/offline_validators.dart, show_offline_text_dialog.dart
├── widgets/offline_commuter_filter_bar.dart
└── screens/
    ├── offline_home_screen.dart
    ├── offline_batches_tab.dart, offline_commuters_tab.dart
    ├── offline_routes_tab.dart, offline_output_tab.dart
    ├── offline_commuter_form_screen.dart
    ├── offline_batch_commuters_screen.dart
    └── offline_route_pops_screen.dart
```

---

## Where to look when debugging

| Symptom | Start here |
|---------|------------|
| Wrong screen / redirect | `app/router/app_router.dart`, `route_names.dart` |
| Button/state not updating | `features/<name>/providers/` |
| API error / wrong payload | `features/<name>/repositories/` → `api/` |
| Login/session issues | `features/auth/`, `data/repositories/session_*`, `domain/` |
| Offline batch not syncing | `features/batches/repositories/offline_first_batch_repository.dart`, `core/sync/` |
| List/card/layout reuse | `widgets/` |
| Admin dashboard counts | `features/admin_home/providers/admin_provider.dart` |
| D2D WebSocket | `features/d2d/`, `appManager/d2d_route_args.dart` |

---

## Provider → Repository map

| Provider | Repository | Feature |
|----------|------------|---------|
| `SignInProvider` / `SignUpProvider` | `AuthenticationRepository` | auth |
| `SplashProvider` | `GetInitialRouteUseCase` → `SessionRepository` | splash |
| `BatchProvider` | `BatchRepository` (offline-first impl) | batches |
| `RunningBatchProvider` | `RunningBatchRepository` | batches |
| `ReturnBatchProvider` | `ReturnBatchRepository` | batches |
| `CabProvider` | `CabRepository` | cabs |
| `DriverProvider` | `DriverRepository` | drivers |
| `DriverHomeProvider` | `DriverRepository` | drivers |
| `CommuterController` | `CommuterRepository` | commuters |
| `CommuterHomeProvider` | `CommuterRepository` | commuters |
| `RouteController` | `RouteRepository` | routes |
| `PopProvider` | `PopRepository` | pops |
| `AdminProvider` | All CRUD + running batch repos | admin_home |
| `D2dChannelProvider` | WebSocket (via provider) | d2d |
| `OfflineTempProvider` | `OfflineTempRepository` | offline_temp |

---

## Migration notes (current state)

- **Target layout:** Feature-first with flat `screens/`, `providers/`, `repositories/` (see [LIB_STRUCTURE.md](./LIB_STRUCTURE.md)).
- **Legacy still present:** `appManager/` globals, `domain/` + `data/` for auth only, duplicate paths in older docs (`shared/widgets/`, `controllers/`).
- **Canonical imports:** `package:cts/features/...`, `package:cts/widgets/...`, `package:cts/api/...`.

---

*Generated from codebase scan. Update when folders move or features are added.*
