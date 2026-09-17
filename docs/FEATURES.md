> **Doc:** docs/FEATURES.md
> **Updated:** 2026-09-10 19:40 IST
> **Session:** Removed offline_temp prototype feature

# Feature catalog

Every major feature module: **screens**, **providers**, and **repositories**.

**See also:** [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md) · [ARCHITECTURE.md](./ARCHITECTURE.md)

---

## Summary table

| Feature folder | Role | Main screens | List provider | Form provider | Repository |
|----------------|------|--------------|---------------|---------------|--------------|
| `splash` | All | SplashScreen | SplashProvider | — | via GetInitialRouteUseCase |
| `auth` | All | SignIn (`/signUp` redirects here) | SignInProvider | — | AuthenticationRepository |
| `admin_home` | Admin + Supervisor (filtered) | AdminMainScreen | AdminProvider | — | Multiple (counts) |
| `routes` | Admin | RouteScreen, RouteForm | RouteController | RouteFormProvider | RouteRepository |
| `pops` | Admin | PopScreen, PopForm | PopProvider | PopFormProvider | PopRepository |
| `batches` | Admin + Driver (return list) | Batch, BatchForm, Running, Returning, ReturnCommuterListScreen, ReturnBoardingQrScreen | BatchProvider, RunningBatchProvider, ReturnBatchProvider | BatchFormProvider | BatchRepository (offline-first), RunningBatchRepository, ReturnBatchRepository |
| `cabs` | Admin | CabScreen, CabForm | CabProvider | CabFormProvider | CabRepository |
| `drivers` | Admin + Driver | DriverScreen, DriverForm, DriverHomePage | DriverProvider, DriverHomeProvider | DriverFormProvider | DriverRepository |
| `commuters` | Admin + Commuter | CommuterScreen, CommuterForm, CommuterHomePage, CommuterListScreen, ReturnCommuterListScreen | CommuterController, CommuterHomeProvider | CommuterFormProvider | CommuterRepository |
| `d2d` | Admin + Driver + Commuter | D2dChannel, D2DLogScreen, BoardingScanScreen | D2dChannelProvider | — | D2dRepository (status + odometer + boarding) + WebSocket via provider |
| `profile` | All logged-in | ProfileScreen | ProfileProvider, SignInProvider (logout) | — | Session (AppManager / SessionRole) + AuthenticationRepository |

### Locale / i18n (FIND-017)

**v1:** English-only Material strings; no `flutter_localizations` delegates yet.  
**Post-v1:** Hindi + RTL timeline tracked in [PROJECT_TODOS.md](../PROJECT_TODOS.md) (item 7b) — inventory → delegates → `app_hi.arb` → RTL smoke.

---

## Routes ↔ features

| Route | Screen | Feature |
|-------|--------|---------|
| `/splashScreen` | SplashScreen | splash |
| `/signIn` | SignInScreen | auth |
| `/signUp` | Redirect → `/signIn` | auth |
| `/adminHomeScreen` | AdminMainScreen | admin_home |
| `/routeScreen`, `/routeForm` | RouteScreen, RouteForm | routes |
| `/popScreen`, `/popForm` | PopScreen, PopForm | pops |
| `/batchScreen`, `/batchForm` | BatchScreen, BatchForm | batches |
| `/runningBatchScreen` | RunningBatchScreen | batches |
| `/returnBatchScreen` | ReturningBatchScreen | batches |
| `/returnCommuterScreen/:batchId` | ReturnCommuterListScreen (admin) | batches / commuters |
| `/driverReturnCommuter/:batchId` | ReturnCommuterListScreen (confirm/remove) | batches / commuters |
| `/returnBoardingQr/:batchId` | ReturnBoardingQrScreen (show; `?trip=return`) | batches |
| `/returnBoardingScan` | ReturnBoardingScanScreen → boarding_scan | batches |
| `/cabScreen`, `/cabForm` | CabScreen, CabForm | cabs |
| `/driverScreen`, `/driverForm` | DriverScreen, DriverForm | drivers |
| `/driverHomeScreen` | DriverHomePage | drivers |
| `/commuterScreen`, `/commuterForm` | CommuterScreen, CommuterForm | commuters |
| `/commuterHomeScreen` | CommuterHomePage | commuters |
| `/d2dChannel/:id` | D2dChannel | d2d |
| `/d2dLog/:id` | D2DLogScreen (start/end KM + boarding QR) | d2d |
| `/boardingScan` | BoardingScanScreen (commuter) | d2d |
| `/profileScreen` | ProfileScreen | profile |

Nested (no GoRoute): `CommuterListScreen`.

---

## Provider registration

All wired in [`lib/app/app_providers.dart`](../lib/app/app_providers.dart):

- Repositories: `Provider<BatchRepository>.value(offlineFirstBatchRepository)` for batches; others `create:` with `BaseApiServices`
- Global: `SessionAuthNotifier`, `SyncManager`, `ConnectivityService`, `SplashProvider`, auth providers
- Per feature: `*Controller` / `*Provider` + matching `*FormProvider`

---

## Feature imports

There are **no barrel `index.dart` files**. Import the canonical file:

- `package:cts/features/batches/screens/...`
- `package:cts/features/routes/screens/...`
- `package:cts/features/pops/screens/...`
- `package:cts/features/cabs/screens/...`
- `package:cts/features/drivers/screens/...`
- `package:cts/features/commuters/screens/...`

Same pattern for `admin_home/`, `d2d/`, `profile/`, `auth/`, `splash/`.

---

## Admin dashboard data sources

`AdminProvider.loadDetailedDashboardData()` aggregates counts from:

- BatchRepository, CommuterRepository, DriverRepository, CabRepository, RouteRepository, PopRepository, RunningBatchRepository

**Quick actions Add Batch / Commuter / Driver / Cab / Route / POP** call the matching `*FormProvider.clearAll()` then `push` the form (same as list **+**). Stat cards only navigate; they do not reset forms.

UI-only navigation from dashboard does not bypass providers for CRUD screens (those screens fetch on mount).

---

## Admin CRUD notes (Application wave A2–A4)

| Topic | Behavior |
|-------|----------|
| Sorted list edit/delete | `CommuterListScreen` and `RouteScreen` pass the **model** into edit/delete, not the sorted/filtered index |
| Coming-today switch | Admin `CommuterScreen` and nested `CommuterListScreen` use `ComingTodaySwitch` (taps not stolen by card/Slidable) → `updateCommuterIsComing` |
| Mark all coming | Admin `CommuterScreen` AppBar action → confirm → `PATCH /user/admin/commuter/<adminCode>/isComing` (`markAllComing`); org-scoped only |
| Commuter form | Email required; Address optional (empty create → email). Edit loads `GET /user/<id>` |
| Form providers | App-scoped. Create entry points must `clearAll()` so `forUpdate` does not leak from the last edit |
| Commuter form pop | Reloads the **current** list scope (`refreshCurrentList`): by-batch if opened from a batch list, otherwise the full admin list |
| D2D admin ADD | Sheet lists all admin commuters. WS ADD looks up by **user ID** (this batch, then any) and requires a POP. Success toast only after the live list updates. Http404 must not drop the socket |
| Morning STOP | Driver **STOP TRIP** only. `DTODLOG` is created on WS **connect**. Back / Close channel = disconnect, not end |

---

## When you add or rename a feature

1. Update this table
2. Update [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md) navigation matrix
3. Register providers and routes
4. Add row to [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) if user journey changes

## Permissions (camera / notifications)

- **Splash:** mobile requests **notifications** only; **never camera**. Web splash is a no-op for `permission_handler`.
- **Camera:** requested only at **boarding QR** (`boarding_scan_screen`) and **odometer capture** (`odometer_camera_helper`).
- **Trip report:** odometer thumbs via authenticated **network images** only — no camera dependency (web-safe).

## Path A trip review banners (no FCM)

- **Admin / Supervisor:** home + Daily Trip Report show a banner when today's (or selected) report has incomplete or auto-closed trips. Home taps through to Trip Report.
- **Driver:** home banner when morning/return is still open past expected end (12:00 / 00:00 Asia/Kolkata) or odometer start exists without complete. Uses existing `get_d2d_log_status`, return batch status, and odometer APIs only.
- **Not in this pass:** FCM, edit_record UI, report filter chips.

