# Where code lives (`lib/`)

Quick map for debugging.

- **Per-folder overview:** [docs/FOLDER_SUMMARY.md](../docs/FOLDER_SUMMARY.md)
- **Layout spec:** [docs/LIB_STRUCTURE.md](../docs/LIB_STRUCTURE.md)

## Top-level folders

```text
lib/
├── main.dart
├── api/              # HTTP client, endpoints, connectivity
├── app/              # App shell only (see below)
├── appManager/       # Session, snackbar, colors, config helpers
├── core/             # Sync manager
├── data/             # Login/session impl + local SQLite
├── domain/           # Auth/session contracts + use cases
├── features/         # Product code by area (main debugging zone)
├── models/           # Shared models (User, Cab, Route, Pop, D2D)
├── screens/          # App-wide screens (errors, no internet)
├── theme/            # AppTheme
├── utils/            # Validators, sorting helpers
├── widgets/          # ALL shared UI components
└── offline_temp/     # Offline prototype (separate)
```

## `lib/app/` — bootstrap only (no screens, no widgets)

```text
app/
├── cts_app.dart           # MaterialApp.router
├── app_providers.dart     # Provider DI (single file — no di/ subfolder)
└── router/                # go_router (3 related files)
    ├── app_router.dart
    ├── route_names.dart
    └── session_auth_notifier.dart
```

## Inside each feature

```text
features/batches/
├── screens/
├── forms/
├── providers/
├── models/
└── repositories/
```

**Debug flow:** `screens/` → `providers/` → `repositories/` → `api/`

## Rules

- Shared UI → always `lib/widgets/`
- App-wide pages (not tied to one feature) → `lib/screens/`
- Feature pages → `features/<name>/screens/`
- Do not add `di/`, `presentation/`, or duplicate stub folders
