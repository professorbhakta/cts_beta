# Admin user guide

Short guide for **transport administrators** using the c2s app.

**Flows:** [FLOWS_BY_ROLE.md](../FLOWS_BY_ROLE.md) · **Screens:** [UI_ARCHITECTURE.md](../UI_ARCHITECTURE.md)

---

## Sign in

1. Open the app → wait for splash
2. Enter **mobile** and **password**
3. Tap **Login** → you land on the **Dashboard**

<!-- After capture: ![Sign in](../assets/screenshots/auth/sign_in.png) -->

---

## Dashboard

<!-- After capture: ![Dashboard](../assets/screenshots/admin/dashboard.png) -->

- **Stat cards** — tap Batches, Commuters, Routes, etc. to open that section
- **Quick actions** — add entities or open Running / Return batches without the drawer

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
*Or* Dashboard → **Add Commuter**

### Create a batch

Drawer → **Batches** → **+** → set name, dates, times → Save

### Monitor live trips

Dashboard → **Running Batches** → tap a batch → **D2D Channel** (live commuter list)

### Return trip

Drawer → **Batches** → toolbar **return** icon → select batch → manage return commuters

### Log out

Drawer → **Profile** → **Logout**

---

## Tips

- Use **search** on list screens to filter by name or time
- **Swipe** a list row for edit or delete (confirm delete carefully)
- On large tablets, navigation may stay visible on the left instead of a drawer

---

## Need help?

- In-app errors often mean network or server — check Wi‑Fi and try refresh
- Developers: see [API_AND_ENV.md](../API_AND_ENV.md) for server URL setup
