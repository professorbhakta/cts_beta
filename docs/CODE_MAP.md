> **Doc:** docs/CODE_MAP.md
> **Updated:** 2026-08-19 17:55 IST
> **Session:** Verified unchanged

# Code map

Where code lives and how it connects—**read after** [START_HERE.md](./START_HERE.md).

---

## Top-level `lib/` layout

```
lib/
├── app/                 # Bootstrap: CtsApp, router, Provider DI
├── api/                 # HTTP client, endpoints, connectivity
├── core/sync/           # SyncManager (offline queue)
├── features/            # Feature-first modules (main product code)
├── widgets/             # Shared UI components
├── design/wireframes/   # Debug layout gallery only
├── offline_temp/        # Offline prototype module
├── appManager/          # Session globals, colors, snackbar, view state
├── screens/             # App-wide error + no-internet screens
├── models/              # Shared models (User, Cab, Route, Pop, D2D)
├── domain/              # Auth/session contracts + use cases
├── data/                # SQLite, cache, auth/session implementations
├── theme/               # AppTheme
└── utils/               # Validators, sort helpers
```

---

## One feature folder (pattern)

Most features under `lib/features/<name>/`:

```
features/routes/
├── screens/        # RouteScreen, etc.
├── forms/          # RouteForm
├── providers/      # RouteController, RouteFormProvider
└── repositories/   # RouteRepository + impl
```

Import files directly (`package:cts/features/routes/screens/...`). Do not add barrel `index.dart` files.

**Rule of thumb:** UI reads/writes through a **Provider** → **Repository** → API or cache.

---

## App startup chain

| Order | File | Role |
|-------|------|------|
| 1 | `main.dart` | DB init, `AppProviders.bootstrapServices()` |
| 2 | `lib/app/cts_app.dart` | `MaterialApp.router` + theme |
| 3 | `lib/app/router/app_router.dart` | Routes + auth redirects |
| 4 | `lib/app/app_providers.dart` | All `ChangeNotifierProvider`s |

---

## UI shared components (most used)

| Widget | File | Used for |
|--------|------|----------|
| `DashboardShell` | `widgets/dashboard_shell.dart` | Admin screens: drawer / rail + app bar |
| `AppDrawer` / `AdminNavList` | `widgets/app_drawer.dart` | Side navigation |
| `BrandAppBar` | `widgets/brand_app_bar.dart` | Driver / commuter / D2D top bar |
| `SearchBarWidget` | `widgets/search_bar_widget.dart` | CRUD list filter |
| `ModernListCard` | `widgets/modern_list_card.dart` | List rows |
| `StatusMessage` | `widgets/status_message.dart` | Empty / error states |

---

## Routing reference

| Constant | File |
|----------|------|
| Path strings | `lib/app/router/route_names.dart` |
| Route → widget | `lib/app/router/app_router.dart` |
| Role → home | `RouteName.homeForRole(userType)` |

Session cookies: `lib/appManager/session_manager.dart`. Connectivity (cached): `lib/api/connectivity_service.dart`. Auth impl: `lib/data/repositories/authentication_repository_impl.dart`.

---

## Documentation map

| Topic | Doc |
|-------|-----|
| Start / doc index | [START_HERE.md](./START_HERE.md) · [README.md](./README.md) |
| Layers & DI (P1) | [ARCHITECTURE.md](./ARCHITECTURE.md) |
| go_router & roles (P1) | [ROUTING_AND_AUTH.md](./ROUTING_AND_AUTH.md) |
| Feature catalog (P1) | [FEATURES.md](./FEATURES.md) |
| Offline / sync (P2) | [OFFLINE_AND_SYNC.md](./OFFLINE_AND_SYNC.md) |
| Build / API / tests (P2) | [BUILD_AND_RELEASE.md](./BUILD_AND_RELEASE.md) · [API_AND_ENV.md](./API_AND_ENV.md) · [TESTING.md](./TESTING.md) |
| User guides (P3) | [guides/README.md](./guides/README.md) |
| Navigation matrix + wireframes ASCII | [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md) |
| Role journeys | [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) |
| In-app wireframes | [WIREFRAME_GALLERY.md](./WIREFRAME_GALLERY.md) |
| Task tracking | [../PROJECT_TODOS.md](../PROJECT_TODOS.md) |
