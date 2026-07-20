# Flows by role

Simple **click-path** guides. For the full route list, see [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md).

---

## Admin

**Home:** `/adminHomeScreen` — Dashboard with stats and quick actions.

```mermaid
flowchart TD
  home[Admin dashboard]
  home --> drawer[Side drawer]
  home --> stats[Tap stat cards]
  home --> quick[Quick action grid]

  drawer --> d1[Dashboard]
  drawer --> d2[Profile]
  drawer --> d3[Commuters / POPs / Batches / Cabs / Drivers / Routes]
  drawer --> d4[Offline mode if shown]

  stats --> d3
  quick --> forms[Add forms directly]
  quick --> running[Running batches]
  quick --> returnB[Return batches]

  running --> d2d[D2D Channel per batch]
  d3 --> list[List screen]
  list --> form[Create or edit form]
  list --> nested[Commuter list for batch - nested push]
  returnB --> returnList[Return commuter list - nested push]
```

| Goal | How |
|------|-----|
| Add a route | Dashboard → **Add Route** *or* Drawer → Routes → **+** |
| See live trips | Quick action **Running Batches** → tap batch → **D2D Channel** |
| Manage return trip | Batches screen → return icon *or* quick action **Return Batches** |
| Work offline | Drawer → **Offline Mode** (when enabled) |
| Log out | Drawer → Profile → **Logout** |

---

## Driver

**Home:** `/driverHomeScreen` — Today’s assignment (batch, time, cab).

| Step | Action |
|------|--------|
| 1 | Open app → sign in as driver |
| 2 | Review assignment card; optional **call admin** |
| 3 | Tap **START TRIP** → `/d2dLog/:batchId` |
| 4 | Use commuter list (call / status actions) |
| 5 | Stop trip → back to driver home |

```mermaid
flowchart LR
  dh[Driver home] --> trip[D2D log]
  trip --> dh
```

---

## Commuter

**Home:** `/commuterHomeScreen` — Greeting + **Coming today** switch.

| Step | Action |
|------|--------|
| 1 | Open app → sign in as commuter |
| 2 | Toggle **Coming** switch |
| 3 | Confirm in dialog |
| 4 | Pull to refresh to reload profile |

---

## Everyone (auth)

| Step | Screen |
|------|--------|
| App launch | Splash → resolves session |
| Not logged in | Sign in → optional Sign up |
| Debug only | Sign in → **Preview UI wireframes** |

---

## Wireframe previews (same flows, no data)

Open [WIREFRAME_GALLERY.md](./WIREFRAME_GALLERY.md) and pick the screen that matches your role above.
