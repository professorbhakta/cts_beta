# CTS interactive UI prototype

**One way to try the app design locally:** open this folder’s **`index.html`** in a browser.

No Flutter build. No server required (optional static server below).

---

## Open now

### Windows (PowerShell)

```powershell
start D:\cts_beta\docs\wireframes\index.html
```

Or double-click `index.html` in Explorer.

### Optional local server

```powershell
cd D:\cts_beta\docs\wireframes
python -m http.server 5500
```

Then open http://localhost:5500/

---

## Who this is for

| Audience | What to do |
|----------|------------|
| **PM / QA / new users** | Land on **How this app works** → pick a role or **Guided tour**. Follow captions, breadcrumbs, and “Tap here next”. |
| **Designers** | Match brand (black / yellow / orange), spacing, drawer, cards, modals. |
| **Developers** | Toggle **Dev panel** for `RouteName`, Flutter file path, Provider. Implement from [DESIGN_SPEC.md](./DESIGN_SPEC.md). |

---

## Files

| File | Role |
|------|------|
| [index.html](./index.html) | Shell: landing + demo workspace |
| [styles.css](./styles.css) | AppColors / design-system styling |
| [app.js](./app.js) | Navigation, CRUD, tours, modals, toasts |
| [DESIGN_SPEC.md](./DESIGN_SPEC.md) | Screen → route → widget → provider |
| [INTERACTIONS.md](./INTERACTIONS.md) | QA checklist (docs flows → taps) |
| [README.md](./README.md) | This file |

---

## What works (high level)

- Role landing + 3 guided tours  
- Sign in (role picker) / Sign up / Splash  
- Admin dashboard, drawer, sync banner  
- All major CRUD entities (Routes, POPs, Batches, Cabs, Drivers, Commuters)  
- Running → D2D Channel; Return batches → nested list; Batch → nested commuters  
- Driver START TRIP → D2D Log → Stop  
- Commuter Coming switch + confirm dialog  
- Offline tabs, FAB, drill-downs  
- Profile Logout; Back; Flow map; Dev panel; toasts & delete modals  

Full checklist: [INTERACTIONS.md](./INTERACTIONS.md). Gaps vs Flutter: [DESIGN_SPEC.md](./DESIGN_SPEC.md) § Gaps.

---

## Related docs

- [START_HERE.md](../START_HERE.md) · [FLOWS_BY_ROLE.md](../FLOWS_BY_ROLE.md) · [UI_ARCHITECTURE.md](../UI_ARCHITECTURE.md)  
- [FEATURES.md](../FEATURES.md) · [guides/](../guides/) · [WIREFRAME_GALLERY.md](../WIREFRAME_GALLERY.md) (Flutter debug stubs)
