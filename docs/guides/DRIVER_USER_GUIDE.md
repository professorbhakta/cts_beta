> **Doc:** docs/guides/DRIVER_USER_GUIDE.md
> **Updated:** 2026-08-14 22:00 IST
> **Session:** Driver can confirm/remove return riders

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
5. When finished, tap **STOP TRIP**. That ends the morning trip for this batch **today**. Pressing **back** only leaves the live screen — the trip stays active until STOP.

Stay on this screen during the trip so live updates work (requires network / WebSocket).

If you reopen the log the same day after STOP, the app shows **trip already ended** (close 4001). A new log starts tomorrow.

---

## Evening return list

If admin has a return trip for your batch:

1. On **Driver home**, tap **RETURN LIST**
2. **Available** shows every rider not yet given a return seat (including other morning batches)
3. Swipe **Confirm** to add them to **Confirmed** — they leave Available
4. Swipe **Remove** on Confirmed to put them back
5. You cannot **End return** — that stays with admin

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

## Related

Screen structure: [UI_ARCHITECTURE.md](../UI_ARCHITECTURE.md). Lab accounts: [LOCAL_DEV.md](../LOCAL_DEV.md).
