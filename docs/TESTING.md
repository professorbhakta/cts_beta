> **Doc:** docs/TESTING.md
> **Updated:** 2026-08-14 22:00 IST
> **Session:** Driver return confirm; any-batch available pool

# Testing

How to verify the CTS app today and what to expand next.

**See also:** [BUILD_AND_RELEASE.md](./BUILD_AND_RELEASE.md) · [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) · [API_CONTRACTS.md](./API_CONTRACTS.md)

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

- [ ] Cold start → splash → sign in (no Sign Up link)
- [ ] `/signUp` deep link → sign in
- [ ] Wrong password → error snackbar
- [ ] ADMIN → dashboard; cannot open driver home URL without redirect
- [ ] DRIVER → home → START TRIP → D2D log → stop → home
- [ ] COMMUTER → toggle “coming” → confirm → success snackbar
- [ ] Profile logout with airplane mode still lands on sign in
- [ ] D2D without login cookie → close 4401 / error, not an empty list

### Admin CRUD (sample one entity)

- [ ] Routes: list, search, add, edit, delete confirm
- [ ] After **search or A–Z**, route swipe Edit/Delete changes **that** route
- [ ] Batches: return icon → returning batches
- [ ] Batch commuter list: sort A–Z, swipe EDIT → form shows **that** commuter
- [ ] Batch commuter list: Coming switch toggles `isComing` (same as Commuters list)
- [ ] Running batches → D2D channel opens
- [ ] D2D Channel **+** add: rider appears on the live list (needs POP); no fake toast if they stay off the list
- [ ] D2D add of a commuter on another batch still works if they have a POP
- [ ] Driver **STOP TRIP** sets `DTODLOG.isActive=false` + `endTime`; back without STOP does not
- [ ] Same-day reconnect after STOP → 4001 “already ended”, no retry
- [ ] After editing a batch, Dashboard → **Add Batch** opens **Create** (not Update of the old id)
- [ ] Same blank-create check for Add Commuter / Driver / Cab / Route / POP
- [ ] Create commuter with Email filled and Address empty → saved address equals email
- [ ] Edit commuter does **not** overwrite email with `mail@email.com` or address with `"address"`
- [ ] From a **batch** commuter list, edit then back → list still shows **only that batch**
- [ ] Commuter home / Track Cab stay on commuter UI when offline (no redirect to admin offline)

### Return batch (REST)

- [ ] Admin: Return Batches picker shows counts (`GET status`)
- [ ] Admin: Available tab lists org commuters not yet confirmed (`GET view`)
- [ ] Admin: Confirm swipe (`POST add_commuter` with user id)
- [ ] Admin: Confirmed tab + capacity (`GET get_commuter`, hydrated names)
- [ ] Admin: Remove swipe (`POST remove_commuter`) returns them to Available
- [ ] Admin: End return (`POST end`) then picker shows inactive
- [ ] Driver: RETURN LIST — Confirm/Remove; no End FAB
- [ ] Confirmed rider disappears from Available on this batch and other return batches

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
