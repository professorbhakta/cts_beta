# Code map

Where code lives and how it connects—**read after** [START_HERE.md](./START_HERE.md).

---

## Top-level `lib/` layout

```
lib/
├── app/                 # Bootstrap: CtsApp, theme, router, Provider DI
├── core/                # Network, sync, shared infrastructure
├── features/            # Feature-first modules (preferred home for new code)
├── shared/widgets/      # Shared UI components
├── design/wireframes/   # Debug layout gallery only
├── offline_temp/        # Offline prototype module
├── appManager/          # Legacy helpers (colors, AppManager, view state)
├── screens/             # Legacy / misc screens
├── controllers/         # Legacy re-exports (migrating to features/)
├── models/              # Shared models (some features have own domain models)
├── domain/              # Shared domain (auth session use cases)
└── data/                # Shared data implementations
```

---

## One feature folder (pattern)

Most features under `lib/features/<name>/`:

```
features/routes/
├── data/           # repositories impl, API calls
├── domain/         # repository interfaces, models
├── presentation/
│   ├── screens/    # RouteScreen, etc.
│   ├── forms/      # RouteForm
│   └── providers/  # RouteController, RouteFormProvider
└── index.dart      # Barrel exports
```

**Rule of thumb:** UI reads/writes through a **Provider** → **Repository** → API or cache.

---

## App startup chain

| Order | File | Role |
|-------|------|------|
| 1 | `main.dart` | `AppProviders.bootstrapServices()` |
| 2 | `lib/app/cts_app.dart` | `MaterialApp.router` + theme |
| 3 | `lib/app/router/app_router.dart` | Routes + auth redirects |
| 4 | `lib/app/di/app_providers.dart` | All `ChangeNotifierProvider`s |

---

## UI shared components (most used)

| Widget | File | Used for |
|--------|------|----------|
| `DashboardShell` | `shared/widgets/dashboard_shell.dart` | Admin screens: drawer / rail + app bar |
| `AppDrawer` / `AdminNavList` | `shared/widgets/app_drawer.dart` | Side navigation |
| `BrandAppBar` | `shared/widgets/brand_app_bar.dart` | Driver / commuter / D2D top bar |
| `SearchBarWidget` | `shared/widgets/search_bar_widget.dart` | CRUD list filter |
| `ModernListCard` | `shared/widgets/modern_list_card.dart` | List rows |
| `StatusMessage` | `shared/widgets/status_message.dart` | Empty / error states |

---

## Routing reference

| Constant | File |
|----------|------|
| Path strings | `lib/app/router/route_names.dart` |
| Route → widget | `lib/app/router/app_router.dart` |
| Role → home | `RouteName.homeForRole(userType)` |

---

## Documentation map

| Topic | Doc |
|-------|-----|
| Start / folder tree | [START_HERE.md](./START_HERE.md) · [FOLDER_GUIDE.md](./FOLDER_GUIDE.md) |
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
