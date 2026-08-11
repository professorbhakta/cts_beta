# INTERACTIONS checklist

Map documented flows → taps in [index.html](./index.html). Use for QA / PM walkthroughs.

Legend: ✅ implemented in HTML demo

---

## Landing & tours

| Flow (docs) | Interaction | Status |
|-------------|-------------|--------|
| START_HERE / guides roles | Role cards: Try Admin / Driver / Commuter | ✅ |
| FLOWS_BY_ROLE guided learning | Guided tour per role (callouts + Next) | ✅ |
| Orientation | Breadcrumb “You are here” + Back + How it works | ✅ |
| Screen purpose | Caption under breadcrumb | ✅ |
| Navigation overview | Flow map toggle (jump nodes) | ✅ |

---

## Auth (ROUTING_AND_AUTH · guides)

| Flow | Tap path | Status |
|------|----------|--------|
| Splash → Sign in | Try role → splash spinner → SignIn | ✅ |
| Login → role home | LOGIN → pick Admin/Driver/Commuter | ✅ |
| Sign up | Sign Up link → form → back to Sign in | ✅ |
| Logout | Profile → Logout → Sign in | ✅ |

---

## Admin (ADMIN_USER_GUIDE · FLOWS)

| Flow | Tap path | Status |
|------|----------|--------|
| Open drawer | ☰ → drawer slides + dim backdrop | ✅ |
| Drawer → Dashboard / Profile / CRUD / Offline | Drawer items | ✅ |
| Sync banner | Sync now → toast, banner clears | ✅ |
| Stat cards → lists | Batches / Commuters / Routes / POPs / Cabs / Drivers | ✅ |
| Quick action → create form | Add Batch/Commuter/Driver/Cab/Route/POP | ✅ |
| Quick action → Running | Running Batches | ✅ |
| Quick action → Return | Return Batches | ✅ |
| Running → D2D Channel | Tap running card | ✅ |
| Close Channel | FAB → back to Running + toast | ✅ |
| Return → nested list | Tap return batch → Confirm rider | ✅ |
| Batch → nested CommuterList | Row 👥 button | ✅ |
| CRUD search | Type in search → filter rows | ✅ |
| CRUD edit | Edit → form prefilled → Update | ✅ |
| CRUD delete | Del → ConfirmationDialog Cancel/Delete → row gone + toast | ✅ |
| CRUD create | FAB / AppBar ＋ → Save → new row + toast | ✅ |
| Batches return icon | AppBar ↩ → Return Batches | ✅ |

---

## Driver (DRIVER_USER_GUIDE)

| Flow | Tap path | Status |
|------|----------|--------|
| Assignment card | Date, Batch, Time, Cab visible | ✅ |
| Call admin | 📞 → toast | ✅ |
| START TRIP | → D2D Log + toast | ✅ |
| Call rider | 📞 on row | ✅ |
| Stop trip | FAB → Driver home | ✅ |

---

## Commuter (COMMUTER_USER_GUIDE)

| Flow | Tap path | Status |
|------|----------|--------|
| Coming switch | Toggle → confirm dialog | ✅ |
| Confirm | CONFIRM → switch state + “Status updated” toast | ✅ |
| Cancel | Cancel → no change | ✅ |

---

## Offline (OFFLINE_AND_SYNC)

| Flow | Tap path | Status |
|------|----------|--------|
| Bottom tabs | Routes / Batches / People / Out | ✅ |
| People tab FAB | → OfflineCommuterForm → Save locally → list | ✅ |
| Other tab FAB | Routes/Batches add toast; Out tab export toast | ✅ |
| Route drill-down | Tap offline route → Offline POPs | ✅ |
| Batch drill-down | Tap offline batch → Offline Commuters | ✅ |
| Overflow menu | ⋮ → toast (import/dump/refresh) | ✅ |

---

## Developer

| Flow | Interaction | Status |
|------|-------------|--------|
| Design ↔ code | Dev panel: Widget, RouteName, path, file, provider, docs | ✅ |
| Spec table | DESIGN_SPEC.md | ✅ |

---

## Related MD flows (reference only)

| Doc section | Covered by |
|-------------|------------|
| UI_ARCHITECTURE §3.1–3.10 | Matching screens in demo |
| TESTING manual QA auth/CRUD/D2D | Rows above |
| SCREENSHOTS checklist | Same screen set |
| BUILD / API / ARCHITECTURE internals | Out of UI scope (see [ARCHITECTURE.md](../ARCHITECTURE.md)) |
