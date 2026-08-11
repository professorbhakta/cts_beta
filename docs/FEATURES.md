> **Doc:** docs/FEATURES.md
> **Updated:** 2026-08-05 11:30 IST
> **Session:** Verified unchanged

# Feature catalog

Every major feature module: **screens**, **providers**, and **repositories**.

**See also:** [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md) · [ARCHITECTURE.md](./ARCHITECTURE.md)

---

## Summary table

| Feature folder | Role | Main screens | List provider | Form provider | Repository |
|----------------|------|--------------|---------------|---------------|--------------|
| `splash` | All | SplashScreen | SplashProvider | — | via GetInitialRouteUseCase |
| `auth` | All | SignIn, SignUp | SignInProvider, SignUpProvider | — | AuthenticationRepository |
| `admin_home` | Admin | AdminMainScreen | AdminProvider | — | Multiple (counts) |
| `routes` | Admin | RouteScreen, RouteForm | RouteController | RouteFormProvider | RouteRepository |
| `pops` | Admin | PopScreen, PopForm | PopProvider | PopFormProvider | PopRepository |
| `batches` | Admin | Batch, BatchForm, Running, Returning | BatchProvider, RunningBatchProvider, ReturnBatchProvider | BatchFormProvider | BatchRepository (offline-first), RunningBatchRepository, ReturnBatchRepository |
| `cabs` | Admin | CabScreen, CabForm | CabProvider | CabFormProvider | CabRepository |
| `drivers` | Admin + Driver | DriverScreen, DriverForm, DriverHomePage | DriverProvider, DriverHomeProvider | DriverFormProvider | DriverRepository |
| `commuters` | Admin + Commuter | CommuterScreen, CommuterForm, CommuterHomePage, CommuterListScreen, ReturnCommuterListScreen | CommuterController, CommuterHomeProvider | CommuterFormProvider | CommuterRepository |
| `d2d` | Admin + Driver | D2dChannel, D2DLogScreen | D2dChannelProvider | — | WebSocket via provider |
| `profile` | All logged-in | ProfileScreen | SignInProvider (logout) | — | AuthenticationRepository |
| `offline_temp` | Admin (prototype) | OfflineHome + tabs + drill-downs | OfflineTempProvider | — | Local offline DB |
| `design/wireframes` | Debug | Wireframe gallery | — | — | — |

---

## Routes ↔ features

| Route | Screen | Feature |
|-------|--------|---------|
| `/splashScreen` | SplashScreen | splash |
| `/signIn`, `/signUp` | SignIn, SignUp | auth |
| `/adminHomeScreen` | AdminMainScreen | admin_home |
| `/routeScreen`, `/routeForm` | RouteScreen, RouteForm | routes |
| `/popScreen`, `/popForm` | PopScreen, PopForm | pops |
| `/batchScreen`, `/batchForm` | BatchScreen, BatchForm | batches |
| `/runningBatchScreen` | RunningBatchScreen | batches |
| `/returnBatchScreen` | ReturningBatchScreen | batches |
| `/cabScreen`, `/cabForm` | CabScreen, CabForm | cabs |
| `/driverScreen`, `/driverForm` | DriverScreen, DriverForm | drivers |
| `/driverHomeScreen` | DriverHomePage | drivers |
| `/commuterScreen`, `/commuterForm` | CommuterScreen, CommuterForm | commuters |
| `/commuterHomeScreen` | CommuterHomePage | commuters |
| `/d2dChannel/:id` | D2dChannel | d2d |
| `/d2dLog/:id` | D2DLogScreen | d2d |
| `/profileScreen` | ProfileScreen | profile |
| `/offlineTempHome` + children | Offline* screens | offline_temp |
| `/designWireframes` | Wireframe gallery | design |

Nested (no GoRoute): `CommuterListScreen`, `ReturnCommuterListScreen`, `OfflineCommuterFormScreen`.

---

## Provider registration

All wired in [`lib/app/app_providers.dart`](../lib/app/app_providers.dart):

- Repositories: `Provider<BatchRepository>.value(offlineFirstBatchRepository)` for batches; others `create:` with `BaseApiServices`
- Global: `SessionAuthNotifier`, `SyncManager`, `ConnectivityService`, `SplashProvider`, auth providers
- Per feature: `*Controller` / `*Provider` + matching `*FormProvider`

---

## Feature barrels

Export paths for imports:

- `lib/features/batches/index.dart`
- `lib/features/routes/index.dart`
- `lib/features/pops/index.dart`
- `lib/features/cabs/index.dart`
- `lib/features/drivers/index.dart`
- `lib/features/commuters/index.dart`

---

## Admin dashboard data sources

`AdminProvider.loadDetailedDashboardData()` aggregates counts from:

- BatchRepository, CommuterRepository, DriverRepository, CabRepository, RouteRepository, PopRepository, RunningBatchRepository

UI-only navigation from dashboard does not bypass providers for CRUD screens (those screens fetch on mount).

---

## When you add or rename a feature

1. Update this table
2. Update [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md) navigation matrix
3. Register providers and routes
4. Add row to [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) if user journey changes
