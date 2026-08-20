> **Doc:** PROJECT_TODOS.md
> **Updated:** 2026-08-20 22:47 IST
> **Session:** 26l Flutter git cleanup APPLIED

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
4. [~] Offline: SyncManager + drawer badge; `offline_temp` isolated prototype (P9); full promote deferred
5. [x] Baseline `flutter pub get`, `flutter analyze`, `flutter test`

### Follow-ups
6. [ ] Replace / harden deprecated or placeholder screens and TODOs in admin CRUD flows
7. [~] Expand automated tests beyond default `widget_test.dart` — P1 added `test/api/api_response_contract_test.dart` + return batch repo tests (33 total)
8. [x] Auth security wave: TLS keep, session cookies cached, logout/401, D2D WS cookie (REST d2d permissions + `POST /user/` userType still open)
9. [x] Phase 7: migrate **batches** (running + return)
10. [x] Pending-sync badge in admin drawer
11. [x] Phase 8 polish (admin_home, d2d, profile) — architecture freeze + structure/UX; then Phase 9–10
12. [x] APK validation pass: analyze/test clean; Gradle assembleDebug SUCCESS
12b. [x] 2-device QA 2026-08-17: other-batch D2D ADD, STOP ended UI, driver 4001, return 5 other-batch, UG4 coming. [docs/TESTING.md](docs/TESTING.md)
12c. [x] Admin D2D STOP: `isActive: false` → `isTripEnded` + refresh running batches; STOP FAB hidden; Django group close **4001** (no `disconnect(0)`); send on closed socket is swallowed
12d. [x] Lab leftovers: Batch-08 LIVE cleared (2026-08-20 FINAL GATE — 0 running batches)

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
24. [x] Return allocation M1+M2 (`cts-docker`): CList attendance read + pure allocator; views not wired
24b. [x] Adapter `return_pool.py`; STOP-gated CList; extras named overflow_remaining; fail closed; TestCase DB
25. [x] Return allocation M3: merge `status_pool_extras()` into GET status (keep remaining_capacity). Not M7.
25b. [x] Flutter parse status extras on picker + return banner; Seats left still remaining_capacity
26. [x] Return allocation M4 GET view split lists + Flutter Available Home/Overflow
26b. [x] Return allocation M7 enforce add_commuter (R2-R5): validate_add_commuter in return_pool.py
26c. [x] P1 Truth Contract — `ApiResponseContract`; C1 (200+status:error → failure); 33 tests
26g. [x] P9 Debt/health burndown — critical deps; repo SnackBar → UI; sort_utils stub; offline_temp isolated; compileSdk 37; 101 tests
26h. [x] A1 Track Cab vehicle — cab `trackingVehicleId` → commuter Fleet Edge WebView; admin cab form; backend field; 106 tests
26i. [x] Device smoke catch-up 2026-08-20 — P1/P3/P5/P6 PASS (P1 re-smoke duplicate reject)
26j. [x] Return list realignment — `isComing` available pool, confirmed order fix, admin add/view only, driver confirm/remove/end
26k. [x] Batch-02 / Driver 2 production smoke — role UI PASS (Admin no-End / Driver End FAB); confirm/remove UG12 + ID/name ([BATCH2_DRIVER2_SMOKE_CHECKLIST.txt](docs/final-gate/BATCH2_DRIVER2_SMOKE_CHECKLIST.txt))
26l. [x] Flutter git cleanup — tagged `p1-p9-merged` @ `72b6aa5`; deleted P1–P9 + `integration/p1-p7-validation` local/remote; kept `beta-ver`/`main`/`cursor/setup-dev-environment-96cd`. Did not touch `cts-docker`.
26d. [ ] Commuter POST intent (skip/home/earlier) + cutoff/no-show release

### Open backlog — API / networking

- [x] D2D WebSocket auth — session cookie on connect; Django rejects anonymous (4401) and wrong role (4403)
- [x] Session cookies on WebSocket — `IOWebSocketChannel.connect` Cookie header
- [x] Backend `POST /user/` userType — public create COMMUTER-only; admin auth required for DRIVER/ADMIN (P2, `cts-docker`)
- [ ] `DEFAULT_ADMIN_CODE` empty — admin registration may need manual code entry
- [ ] `channels_redis` for WS broadcast scaling (backend)

### Open backlog — manual QA checklist

- [x] Admin: running batches after driver WS connect *(LIVE Batch-01 while trip active; empty after STOP + pull-to-refresh)*
- [x] Admin: D2D channel + add sheet *(2026-08-17: PG10/UG2/UG4 other-batch via search)*
- [x] Driver: connect, pickup, STOP *(2026-08-17: reconnect live, STOP finalized, 4001)*
- [x] Driver/admin: reconnect after STOP → ended message *(admin on-channel + driver 4001 2026-08-17)*
- [x] Admin: return batch confirm / remove / end *(confirm/remove yes; End skipped — 5 confirmed tonight)*
- [x] Driver: RETURN LIST confirm/remove/**End FAB** *(Batch-02 2026-08-20: UG12 confirm/remove; End FAB present, not tapped)*
- [x] Commuter: isComing toggle *(UG4 PATCH + pull-to-refresh → COMING; Switch adb tap missed)*

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
| **9** Promote offline_temp | Isolated (P9) | `offline_module.dart`; drawer-only prototype |
| **10** Remove legacy + Reviewer | Pending | Re-export stubs still present |

### Restructure for readability (new — [LIB_STRUCTURE.md](docs/LIB_STRUCTURE.md))

| Phase | Status | Action |
|-------|--------|--------|
| **A** Docs + rules | Done | `docs/LIB_STRUCTURE.md`, `lib/README.md`, `.cursorrules` |
| **B** Flatten feature folders | Done (local) | All features use `screens/`, `providers/`, `models/`, `repositories/`; old `presentation/domain/data` paths are re-export stubs |
| **C** Single canonical root | Pending | `widgets/`, `app/services/`, delete re-export stubs |
| **D** Naming | Pending | `*_provider.dart`, move `AdminProvider`, reduce `AppClass` statics |
| **E** Offline | Isolated (P9) | Full promote to `features/offline/` deferred |

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
- [x] `flutter analyze` — 0 errors (7 pre-existing info/warnings)
- [x] `flutter test` — 101 passed (P9)

## Build fixes (2026-07-17)
- [x] Fixed Windows assembleDebug blocker: Kotlin incremental cache crash across drives (Pub cache on C:, project on D:)
- [x] Hardened Android Gradle props: `kotlin.incremental=false`, in-process Kotlin, daemon/AAPT2 stability flags
- [x] Upgraded `device_info_plus`, `share_plus`, `flutter_secure_storage` for newer Android plugin support
- [x] Verified `flutter build apk --debug` succeeds (`build\app\outputs\flutter-apk\app-debug.apk`)
- [ ] Optional: enable Windows Developer Mode for symlink-friendly `flutter pub get`; migrate off deprecated `android.builtInKotlin=false` / `android.newDsl=false` when Flutter/plugins allow
