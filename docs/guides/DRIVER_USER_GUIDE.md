# Driver user guide

Short guide for **drivers** using the c2s app.

**Flows:** [FLOWS_BY_ROLE.md](../FLOWS_BY_ROLE.md)

---

## Sign in

1. Open the app
2. Enter mobile and password (account created by admin)
3. Tap **Login** → **Driver home**

---

## Your home screen

<!-- After capture: ![Driver home](../assets/screenshots/driver/home.png) -->

You see:

- **Today’s date**
- **Batch** name, **start time**, **cab** registration
- **Call admin** (phone icon) if admin number is on file

If nothing appears, pull to refresh or contact admin — you may not be assigned to a batch yet.

---

## Start a trip (door-to-door)

<!-- After capture: ![D2D log](../assets/screenshots/driver/d2d_log.png) -->

1. Confirm assignment details
2. Tap **START TRIP**
3. You enter the **trip log** — list of commuters for this batch
4. Use row actions to **call** or update status as your organization defines
5. When finished, use **Stop trip** (or back) to return home

Stay on this screen during the trip so live updates work (requires network / WebSocket).

---

## Menu and profile

Open **☰** for navigation (may show admin items — ignore unless your role allows them).

Use **Profile** from the drawer to view info or **logout** at end of day.

---

## Tips

- Enable mobile data or Wi‑Fi before **START TRIP**
- If trip screen fails to load, tap retry or restart app after checking signal
- Do not share your login password

---

## Preview layout (debug)

Developers can open **Preview UI wireframes** on sign-in → **Driver home** / **D2D live** without logging in (debug builds only). See [WIREFRAME_GALLERY.md](../WIREFRAME_GALLERY.md).
