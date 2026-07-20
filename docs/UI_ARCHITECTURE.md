# CTS Mobile App — UI, Navigation, Wireframes & Controls

> Easier entry: [START_HERE.md](./START_HERE.md) · Role flows: [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) · In-app previews: [WIREFRAME_GALLERY.md](./WIREFRAME_GALLERY.md)

Reference for the **current** Flutter codebase (Commuter Transport System / c2s).

**Sources:** `lib/app/router/app_router.dart`, `lib/app/router/route_names.dart`, `lib/app/di/app_providers.dart`, feature `presentation/` layers.

**Index:** [README.md](./README.md)

---

## 1. Complete navigation matrix

Every **registered** GoRouter destination plus **nested** `Navigator.push` screens.

| # | Destination | Route / mechanism | Who can open | Entry points |
|---|-------------|-------------------|--------------|--------------|
| 1 | SplashScreen | `/splashScreen` | All | App launch |
| 2 | SignInScreen | `/signIn` | Public | Splash, redirect when logged out, logout |
| 3 | SignUpScreen | `/signUp` | Public | Sign-in link (`push`) |
| 4 | NoInternetError | `/noInternet` | Public | Connectivity flows (legacy) |
| 5 | AdminMainScreen | `/adminHomeScreen` | ADMIN (+ redirect) | Splash/login, drawer Dashboard, stat taps stay on hub |
| 6 | DriverHomePage | `/driverHomeScreen` | DRIVER, ADMIN blocked from prefix* | Splash/login |
| 7 | CommuterHomePage | `/commuterHomeScreen` | COMMUTER | Splash/login |
| 8 | ProfileScreen | `/profileScreen` | Logged-in (drawer) | Drawer Profile; logout on profile |
| 9 | RouteScreen | `/routeScreen` | ADMIN | Drawer, dashboard compact card |
| 10 | RouteForm | `/routeForm` | ADMIN | Route list FAB/slidable edit, quick action |
| 11 | PopScreen | `/popScreen` | ADMIN | Drawer, dashboard |
| 12 | PopForm | `/popForm` | ADMIN | POP list, quick action |
| 13 | BatchScreen | `/batchScreen` | ADMIN | Drawer, dashboard Batches stat |
| 14 | BatchForm | `/batchForm` | ADMIN | Batch AppBar +, slidable edit, quick action |
| 15 | ReturningBatchScreen | `/returnBatchScreen` | ADMIN | Batch AppBar return icon, quick action |
| 16 | RunningBatchScreen | `/runningBatchScreen` | ADMIN | Quick action; D2D fallback |
| 17 | CabScreen / CabForm | `/cabScreen`, `/cabForm` | ADMIN | Drawer, dashboard, list actions |
| 18 | DriverScreen / DriverForm | `/driverScreen`, `/driverForm` | ADMIN | Drawer, dashboard, list actions |
| 19 | CommuterScreen / CommuterForm | `/commuterScreen`, `/commuterForm` | ADMIN | Drawer, dashboard, list actions |
| 20 | D2dChannel | `/d2dChannel/:batchId` | ADMIN | Running batch card tap |
| 21 | D2DLogScreen | `/d2dLog/:batchId` | DRIVER | Driver home START TRIP |
| 22 | OfflineHomeScreen | `/offlineTempHome` | ADMIN (drawer when enabled) | Drawer Offline Mode |
| 23 | OfflineRoutePopsScreen | `/offlineRoutePops/:routeId` | ADMIN | Offline Routes tab row |
| 24 | OfflineBatchCommutersScreen | `/offlineBatchCommuters/:batchId` | ADMIN | Offline Batches tab row |
| 25 | OfflineCommuterFormScreen | `Navigator.push` | ADMIN | Offline Commuters tab FAB |
| 26 | CommuterListScreen | `Navigator.push` | ADMIN | Batch list row → commuters for batch |
| 27 | ReturnCommuterListScreen | `Navigator.push` | ADMIN | Returning batch screen → batch row |
| 28 | Router error | `errorBuilder` | — | Unknown deep link |

\*GoRouter `driverOnlyPrefixes` sends non-drivers away from `/driverHomeScreen` and `/d2dLog`. ADMIN uses admin home but can open D2D **Channel**.

**Drawer behavior** (`lib/shared/widgets/app_drawer.dart`): closes drawer → `context.push(route)` (stack, not `go`). Sync banner + “Sync now” when `SyncManager` pending. Logout → `context.go(signIn)`.

**Constants not in GoRouter** (`route_names.dart` only): `/commuterListScreen`, `/returnCommuterScreen`, `/confirmReturnCommuterList` — nested Navigator instead.

```mermaid
flowchart TB
  subgraph navSources [Navigation sources]
    Splash[Splash go]
    Auth[Auth go]
    Drawer[Drawer push]
    Dash[Dashboard push]
    AppBarAct[AppBar actions push]
    ListAct[List slidable or row push]
    NestedNav[Navigator.push modal stack]
  end

  subgraph router [GoRouter destinations]
    R[30 plus flat routes]
  end

  Splash --> R
  Auth --> R
  Drawer --> R
  Dash --> R
  AppBarAct --> R
  ListAct --> R
  NestedNav --> Local[CommuterList ReturnCommuterList OfflineCommuterForm]
```

---

## 2. Feature views and controls (Screen → Provider → actions)

Shared UI state: `ViewState` — `idle | loading | success | error` (`lib/appManager/view_state.dart`). Most list screens: `Consumer<Controller>` + local `_searchQuery` in `State`.

| Feature | View (screen) | Control (Provider) | Repository / service | User controls → provider methods |
|---------|---------------|--------------------|----------------------|----------------------------------|
| Splash | SplashScreen | SplashProvider | GetInitialRouteUseCase → SessionRepository | Auto: `determineInitialRoute()` → `context.go` |
| Session | (redirect only) | SessionAuthNotifier | SessionRepositoryImpl | `refresh()` on login/logout |
| Auth sign-in | SignInScreen | SignInProvider | AuthenticationRepository | Mobile/password fields → login; logout from profile |
| Auth sign-up | SignUpScreen | SignUpProvider | AuthenticationRepository | Registration form → sign up |
| Admin dashboard | AdminMainScreen | AdminProvider | Batch, Commuter, Driver, Cab, Route, Pop, RunningBatch repos | Pull refresh → `loadDetailedDashboardData()`; stat/quick action → router only |
| Routes | RouteScreen, RouteForm | RouteController, RouteFormProvider | RouteRepository | `fetchRoutes`, `deleteRoute`; create/update |
| POPs | PopScreen, PopForm | PopProvider, PopFormProvider | PopRepository | Same CRUD pattern |
| Batches | BatchScreen, BatchForm | BatchProvider, BatchFormProvider | OfflineFirstBatchRepository | `fetchBatches`, delete; form dates/times |
| Running batches | RunningBatchScreen | RunningBatchProvider | RunningBatchRepository | `startStream`/`stopStream`, `fetchOnce`; card → D2D Channel |
| Return batches | ReturningBatchScreen, ReturnCommuterListScreen | ReturnBatchProvider | ReturnBatchRepository | Fetch return batches; nested list confirm return flows |
| Cabs | CabScreen, CabForm | CabProvider, CabFormProvider | CabRepository | CRUD |
| Drivers (admin) | DriverScreen, DriverForm | DriverProvider, DriverFormProvider | DriverRepository | CRUD |
| Driver home | DriverHomePage | DriverHomeProvider | DriverRepository | `fetchDriverProfile`; START TRIP |
| Commuters (admin) | CommuterScreen, CommuterForm, CommuterListScreen | CommuterController, CommuterFormProvider | CommuterRepository | CRUD; list by batch via nested screen |
| Commuter home | CommuterHomePage | CommuterHomeProvider | CommuterRepository | `fetchCommuterProfile`; Switch → `updateIsComing` + dialog |
| D2D admin | D2dChannel | D2dChannelProvider | WebSocket/API via provider | `connect(batchId)`, slidable actions, call tel, FAB close |
| D2D driver | D2DLogScreen | D2dChannelProvider (shared) | Same | `connect`, stop trip disconnect, pop/go home |
| Profile | ProfileScreen | SignInProvider (logout) | AuthenticationRepository | Logout → reset controllers, session refresh |
| Offline | OfflineHomeScreen + tabs | OfflineTempProvider | Local offline store | `initialize`, tab FABs, import/dump/refresh menu |
| Sync | Drawer banner | SyncManager | Connectivity + queue | Manual sync button |

```mermaid
classDiagram
  direction LR
  class Screen {
    StatefulWidget
    initState fetch
    Consumer builder
  }
  class ChangeNotifierProvider {
    ViewState state
    notifyListeners
  }
  class Repository {
    API or local
  }
  Screen --> ChangeNotifierProvider : context.read watch
  ChangeNotifierProvider --> Repository : async calls
  Screen --> GoRouter : push go on success nav
```

**Form control pattern** (all `*Form` screens): `*FormProvider` holds `TextEditingController`s + `forUpdate`/`updateId`; submit calls `*Controller` or repository via provider; `DashboardShell` + `AdminFormHeader` + `PopScope` refresh list on pop.

**List control pattern**: `SearchBarWidget` → local filter; `Slidable` edit prefills form provider → `push(*Form)`; delete → `ConfirmationDialog` → controller delete.

---

## 3. ASCII wireframes (by screen type)

### 3.1 Auth — SignInScreen

```
+----------------------------------+
|           [status bar]           |
|         [logo / Welcome]         |
|  +----------------------------+  |
|  | Mobile                     |  |
|  +----------------------------+  |
|  +----------------------------+  |
|  | Password            [eye]  |  |
|  +----------------------------+  |
|  [ ======== LOGIN ========== ]   |
|      Don't have account? Sign Up |
+----------------------------------+
```

### 3.2 Admin — DashboardShell + AdminMainScreen

```
+--Drawer--+--------------------------------+
| [avatar] | [=] Dashboard          [actions]|
| Dashboard| Welcome + date                 |
| Profile  | +----------+ +----------+      |
| -------- | | Batches  | | Commuters|      |
| MGMT     | +----------+ +----------+      |
| Commuters| [Routes][POPs][Cabs][Drivers]  |
| POPs     | Quick Actions (2x4 grid)       |
| Batches  | [Add Batch][Add Commuter]...   |
| ...      |                                |
| Logout   |                                |
+----------+--------------------------------+
Desktop: permanent 250px nav column replaces drawer.
```

### 3.3 Admin — CRUD list (RouteScreen template)

```
+----------------------------------+
| [=] Routes              [+]      |
+----------------------------------+
| All Routes                       |
| [======== Search ========]       |
| +------------------------------+ |
| | Route A          [<- swipe ->| |
| +------------------------------+ |
| | Route B                      | |
| +------------------------------+ |
+----------------------------------+
FAB optional; Batch screen uses AppBar [return][+] instead.
```

### 3.4 Admin — Form (RouteForm template)

```
+----------------------------------+
| [=] Create Route                 |
+----------------------------------+
| (icon) Create New Route          |
| +----------------------------+   |
| | Route Name                 |   |
| +----------------------------+   |
| [ Cancel ]  [ Save / Update ]    |
+----------------------------------+
```

### 3.5 Driver — DriverHomePage

```
+----------------------------------+
| [=]  BrandAppBar                 |
+----------------------------------+
|        +------------------+      |
|        | Date       [call]|      |
|        | Batch | Time | Cab|      |
|        +------------------+      |
|                                  |
|     [ ===== START TRIP ===== ]   |
+----------------------------------+
```

### 3.6 Driver — D2DLogScreen

```
+----------------------------------+
| [=]  BrandAppBar                 |
+----------------------------------+
| D2D header / batch context       |
| +------------------------------+ |
| | Commuter rows (slidable)     | |
| | call / status actions        | |
| +------------------------------+ |
|              [ Stop trip FAB ]   |
+----------------------------------+
```

### 3.7 Admin — D2dChannel (DashboardShell)

```
+----------------------------------+
| [=] D2D Channel                  |
+----------------------------------+
| Live commuter list (slidable)    |
|                                  |
|         [ Close Channel FAB ]    |
+----------------------------------+
```

### 3.8 Commuter — CommuterHomePage

```
+----------------------------------+
| [=]  BrandAppBar                 |
+----------------------------------+
| Hey, {username}                  |
| +------------------------------+ |
| | Today date      [Coming O|X]| |
| +------------------------------+ |
| (loading bar while updating)     |
+----------------------------------+
```

### 3.9 Offline — OfflineHomeScreen

```
+----------------------------------+
| Offline Mode              [...]  |
+----------------------------------+
|     (tab body: Routes/Batches/   |
|      Commuters/Output)           |
+----------------------------------+
| O Routes | Batches | People | Out|
+----------------------------------+
                            [FAB]
```

### 3.10 Profile — ProfileScreen

```
+----------------------------------+
| [=] Profile                      |
+----------------------------------+
|        ( large avatar )          |
| +------------------------------+ |
| | Name / Mobile / Role rows    | |
| +------------------------------+ |
| [ Logout ]                       |
+----------------------------------+
```

---

## 4. Wireframe-as-code (Flutter layout skeletons)

Documentation templates matching existing widgets. **Live implementations:** [WIREFRAME_GALLERY.md](./WIREFRAME_GALLERY.md) and `lib/design/wireframes/`.

### 4.1 Reusable list feature skeleton

```dart
// Pattern: RouteScreen, PopScreen, CabScreen, DriverScreen, CommuterScreen
class FeatureListWireframe extends StatelessWidget {
  const FeatureListWireframe({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: title,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => context.push('/featureForm'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          SearchBarWidget(hintText: 'Search…', onSearchChanged: _noop),
          const Expanded(
            child: /* Consumer: loading SkeletonList | error StatusMessage | list ModernListCard + Slidable */,
          ),
        ],
      ),
    );
  }

  static void _noop(String _) {}
}
```

### 4.2 Reusable form skeleton

```dart
// Pattern: RouteForm, PopForm, BatchForm, etc.
class FeatureFormWireframe extends StatelessWidget {
  const FeatureFormWireframe({super.key, required this.isEdit});

  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: isEdit ? 'Edit' : 'Create',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdminFormHeader(icon: Icons.edit, title: isEdit ? 'Edit' : 'Create'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => context.pop(), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(child: CommonPrimaryButton(label: 'Save', onPressed: () {})),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 4.3 Role home skeleton (driver / commuter)

```dart
// Pattern: DriverHomePage, CommuterHomePage
class RoleHomeWireframe extends StatelessWidget {
  const RoleHomeWireframe({super.key, required this.primaryActionLabel});

  final String primaryActionLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandAppBar(),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: /* Consumer: LoadingIndicator | StatusMessage | Column(
          Card(assignment or date + switch),
          PrimaryButton(label: primaryActionLabel),
        ) */,
      ),
    );
  }
}
```

### 4.4 D2D live view skeleton

```dart
// Pattern: D2DLogScreen (driver), D2dChannel (admin shell)
class D2dLiveWireframe extends StatelessWidget {
  const D2dLiveWireframe({super.key, required this.useDashboardShell});

  final bool useDashboardShell;

  @override
  Widget build(BuildContext context) {
    final body = Consumer<D2dChannelProvider>(
      builder: (context, provider, _) {
        return switch (provider.state) {
          ViewState.loading => const LoadingIndicator(),
          ViewState.error => StatusMessage.error(onRetry: () {}),
          _ => ListView.builder(
              itemCount: 0,
              itemBuilder: (_, __) => const SizedBox.shrink(),
            ),
        };
      },
    );

    if (useDashboardShell) {
      return DashboardShell(title: 'D2D Channel', fab: _closeFab(), child: body);
    }
    return Scaffold(
      appBar: const BrandAppBar(),
      drawer: const AppDrawer(),
      body: body,
      floatingActionButton: _stopFab(),
    );
  }

  Widget _closeFab() => FloatingActionButton.extended(onPressed: () {}, label: const Text('Close'));
  Widget _stopFab() => FloatingActionButton(onPressed: () {}, child: const Icon(Icons.stop));
}
```
---

## 5. Architecture diagrams

### 5.1 App bootstrap

```mermaid
flowchart TB
  subgraph root [CtsApp]
    MP[MultiProvider AppProviders]
    MAR[MaterialApp.router]
    GR[GoRouter]
    MP --> MAR --> GR
  end
  GR --> Splash --> Auth
  GR --> RoleHomes[Admin Driver Commuter homes]
  GR --> CRUD[Admin CRUD and forms]
  GR --> D2D[D2D Channel and Log]
  GR --> Offline[Offline module]
```

### 5.2 Auth state

```mermaid
stateDiagram-v2
  [*] --> Splash
  Splash --> SignIn: not logged in
  Splash --> AdminHome: ADMIN
  Splash --> DriverHome: DRIVER
  Splash --> CommuterHome: COMMUTER
  SignIn --> AdminHome: login ADMIN
  SignIn --> DriverHome: login DRIVER
  SignIn --> CommuterHome: login COMMUTER
```

### 5.3 Batch operations flow

```mermaid
flowchart LR
  batchScreen[BatchScreen]
  batchForm[BatchForm]
  running[RunningBatchScreen]
  returnB[ReturningBatchScreen]
  d2dCh[D2dChannel]
  commuterList[CommuterListScreen nested]
  returnList[ReturnCommuterListScreen nested]

  batchScreen --> batchForm
  batchScreen --> returnB
  batchScreen --> commuterList
  running --> d2dCh
  returnB --> returnList
```

---

## 6. Screen inventory

| Area | Screen widget | Route |
|------|---------------|-------|
| Auth | SignInScreen, SignUpScreen | `/signIn`, `/signUp` |
| Splash | SplashScreen | `/splashScreen` |
| Admin | AdminMainScreen | `/adminHomeScreen` |
| Routes | RouteScreen, RouteForm | `/routeScreen`, `/routeForm` |
| POPs | PopScreen, PopForm | `/popScreen`, `/popForm` |
| Batches | BatchScreen, BatchForm, RunningBatchScreen, ReturningBatchScreen | `/batchScreen`, … |
| Cabs | CabScreen, CabForm | `/cabScreen`, `/cabForm` |
| Drivers | DriverScreen, DriverForm, DriverHomePage | `/driverScreen`, … |
| Commuters | CommuterScreen, CommuterForm, CommuterHomePage | `/commuterScreen`, … |
| D2D | D2dChannel, D2DLogScreen | `/d2dChannel`, `/d2dLog` |
| Profile | ProfileScreen | `/profileScreen` |
| Offline | OfflineHomeScreen + tabs | `/offlineTempHome`, … |

---

## 7. Known UI quirks

- **Driver and Commuter homes** use the same `AppDrawer` / `AdminNavList` as admin (`lib/features/drivers/presentation/screens/driver_home_page.dart`, `lib/features/commuters/presentation/screens/commuter_home_page.dart`); GoRouter redirects block admin CRUD for non-admins, but drawer labels may still show management items until tapped.
- **Duplicate widget paths:** some screens import `package:cts/widgets/...` vs `package:cts/shared/widgets/...` (same patterns, parallel barrels).
- **Drawer selection** uses `ModalRoute.settings.name`, which may not always match GoRouter path — selected tile highlight can be inconsistent.
