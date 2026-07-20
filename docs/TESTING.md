# Testing

How to verify the CTS app today and what to expand next.

**See also:** [BUILD_AND_RELEASE.md](./BUILD_AND_RELEASE.md) · [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md)

---

## Automated tests (current)

Location: `test/`

| Test | File | What it covers |
|------|------|----------------|
| Theme smoke | `test/widget_test.dart` | `AppTheme.light()` + basic `MaterialApp` renders “CTS” |

Run:

```bash
flutter test
```

Static analysis:

```bash
flutter analyze
```

Project goal (`.cursorrules`): run analyze, pub get, and test after substantive changes.

---

## Manual QA checklist

### Auth and roles

- [ ] Cold start → splash → sign in
- [ ] Wrong password → error snackbar
- [ ] ADMIN → dashboard; cannot open driver home URL without redirect
- [ ] DRIVER → home → START TRIP → D2D log → stop → home
- [ ] COMMUTER → toggle “coming” → confirm → success snackbar
- [ ] Profile logout → sign in

### Admin CRUD (sample one entity)

- [ ] Routes: list, search, add, edit, delete confirm
- [ ] Batches: return icon → returning batches
- [ ] Running batches → D2D channel opens

### Offline / sync (batches)

- [ ] Airplane mode → view batches (cached if previously loaded)
- [ ] Queue mutation offline → drawer shows pending → online → Sync now

### Debug wireframes

- [ ] Sign in screen → Preview UI wireframes → each catalog item opens

---

## Recommended test expansion (backlog)

| Priority | Type | Target |
|----------|------|--------|
| P1 | Widget | `SignInScreen` form validation |
| P1 | Widget | `DashboardShell` responsive breakpoints |
| P2 | Unit | `GetInitialRouteUseCase` with mock session |
| P2 | Unit | `RouteName.homeForRole` / redirect logic (extracted pure functions) |
| P3 | Integration | Login flow with mocked `AuthenticationRepository` |
| P3 | Golden | Admin dashboard stat cards (optional) |

Place new tests under `test/features/<name>/` mirroring `lib/features/`.

---

## Device matrix

| Platform | Minimum smoke |
|----------|----------------|
| Android phone | Debug APK install + driver trip |
| Android tablet width | Admin dashboard 2×2 vs row layout |
| iOS | Sign in + commuter switch (when Mac available) |

---

## Bug reporting template

1. Role + account type
2. Route or screen name
3. Steps to reproduce
4. Expected vs actual
5. Online/offline
6. `flutter doctor -v` snippet if build-related
