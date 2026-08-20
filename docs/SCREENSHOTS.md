# Screenshots

Visual appendix for docs and onboarding. **Screenshots are not auto-generated** — add PNGs to the repo as the UI stabilizes.

---

## Folder layout

Store images under:

```text
docs/assets/screenshots/
├── auth/
│   sign_in.png
│   sign_up.png
├── admin/
│   dashboard.png
│   routes_list.png
│   running_batches.png
│   d2d_channel.png
├── driver/
│   home.png
│   d2d_log.png
├── commuter/
│   home.png
├── shared/
│   profile.png
│   drawer.png
└── offline/
    offline_home.png
```

See [assets/screenshots/README.md](./assets/screenshots/README.md) for capture instructions.

---

## Suggested capture checklist

| # | Screen | Route / how to open | Role |
|---|--------|---------------------|------|
| 1 | Sign in | `/signIn` | — |
| 2 | Admin dashboard | Login as admin | ADMIN |
| 3 | Routes list | Drawer → Routes | ADMIN |
| 4 | Running batches | Quick action | ADMIN |
| 5 | D2D channel | Tap running batch | ADMIN |
| 6 | Driver home | Login as driver | DRIVER |
| 7 | D2D log | START TRIP | DRIVER |
| 8 | Commuter home | Login as commuter | COMMUTER |
| 9 | Profile | Drawer → Profile | Any |
| 10 | Offline home | Drawer → Offline | ADMIN |

Use **light and dark mode** optionally: `ThemeMode.system` — capture both if branding review needs it.

---

## Screenshots vs live app

| Type | Location | Use |
|------|----------|-----|
| Live app | Lab devices / emulator | Layout + real data |
| Screenshots | `docs/assets/screenshots/` | Real UI, marketing, QA baselines |

---

## Embedding in markdown

After adding files:

```markdown
![Admin dashboard](./assets/screenshots/admin/dashboard.png)
```

Link from [guides/ADMIN_USER_GUIDE.md](./guides/ADMIN_USER_GUIDE.md) once images exist.

---

## P3 status

- [x] Folder structure and checklist (this doc)
- [x] Category folders under `assets/screenshots/{auth,admin,driver,commuter,shared,offline}/`
- [x] Placeholder image comments in [guides/](./guides/) (uncomment when PNGs exist)
- [ ] PNG files committed (team to capture from device/emulator)
- [ ] Uncomment / enable embedded images in user guides
