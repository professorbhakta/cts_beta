> **Doc:** PROJECT_TODOS.md
> **Updated:** 2026-08-14 22:00 IST
> **Session:** Driver return ADD done; R5 STOP flush still open

# Project Todo & Progress

**Session entry:** [PROJECT_BRAIN.md](PROJECT_BRAIN.md) · **Doc tracker:** [DOC_REGISTRY.md](DOC_REGISTRY.md) · **Chat templates:** [CHAT_PROMPTS.txt](CHAT_PROMPTS.txt)

## Current Status
- [x] Cursor multi-agent system setup completed
- [x] Project architecture Phases **0–7 frozen** (see [docs/LIB_STRUCTURE.md](docs/LIB_STRUCTURE.md)); Phase 8 polish in progress; restructure Phases C–E pending
- [x] State management decision: **keep Provider** (Riverpod deferred)
- [x] Routing: **go_router** with role-protected redirects + deep-link basics
- [x] API layer consolidated under `core/network/`
- [x] APK validation: debug APK built successfully at `build_android/app/outputs/apk/debug/app-debug.apk`
 - [x] Git repository connected / remote verified (`origin` → professorbhakta/cts_beta, branch `beta-ver`)

## Documentation (`docs/`)

**Hub:** [docs/README.md](docs/README.md) · **Start:** [docs/START_HERE.md](docs/START_HERE.md)

### Published

- P0: START_HERE, FLOWS_BY_ROLE, CODE_MAP, UI_ARCHITECTURE, WIREFRAME_GALLERY, wireframes in `lib/design/wireframes/`
- P1: ARCHITECTURE, ROUTING_AND_AUTH, FEATURES, DESIGN_SYSTEM_REVIEW
- P2: OFFLINE_AND_SYNC, BUILD_AND_RELEASE, TESTING, API_AND_ENV
- P3: guides/ (Admin, Driver, Commuter), SCREENSHOTS + assets/screenshots/ category folders (PNGs pending capture)
- **Interactive HTML wireframes:** [docs/wireframes/index.html](docs/wireframes/index.html) (+ styles.css, app.js, DESIGN_SPEC, INTERACTIONS) — preferred local demo
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
8. [x] Auth security wave: TLS keep, session cookies cached, logout/401, D2D WS cookie (REST d2d permissions + `POST /user/` userType still open)
9. [x] Phase 7: migrate **batches** (running + return)
10. [x] Pending-sync badge in admin drawer
11. [x] Phase 8 polish (admin_home, d2d, profile) — architecture freeze + structure/UX; then Phase 9–10
12. [x] APK validation pass: analyze/test clean; Gradle assembleDebug SUCCESS; emulator smoke deferred (emulator stayed offline)

### Application wave (bug audit A2–A4 + ride-alongs)
13. [x] Slice 1 (A2): batch commuter swipe-edit and route edit/delete pass the model, not the sorted index
14. [x] Slice 2 (A3): restore Email/Address fields; empty create address → email; update → last saved
15. [x] Slice 3 (A4): dashboard Add buttons call matching `clearAll()`
16. [x] Slice 1 (A5): commuter form pop re-fetches by batch when opened from a batch list
17. [x] R1: `if (!mounted) return;` in all six CRUD form submit handlers
18. [x] Slice 2 (A10): do not wrap commuter home / Track Cab in OfflineAutoRedirect
19. [x] Slice 3 (R6): SyncManager.dispose() disposes ConnectivityService; unknown entity types do not retry forever
20. [x] Admin nested batch commuter list Coming-today switch (`CommuterListScreen`)
21. [x] Admin Coming switch persists (`ComingTodaySwitch` + PATCH `{status, isComing}`)
22. [x] Admin D2D ADD: user-ID lookup + no optimistic toast / no WS crash
23. [x] Driver return ADD: confirm/remove; org-wide available pool; hide confirmed

### Open backlog — API / networking

- [x] D2D WebSocket auth — session cookie on connect; Django rejects anonymous (4401) and wrong role (4403)
- [x] Session cookies on WebSocket — `IOWebSocketChannel.connect` Cookie header
- [ ] Backend `POST /user/` still trusts client `userType` (public Flutter sign-up disabled)
- [ ] `DEFAULT_ADMIN_CODE` empty — admin registration may need manual code entry
- [ ] `channels_redis` for WS broadcast scaling (backend)

### Open backlog — manual QA checklist

- [ ] Admin: running batches after driver WS connect
- [ ] Admin: D2D channel + add sheet
- [ ] Driver: connect, pickup, STOP
- [ ] Driver/admin: reconnect after STOP → ended message
- [ ] Admin: return batch confirm / remove / end
- [ ] Commuter: isComing toggle affects **morning** D2D pool (evening return is not gated on isComing)

## APK validation notes (2026-07-17)
- Fixed: deprecated `encryptedSharedPreferences` in `session_manager.dart`
- Fixed: Android release missing INTERNET/cleartext + permission declarations
- Fixed: `Connectivity.checkConnectivity()` cast crash risk in `app_class.dart`
- Fixed: CMake SDK mismatch by installing cmake 3.31.6 and pinning in `android/app/build.gradle.kts`
- Remaining: image assets listed in pubspec appear missing from workspace; Firebase Messaging not initialized; API host is LAN-only (`172.20.10.2`)

## Architecture phase progress

Phases **0–7 are frozen** (layout + migration complete). Do not reopen them for new feature work. Phase 8 is the current polish pass. Phases 9–10 and restructure C–E stay pending.

| Phase | Status | Notes |
|-------|--------|-------|
| **0** Scaffold `app/`, `shared/`, `features/` | Frozen | |
| **1** Extract app shell + DI | Frozen | `lib/app/cts_app.dart`, `lib/app/app_providers.dart` |
| **2** Consolidate `api/` → `core/network` | Frozen | Canonical in `core/network/`; `lib/api/` re-exports |
| **3** Widgets → `shared/` | Frozen | Canonical UI is `lib/widgets/` |
| **4** Splash + auth | Frozen | `features/splash`, `features/auth` |
| **5** Routes, pops, cabs | Frozen | `features/routes`, `pops`, `cabs` |
| **6** Drivers + commuters | Frozen | CRUD + role homes + list/return screens |
| **7** Batches (running + return) | Frozen | `features/batches/` |
| **8** admin_home, d2d, profile | Done | Structure/UX polish (no token redesign) |
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

### Structure (frozen after Phase 8)
```
lib/
  features/
    batches/          # screens / providers / models / repositories
    drivers/, commuters/
    routes/, pops/, cabs/
    splash/, auth/, d2d/, admin_home/, profile/
  core/network/
  widgets/            # shared UI (canonical)
  screens/, controllers/, models/, domain/, data/  # legacy / shared infra
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
