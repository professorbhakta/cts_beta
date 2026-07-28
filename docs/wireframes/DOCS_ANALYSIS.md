# Docs analysis → HTML wireframe coverage

Audit of every markdown file under `docs/` (2026-07-21). Used to drive the interactive prototype in this folder.

**Sources read:** README, START_HERE, FOLDER_GUIDE, CODE_MAP, UI_ARCHITECTURE, FLOWS_BY_ROLE, WIREFRAME_GALLERY, SCREENSHOTS, ARCHITECTURE, ROUTING_AND_AUTH, FEATURES, DESIGN_SYSTEM_REVIEW, OFFLINE_AND_SYNC, BUILD_AND_RELEASE, TESTING, API_AND_ENV, guides/* (Admin/Driver/Commuter/README), assets/screenshots/README, wireframes/README.

---

## 1. Inventory — user-facing screens & flows

### Auth (everyone)

| Screen | Route | Documented in |
|--------|-------|---------------|
| SplashScreen | `/splashScreen` | UI_ARCHITECTURE, ROUTING, START_HERE |
| SignInScreen | `/signIn` | guides, FLOWS, TESTING, SCREENSHOTS |
| SignUpScreen | `/signUp` | UI_ARCHITECTURE, ROUTING |
| NoInternetError | `/noInternet` | UI_ARCHITECTURE (legacy) |
| Wireframe gallery (debug) | `/designWireframes` | WIREFRAME_GALLERY (not a product screen) |

### Admin

| Screen | Route / mechanism | Documented in |
|--------|-------------------|---------------|
| AdminMainScreen (Dashboard) | `/adminHomeScreen` | guides/ADMIN, FLOWS, FEATURES, SCREENSHOTS |
| AppDrawer / AdminNavList | shell | UI_ARCHITECTURE, OFFLINE (sync banner) |
| RouteScreen / RouteForm | `/routeScreen`, `/routeForm` | UI_ARCHITECTURE §3.3–3.4 (CRUD template) |
| PopScreen / PopForm | `/popScreen`, `/popForm` | FEATURES, ADMIN guide |
| BatchScreen / BatchForm | `/batchScreen`, `/batchForm` | FEATURES, ADMIN guide |
| RunningBatchScreen | `/runningBatchScreen` | FLOWS, ADMIN guide, SCREENSHOTS |
| ReturningBatchScreen | `/returnBatchScreen` | FLOWS, ADMIN guide |
| CabScreen / CabForm | `/cabScreen`, `/cabForm` | FEATURES |
| DriverScreen / DriverForm | `/driverScreen`, `/driverForm` | FEATURES |
| CommuterScreen / CommuterForm | `/commuterScreen`, `/commuterForm` | FEATURES, ADMIN guide |
| CommuterListScreen | `Navigator.push` | UI_ARCHITECTURE, FLOWS |
| ReturnCommuterListScreen | `Navigator.push` | UI_ARCHITECTURE, FLOWS |
| D2dChannel | `/d2dChannel/:batchId` | FLOWS, DRIVER/ADMIN guides, SCREENSHOTS |
| OfflineHomeScreen | `/offlineTempHome` | OFFLINE_AND_SYNC, ADMIN guide |
| OfflineRoutePopsScreen | `/offlineRoutePops/:routeId` | FEATURES, OFFLINE |
| OfflineBatchCommutersScreen | `/offlineBatchCommuters/:batchId` | FEATURES, OFFLINE |
| OfflineCommuterFormScreen | `Navigator.push` | FEATURES |
| ProfileScreen | `/profileScreen` | guides, FLOWS, SCREENSHOTS |

### Driver

| Screen | Route | Documented in |
|--------|-------|---------------|
| DriverHomePage | `/driverHomeScreen` | DRIVER guide, FLOWS, SCREENSHOTS |
| D2DLogScreen | `/d2dLog/:batchId` | DRIVER guide, FLOWS, TESTING |
| Profile / drawer | shared | DRIVER guide |

### Commuter

| Screen | Route | Documented in |
|--------|-------|---------------|
| CommuterHomePage | `/commuterHomeScreen` | COMMUTER guide, FLOWS |
| Coming-today confirm dialog | modal | COMMUTER guide, TESTING |
| Profile / drawer | shared | COMMUTER guide |

### Cross-cutting interactions (docs)

| Interaction | Source |
|-------------|--------|
| Splash → role home or sign-in | ROUTING_AND_AUTH |
| Role-gated redirects | ROUTING_AND_AUTH |
| Drawer `push` (not `go`) | UI_ARCHITECTURE, ROUTING |
| Dashboard stats → list screens | ADMIN guide, FLOWS |
| Quick actions → forms / running / return | ADMIN guide |
| List search + slidable edit/delete | ADMIN guide, UI_ARCHITECTURE |
| Delete → ConfirmationDialog | UI_ARCHITECTURE, TESTING |
| FAB / AppBar + → create form | UI_ARCHITECTURE |
| Running batch card → D2D Channel | FLOWS, SCREENSHOTS |
| Batch return icon → Returning batches → nested list | ADMIN guide |
| Driver START TRIP → D2D Log → Stop → home | DRIVER guide, TESTING |
| Commuter switch → confirm → toast | COMMUTER guide, TESTING |
| Offline bottom tabs + FAB per tab | OFFLINE_AND_SYNC, UI §3.9 |
| Sync banner + Sync now in drawer | OFFLINE_AND_SYNC, ADMIN guide |
| Profile Logout → Sign in | ROUTING, guides |
| Pull-to-refresh (dashboard / lists / homes) | guides |

---

## 2. Gaps — previous HTML gallery vs docs

| Gap | Severity |
|-----|----------|
| Static gallery only — taps did nothing | Critical |
| Missing Sign Up, Splash | Medium |
| Missing entity lists beyond Routes (POPs, Batches, Cabs, Drivers, Commuters) | High |
| Missing Running / Returning batches + nested commuter lists | High |
| Missing Offline drill-downs + sync banner concept | Medium |
| No role landing / guided tours / breadcrumbs / captions | High (PM/QA) |
| No Dev panel (RouteName, file path, provider) | High (devs) |
| No DESIGN_SPEC / interaction checklist | High |
| Gray stub aesthetic vs AppColors + DESIGN_SYSTEM_REVIEW | High |

---

## 3. Required navigation & popup/CRUD interactions

Must work in HTML with visible feedback:

1. Landing → pick role or guided tour → Sign in (role picker) → role home  
2. Admin drawer → every management item + Offline + Profile  
3. Dashboard stats + quick actions → lists/forms/running/return  
4. Generic CRUD: search, row Edit → form, Delete → modal Cancel/Delete, FAB create → Save adds row, toast  
5. Running batch → D2D Channel → Close Channel  
6. Return batches → tap batch → return commuter list  
7. Batch row → nested CommuterList (demo)  
8. Driver START TRIP → D2D Log → Stop trip → home  
9. Commuter Coming switch → ConfirmationDialog → toast  
10. Offline tabs switch body; FAB toast/add; sync banner “Sync now” toast  
11. Profile Logout → Sign in; Back + breadcrumb always  

---

## 4. Dev-facing mapping (from FEATURES + ROUTING + ARCHITECTURE)

| Screen widget | RouteName | Provider(s) | Feature folder |
|---------------|-----------|-------------|----------------|
| SplashScreen | `splashScreen` | SplashProvider | `features/splash` |
| SignInScreen | `signIn` | SignInProvider | `features/auth` |
| SignUpScreen | `signUp` | SignUpProvider | `features/auth` |
| AdminMainScreen | `adminHomeScreen` | AdminProvider | `features/admin_home` |
| RouteScreen / RouteForm | `routeScreen` / `routeForm` | RouteController, RouteFormProvider | `features/routes` |
| PopScreen / PopForm | `popScreen` / `popForm` | PopProvider, PopFormProvider | `features/pops` |
| BatchScreen / BatchForm | `batchScreen` / `batchForm` | BatchProvider, BatchFormProvider | `features/batches` |
| RunningBatchScreen | `runningBatchScreen` | RunningBatchProvider | `features/batches` |
| ReturningBatchScreen | `returnBatchScreen` | ReturnBatchProvider | `features/batches` |
| CabScreen / CabForm | `cabScreen` / `cabForm` | CabProvider, CabFormProvider | `features/cabs` |
| DriverScreen / DriverForm | `driverScreen` / `driverForm` | DriverProvider, DriverFormProvider | `features/drivers` |
| DriverHomePage | `driverHomeScreen` | DriverHomeProvider | `features/drivers` |
| CommuterScreen / CommuterForm | `commuterScreen` / `commuterForm` | CommuterController, CommuterFormProvider | `features/commuters` |
| CommuterHomePage | `commuterHomeScreen` | CommuterHomeProvider | `features/commuters` |
| CommuterListScreen | nested | CommuterController | `features/commuters` |
| ReturnCommuterListScreen | nested | ReturnBatchProvider | `features/commuters` |
| D2dChannel | `d2dChannel` + `/:batchId` | D2dChannelProvider | `features/d2d` |
| D2DLogScreen | `d2dLog` + `/:batchId` | D2dChannelProvider | `features/d2d` |
| ProfileScreen | `profileScreen` | SignInProvider (logout) | `features/profile` |
| OfflineHomeScreen | `offlineTempHome` | OfflineTempProvider | `offline_temp/` |
| Shell widgets | — | — | `shared/widgets/` DashboardShell, AppDrawer, BrandAppBar, ModernListCard, ConfirmationDialog |

DI: `lib/app/di/app_providers.dart`. Router: `lib/app/router/app_router.dart`.

---

## 5. Design tokens / UX notes

From `AppColors` + DESIGN_SYSTEM_REVIEW + UI_ARCHITECTURE:

| Token | Value / use |
|-------|-------------|
| Brand yellow | `#FFC107` (`acYellowWarm`) — accents, FAB, drawer header gradient |
| Yellow bright | `#FFEB3B` — gradients |
| Orange warm | `#FF6F00` / `#FF9800` — alternating stats |
| Black / charcoal | `#000` / `#1A1A1A` — AppBar, drawer body, primary CTA fill |
| Surface | warm off-white `#F5F5F5` / `#FAFAFA` (docs suggest `#F7F6F2`) |
| Success / Danger / Live | green `#388E3C`/`#2E7D32`, red `#D32F2F`/`#C62828`, teal `#00897B` for live |
| Patterns | DashboardShell + drawer; BrandAppBar for driver/commuter; ModernListCard; ConfirmationDialog; charcoal CTA + yellow border |

Role mood: Admin = charcoal + gold + teal live; Driver = high-contrast START / red stop; Commuter = calm surface + green “coming”.

---

## 6. Out of scope for HTML demo (documented but not UI)

| Topic | Doc | Why skipped in wireframes |
|-------|-----|---------------------------|
| Build/release commands | BUILD_AND_RELEASE | Ops, not UI |
| API env vars / Dio | API_AND_ENV | Backend config |
| Automated test files | TESTING | Use TESTING checklist manually against demo |
| Architecture DI internals | ARCHITECTURE | Covered via Dev panel pointers only |
| Flutter debug gallery | WIREFRAME_GALLERY | Separate from HTML; linked in README |
| Screenshot PNGs | SCREENSHOTS | Assets not captured yet; HTML replaces visual need for review |

---

## 7. HTML coverage target (Phase 2 checklist)

- [x] Role landing + 3 guided tours  
- [x] Auth splash + sign-in + sign-up  
- [x] Admin dashboard, drawer, sync banner  
- [x] All 6 CRUD entities (list ↔ form, search, delete modal, FAB)  
- [x] Running batches → D2D Channel  
- [x] Return batches → nested return list  
- [x] Batch → nested CommuterList  
- [x] Driver home → D2D Log → stop  
- [x] Commuter home + coming confirm  
- [x] Offline tabs + FAB + offline commuter form + sync toast  
- [x] Profile logout  
- [x] Breadcrumbs, captions, Dev panel, map overlay  
- [x] DESIGN_SPEC.md + INTERACTIONS.md + README  

**Cross-check (2026-07-21):** HTML demo covers every user-facing screen in §1 except `NoInternetError` (legacy) and Flutter-only `/designWireframes`. `OfflineCommuterFormScreen` is a nested push from the People tab FAB. Ops docs (BUILD/API/TESTING internals) intentionally out of UI scope (§6).
