> **Doc:** docs/TESTING.md
> **Updated:** 2026-08-17 22:15 IST
> **Session:** Wrap — 2-device leftovers passed; lab on UG4 / Batch-08 LIVE

# Testing

How to verify the CTS app today and what to expand next.

**See also:** [BUILD_AND_RELEASE.md](./BUILD_AND_RELEASE.md) · [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) · [API_CONTRACTS.md](./API_CONTRACTS.md)

---

## Automated tests (current)

Location: `test/`

| Test | File | What it covers |
|------|------|----------------|
| Theme smoke | `test/widget_test.dart` | `AppTheme.light()` + basic `MaterialApp` renders “CTS” |
| D2D STOP snapshot | `test/features/d2d/d2d_result_ended_test.dart` | `isActive: false` marks trip ended |

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

- [x] Cold start → splash → sign in (no Sign Up link)
- [x] `/signUp` deep link → sign in
- [ ] Wrong password → error snackbar *(blocked: Gboard stylus overlay ate LOGIN taps; `wrongpass` was the failed-login case, real password is `password`)*
- [~] ADMIN → dashboard; cannot open driver home URL without redirect *(dashboard pass; `cts://app/driverHomeScreen` opens Driver home error — admin is allowed on driver routes)*
- [x] DRIVER → home → START TRIP → D2D log → stop → home *(Driver 1 `9876544111` 2026-08-17: reconnect live, STOP → home; same-day START → 4001)*
- [x] COMMUTER → toggle “coming” → confirm → success *(UG4 `9876556704`: home showed NOT COMING; PATCH `{isComing:true}` + pull-to-refresh → COMING. Adb tap missed the Switch thumb)*
- [~] Profile logout with airplane mode still lands on sign in *(online logout reached sign-in; airplane yanked admin to Offline Mode; force-stop still restored Admin dashboard)*
- [x] D2D without login cookie → close 4401 / error, not an empty list *(logged-out deep link redirected to sign-in)*

### Admin CRUD (sample one entity)

- [x] Routes: list, search, add, edit, delete confirm *(TestRoute1 created then deleted; original 5 routes remain)*
- [x] After **search or A–Z**, route swipe Edit/Delete changes **that** route *(search Palej → Edit form Palej)*
- [x] Batches: return icon → returning batches
- [x] Batch commuter list: sort A–Z, swipe EDIT → form shows **that** commuter *(SHIVAM BHAKTA)*
- [x] Batch commuter list: Coming switch toggles `isComing` (same as Commuters list) *(toggled ADD KORE off then restored)*
- [x] Running batches → D2D channel opens *(admin Open channel Batch-01: 15 then 16 on board, Connection live)*
- [x] D2D Channel **+** add: rider appears on the live list (needs POP); no fake toast if they stay off the list *(2026-08-17: PG10/UG2/UG4 via search; toast after list)*
- [x] D2D add of a commuter on another batch still works if they have a POP *(PG10 Batch-10, UG2 Batch-02, UG4 Batch-04 — 4 on board both devices)*
- [x] Driver **STOP TRIP** sets `DTODLOG.isActive=false` + `endTime`; back without STOP does not *(2026-08-17: log 9 ended, live key for batch 4 deleted)*
- [x] Same-day reconnect after STOP → 4001 “already ended”, no retry *(driver + admin on-channel 2026-08-17)*
- [x] After editing a batch, Dashboard → **Add Batch** opens **Create** (not Update of the old id)
- [~] Same blank-create check for Add Commuter / Driver / Cab / Route / POP *(Add Commuter = Create blank; Route create verified; Driver/Cab/POP not opened)*
- [ ] Create commuter with Email filled and Address empty → saved address equals email *(skipped: dump not thin)*
- [x] Edit commuter does **not** overwrite email with `mail@email.com` or address with `"address"`
- [x] From a **batch** commuter list, edit then back → list still shows **only that batch**
- [ ] Commuter home / Track Cab stay on commuter UI when offline (no redirect to admin offline)

### Return batch (REST)

- [x] Admin: Return Batches picker shows counts (`GET status`)
- [x] Admin: Available tab lists org commuters not yet confirmed (`GET view`) *(5 org-wide, including TAUKIR)*
- [x] Admin: Confirm swipe (`POST add_commuter` with user id) *(TAUKIR → 1 confirmed / 4 available)*
- [x] Admin: Confirmed tab + capacity (`GET get_commuter`, hydrated names)
- [x] Admin: Remove swipe (`POST remove_commuter`) returns them to Available *(restored 0/5)*
- [ ] Admin: End return (`POST end`) then picker shows inactive *(skipped: would end the day’s return)*
- [x] Driver: RETURN LIST — Confirm/Remove; no End FAB *(2026-08-17: UG3/UG5/PG2/UG10/UG4 → 5 confirmed / 48 of 53; no End)*
- [x] Confirmed rider disappears from Available on this batch *(UG4 search empty after confirm; 1500→1495)*

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

### Current lab (2026-08-17 dummy org)

Two orgs now coexist. **Do not wipe** dump admin `9898927941` (Parul). New QA org:

| Role | Mobile | Password | Device |
|------|--------|----------|--------|
| Admin (new) | `7069036462` | `password` | `emulator-5554` |
| Driver 1 | `9876544111` | `password` | `5f36af49` (Batch-01) |
| Driver 4 | `9876544114` | `password` | Batch-04 — not this phone |
| UG4 | `9876556704` | `password` | phone swap after driver QA |

Counts: 10 batches / 1500 commuters / 10 routes / 30 POPs / 10 cabs **capacity 53** / 10 drivers. `.env` LAN `192.168.1.6`.

| Target | ADB | Status |
|--------|-----|--------|
| Pixel_10_Pro | `emulator-5554` | Admin `7069036462`. After STOP: Batch-01 gone from running list; Batch-08 still LIVE. Window scale 0.25. |
| Phone `2107113SI` | `5f36af49` | Last: UG4 home **COMING**. Open `cts_beta` before `adb` taps. Driver 1 is **`9876544111`** (not 4114). |

Dummy Batch-01 morning trip **ended 2026-08-17** (`GET …/get_d2d_log_status/4` → `status: ended`). Same-day START is 4001. Return Batch-01 has **5 confirmed** (UG3, UG4, UG5, UG10, PG2). High leftovers (A1, A6–A9, R4/R5) are not this pass.

---

## Bug reporting template

1. Role + account type
2. Route or screen name
3. Steps to reproduce
4. Expected vs actual
5. Online/offline
6. `flutter doctor -v` snippet if build-related
