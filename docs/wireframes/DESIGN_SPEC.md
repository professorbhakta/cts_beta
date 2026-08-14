# DESIGN_SPEC — HTML prototype ↔ Flutter implementation

Source of truth for developers implementing or reviewing UI against this interactive demo.

**Open demo:** [index.html](./index.html) · **Tap checklist:** [INTERACTIONS.md](./INTERACTIONS.md)

Brand tokens: `lib/appManager/colors.dart` · Themes: `lib/theme/app_theme.dart` · Psychology notes: [DESIGN_SYSTEM_REVIEW.md](../DESIGN_SYSTEM_REVIEW.md)

---

## How to use this as a design source

1. Open `index.html` → enable **Dev panel**.
2. Navigate to the screen you are building.
3. Match **Widget**, **RouteName**, **Provider**, and **file** from the panel.
4. Implement interactions listed in [INTERACTIONS.md](./INTERACTIONS.md).
5. Prefer shared widgets: `DashboardShell`, `AppDrawer`, `BrandAppBar`, `ModernListCard`, `SearchBarWidget`, `ConfirmationDialog`, `AdminFormHeader`, `CommonPrimaryButton`.

---

## Screen → route → widget → provider

| Demo id | Widget | RouteName / path | Provider | Feature |
|---------|--------|------------------|----------|---------|
| splash | SplashScreen | `splashScreen` `/splashScreen` | SplashProvider | splash |
| signIn | SignInScreen | `signIn` `/signIn` | SignInProvider | auth |
| signUp | (removed from app) | `signUp` `/signUp` → `/signIn` | — | auth (public register disabled) |
| adminHome | AdminMainScreen | `adminHomeScreen` | AdminProvider | admin_home |
| routes | RouteScreen | `routeScreen` | RouteController | routes |
| routeForm | RouteForm | `routeForm` | RouteFormProvider | routes |
| pops / popForm | PopScreen / PopForm | `popScreen` / `popForm` | PopProvider / PopFormProvider | pops |
| batches / batchForm | BatchScreen / BatchForm | `batchScreen` / `batchForm` | BatchProvider / BatchFormProvider | batches |
| running | RunningBatchScreen | `runningBatchScreen` | RunningBatchProvider | batches |
| returning | ReturningBatchScreen | `returnBatchScreen` | ReturnBatchProvider | batches |
| cabs / cabForm | CabScreen / CabForm | `cabScreen` / `cabForm` | CabProvider / CabFormProvider | cabs |
| drivers / driverForm | DriverScreen / DriverForm | `driverScreen` / `driverForm` | DriverProvider / DriverFormProvider | drivers |
| driverHome | DriverHomePage | `driverHomeScreen` | DriverHomeProvider | drivers |
| commuters / commuterForm | CommuterScreen / CommuterForm | `commuterScreen` / `commuterForm` | CommuterController / CommuterFormProvider | commuters |
| commuterHome | CommuterHomePage | `commuterHomeScreen` | CommuterHomeProvider | commuters |
| commuterList | CommuterListScreen | nested `Navigator.push` | CommuterController | commuters |
| returnCommuterList | ReturnCommuterListScreen | nested | ReturnBatchProvider | commuters |
| d2dChannel | D2dChannel | `d2dChannel` `/d2dChannel/:batchId` | D2dChannelProvider | d2d |
| d2dLog | D2DLogScreen | `d2dLog` `/d2dLog/:batchId` | D2dChannelProvider | d2d |
| profile | ProfileScreen | `profileScreen` | SignInProvider (logout) | profile |
| offline | OfflineHomeScreen | `offlineTempHome` | OfflineTempProvider | offline_temp |
| offlineRoutePops | OfflineRoutePopsScreen | `offlineRoutePops` | OfflineTempProvider | offline_temp |
| offlineBatchCommuters | OfflineBatchCommutersScreen | `offlineBatchCommuters` | OfflineTempProvider | offline_temp |
| offlineCommuterForm | OfflineCommuterFormScreen | nested `Navigator.push` | OfflineTempProvider | offline_temp |

Router: `lib/app/router/app_router.dart` · Names: `route_names.dart` · DI: `lib/app/app_providers.dart`

Prototype runtime: `app.js` → `screens` registry (`id`, `title`, `caption`, `route`, `widget`, `file`, `provider`, `render()`, optional `onEnter()`); helpers `showModal`, `showToast`, `startTour`, `toggleDevPanel`.

---

## Shared UI contracts

| Pattern | Flutter | HTML demo behavior |
|---------|---------|-------------------|
| Admin shell | `DashboardShell` + `AppDrawer` | Black AppBar, drawer slide + backdrop |
| Role home shell | `BrandAppBar` (yellow gradient) | Driver / Commuter / D2D log |
| List row | `ModernListCard` + `Slidable` | Edit / Del buttons (swipe → buttons in demo) |
| Delete | `ConfirmationDialog.showDeleteConfirmation` | Modal Cancel / Delete |
| Form header | `AdminFormHeader` | Yellow gradient header strip |
| Primary CTA | charcoal + yellow border | `.btn-block.primary` |
| Live status | teal accent | `.live-badge` |
| Sync | drawer `_syncStatusBanner` + SyncManager | Yellow banner + Sync now toast |

---

## Color tokens (implement against AppColors)

| Token | Hex | Use |
|-------|-----|-----|
| `acBlack` / `acBlackLight` | `#000` / `#1A1A1A` | AppBar, drawer, CTAs |
| `acYellowWarm` | `#FFC107` | Brand accent, FAB, borders |
| `acYellowBright` | `#FFEB3B` | Gradients |
| `acOrangeWarm` | `#FF6F00` | Alternating stats |
| `acGreen` / success | `#388E3C` / `#2E7D32` | Coming switch on, success toast |
| `acRed` / danger | `#D32F2F` / `#C62828` | Delete, Stop trip |
| Live (DESIGN_SYSTEM) | `#00897B` | Running / D2D live |
| Surface | `#F7F6F2` / `acWhiteSoft` | Phone body background |

---

## Gaps vs production Flutter

| Area | Demo | Production |
|------|------|------------|
| Auth | Role picker after LOGIN | Real API + `SessionAuthNotifier` |
| Slidable | Explicit Edit/Del buttons | `flutter_slidable` swipe |
| Pull-to-refresh | Caption only | `RefreshIndicator` |
| WebSocket D2D | Static list + call toast | Live `D2dChannelProvider.connect` |
| Offline DB | In-memory arrays | `OfflineTempDatabase` |
| Sign-up fields | Simplified | Full validators + admin code |
| Tablet rail | Phone drawer only | `DashboardShell` permanent nav ≥900px |
| NoInternet | Not a dedicated screen | `/noInternet` legacy route |

Update this file when routes or providers change (see FEATURES.md maintenance checklist).
