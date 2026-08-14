> **Doc:** docs/guides/ADMIN_USER_GUIDE.md
> **Updated:** 2026-08-14 22:00 IST
> **Session:** Return available = any unconfirmed org commuter

# Admin user guide

Short guide for **transport administrators** using the c2s app.

**Flows:** [FLOWS_BY_ROLE.md](../FLOWS_BY_ROLE.md) · **Screens:** [UI_ARCHITECTURE.md](../UI_ARCHITECTURE.md)

---

## Sign in

There is **no Sign Up** on the login screen. You create driver and commuter accounts from the app (CRUD).

1. Open the app → wait for splash
2. Enter **mobile** and **password**
3. Tap **Login** → you land on the **Dashboard**

<!-- After capture: ![Sign in](../assets/screenshots/auth/sign_in.png) -->

---

## Dashboard

<!-- After capture: ![Dashboard](../assets/screenshots/admin/dashboard.png) -->

- **Stat cards** — tap Batches, Commuters, Routes, etc. to open that section
- **Quick actions** — **Add …** opens a **new blank form** (not the last person you edited). Running / Return batches skip the drawer.

Pull down to **refresh** counts.

---

## Side menu (drawer)

Tap **☰** (menu):

| Item | Use for |
|------|---------|
| Dashboard | Home overview |
| Profile | Your details, logout |
| Commuters | Manage commuters |
| Pick-up Points | Manage POPs |
| Batches | Schedules and assignments |
| Cabs | Vehicles |
| Drivers | Driver accounts |
| Routes | Route definitions |
| Offline Mode | Local prototype tools (if shown) |

If you see **Sync** banner — tap **Sync now** after reconnecting to send pending batch changes.

---

## Typical tasks

### Add a commuter

Drawer → **Commuters** → **+** → fill form → Save  
*Or* Dashboard → **Add Commuter** (blank form)

- **Email** is required
- **Address** is optional. If you leave it empty the first time, the app stores the email as the address. Later edits keep the last saved address unless you type a new one.

### Edit a commuter on a batch

Batches → tap a batch → swipe **EDIT** on that row. The form is for the person you swiped, even after A–Z sort.

Use the **Coming** switch on that list (or Drawer → **Commuters**) to mark whether they are riding today.

### Create a batch

Drawer → **Batches** → **+** → set name, dates, times → Save

### Monitor live trips

Dashboard → **Running Batches** → tap a batch → **D2D Channel** (live commuter list).

Tap **+** to add a rider from the full commuter list. They show on the live list only after the server accepts the add (they need a pick-up point). **Close channel** leaves the trip running — it does **not** stop the morning trip. Only the driver **STOP TRIP** button ends it for the day.

### Return trip

Dashboard → **Return Batches** (or Batches screen → return icon) → tap a batch:

1. **Available** — every org commuter not already confirmed for a return trip today (any morning batch); swipe **Confirm** to give a seat
2. **Confirmed** — seated list; swipe **Remove** to put them back in the pool
3. **End return** — clears the evening trip and restores Coming flags

Capacity shows on the confirmed banner. Drivers can **Confirm** and **Remove** on their return list; only admin can **End return**.

### Log out

Drawer → **Profile** → **Logout**

---

## Tips

- Use **search** on list screens to filter by name or time
- **Swipe** a list row for edit or delete (confirm delete carefully). Edit always applies to the row you swiped.
- On large tablets, navigation may stay visible on the left instead of a drawer

---

## Need help?

- In-app errors often mean network or server — check Wi‑Fi and try refresh
- Developers: see [API_AND_ENV.md](../API_AND_ENV.md) for server URL setup
