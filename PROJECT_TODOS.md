# Project Todo & Progress

## Current Status
- [x] Cursor multi-agent system setup completed
- [~] Project architecture migrating to **human-friendly module layout** (see [docs/LIB_STRUCTURE.md](docs/LIB_STRUCTURE.md); Phases 0–7 done; restructure Phases A–E pending)
- [x] State management decision: **keep Provider** (Riverpod deferred)
- [x] Routing: **go_router** with role-protected redirects + deep-link basics
- [x] API layer consolidated under `core/network/`
- [x] APK validation: debug APK built successfully at `build_android/app/outputs/apk/debug/app-debug.apk`
 - [x] Git repository connected / remote verified (`origin` → professorbhakta/cts_beta, branch `beta-ver`)

## Documentation (`docs/`)

**Hub:** [docs/README.md](docs/README.md) · **Start:** [docs/START_HERE.md](docs/START_HERE.md)

### Published

- P0: START_HERE, FOLDER_GUIDE, FLOWS_BY_ROLE, CODE_MAP, UI_ARCHITECTURE, WIREFRAME_GALLERY, wireframes in `lib/design/wireframes/`
- P1: ARCHITECTURE, ROUTING_AND_AUTH, FEATURES, DESIGN_SYSTEM_REVIEW
- P2: OFFLINE_AND_SYNC, BUILD_AND_RELEASE, TESTING, API_AND_ENV
- P3: guides/ (Admin, Driver, Commuter), SCREENSHOTS + assets/screenshots/ category folders (PNGs pending capture)
- **Interactive HTML wireframes:** [docs/wireframes/index.html](docs/wireframes/index.html) (+ styles.css, app.js, DESIGN_SPEC, INTERACTIONS, DOCS_ANALYSIS) — preferred local demo
- Optional Flutter stubs: `lib/design/wireframes/` + debug `/designWireframes` route

### Optional follow-up

- [ ] Commit screenshot PNGs per [docs/SCREENSHOTS.md](docs/SCREENSHOTS.md)
- [ ] Uncomment screenshot embeds in [docs/guides/](docs/guides/)
- [ ] Pilot semantic color tokens from [docs/DESIGN_SYSTEM_REVIEW.md](docs/DESIGN_SYSTEM_REVIEW.md) on Admin dashboard

## Next Features / Tasks

### High Priority
1. [x] Confirm state management approach → **Provider retained**
2. [x] Feature-first migration through Phase 7 (batches)
3. [x] Splash → auth → role routing via go_router guards
4. [~] Offline: SyncManager + drawer badge; entity coverage still `offline_temp` promote (Phase 9)
5. [x] Baseline `flutter pub get`, `flutter analyze`, `flutter test`

### Follow-ups
6. [ ] Replace / harden deprecated or placeholder screens and TODOs in admin CRUD flows
7. [ ] Expand automated tests beyond default `widget_test.dart`
8. [ ] Review API layer (`dio`, cookies, env) for secure config and error handling
9. [x] Phase 7: migrate **batches** (running + return)
10. [x] Pending-sync badge in admin drawer
11. [ ] Phase 8 finish (admin_home, d2d, profile polish) then Phase 9–10
12. [x] APK validation pass: analyze/test clean; Gradle assembleDebug SUCCESS; emulator smoke deferred (emulator stayed offline)

## APK validation notes (2026-07-17)
- Fixed: deprecated `encryptedSharedPreferences` in `session_manager.dart`
- Fixed: Android release missing INTERNET/cleartext + permission declarations
- Fixed: `Connectivity.checkConnectivity()` cast crash risk in `app_class.dart`
- Fixed: CMake SDK mismatch by installing cmake 3.31.6 and pinning in `android/app/build.gradle.kts`
- Remaining: image assets listed in pubspec appear missing from workspace; Firebase Messaging not initialized; API host is LAN-only (`172.20.10.2`)

## Architecture phase progress

| Phase | Status | Notes |
|-------|--------|-------|
| **0** Scaffold `app/`, `shared/`, `features/` | Done | |
| **1** Extract app shell + DI | Done | `lib/app/cts_app.dart`, `lib/app/app_providers.dart` |
| **2** Consolidate `api/` → `core/network` | Done | Canonical in `core/network/`; `lib/api/` re-exports |
| **3** Widgets → `shared/` | Done | Legacy `widgets/` re-exports |
| **4** Splash + auth | Done | `features/splash`, `features/auth` |
| **5** Routes, pops, cabs | Done | `features/routes`, `pops`, `cabs` + `index.dart` barrels |
| **6** Drivers + commuters | Done | CRUD + role homes + list/return screens |
| **7** Batches (running + return) | Done | `features/batches/` + legacy stubs |
| **8** admin_home, d2d, profile | Partial | Migrated earlier |
| **9** Promote offline_temp | Pending | |
| **10** Remove legacy + Reviewer | Pending | Re-export stubs still present |

### Restructure for readability (new — [LIB_STRUCTURE.md](docs/LIB_STRUCTURE.md))

| Phase | Status | Action |
|-------|--------|--------|
| **A** Docs + rules | Done | `docs/LIB_STRUCTURE.md`, `lib/README.md`, `.cursorrules` |
| **B** Flatten feature folders | Done (local) | All features use `screens/`, `providers/`, `models/`, `repositories/`; old `presentation/domain/data` paths are re-export stubs |
| **C** Single canonical root | Pending | `widgets/`, `app/services/`, delete re-export stubs |
| **D** Naming | Pending | `*_provider.dart`, move `AdminProvider`, reduce `AppClass` statics |
| **E** Offline | Pending | Merge or isolate `offline_temp/` |

### Structure after Phase 7
```
lib/
  features/
    batches/          # data / domain / presentation + index.dart
    drivers/, commuters/
    routes/, pops/, cabs/
    splash/, auth/, d2d/, admin_home/, profile/
  core/network/
  shared/widgets/
  screens/, controllers/, models/, domain/, data/  # legacy re-export stubs
```

### Phase 7 highlights
- Batch model, repos (CRUD + offline-first + return + running), providers, screens moved into `features/batches/`
- `RunningBatchRepository` extracted as domain interface; impl in data layer
- Barrel files: `features/batches/index.dart` (+ layer barrels)
- Legacy paths re-export feature modules; `app_router` + `app_providers` import feature paths
- Return-commuter UI stays under `features/commuters` (updated to use feature `ReturnBatchProvider`)

### Offline / sync UI
- Admin drawer: pending/failed counts + Sync now
- Production offline-first for batches remains wired via `OfflineFirstBatchRepository`

### Lint / env
- [x] `flutter analyze` — 0 issues
- [x] `flutter test` — passed

## Build fixes (2026-07-17)
- [x] Fixed Windows assembleDebug blocker: Kotlin incremental cache crash across drives (Pub cache on C:, project on D:)
- [x] Hardened Android Gradle props: `kotlin.incremental=false`, in-process Kotlin, daemon/AAPT2 stability flags
- [x] Upgraded `device_info_plus`, `share_plus`, `flutter_secure_storage` for newer Android plugin support
- [x] Verified `flutter build apk --debug` succeeds (`build\app\outputs\flutter-apk\app-debug.apk`)
- [ ] Optional: enable Windows Developer Mode for symlink-friendly `flutter pub get`; migrate off deprecated `android.builtInKotlin=false` / `android.newDsl=false` when Flutter/plugins allow
