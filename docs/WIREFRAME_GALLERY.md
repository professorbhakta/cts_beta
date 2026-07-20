# Wireframe gallery (in-app)

Debug-only **layout previews**—same structure as production screens, **no API** and **no login** (debug builds).

---

## How to open

### Option A — From sign in (easiest)

1. Run a **debug** build: `flutter run`
2. On **Sign in**, tap **Preview UI wireframes (debug)** at the bottom

### Option B — Deep link / route

Navigate to:

```text
/designWireframes
```

Detail screen:

```text
/designWireframes/<id>
```

Example: `/designWireframes/admin_dashboard`

---

## Catalog

| ID | Screen | Role |
|----|--------|------|
| `auth_sign_in` | Sign in | All |
| `admin_dashboard` | Admin dashboard | Admin |
| `crud_list` | CRUD list (Routes template) | Admin |
| `crud_form` | CRUD form | Admin |
| `driver_home` | Driver home | Driver |
| `d2d_live` | D2D live list | Driver / Admin |
| `commuter_home` | Commuter home | Commuter |
| `offline_home` | Offline tabs | Admin |
| `profile` | Profile | Logged-in |

Source of truth: [`lib/design/wireframes/wireframe_catalog.dart`](../lib/design/wireframes/wireframe_catalog.dart).

---

## Code layout

```
lib/design/wireframes/
├── wireframe_catalog.dart       # IDs + metadata
├── wireframe_gallery_screen.dart # Hub + detail
├── wireframe_primitives.dart    # WireframeBlock helpers
└── screens/                     # One file per preview
```

Routes registered only when `kDebugMode` is true ([`app_router.dart`](../lib/app/router/app_router.dart)).

---

## Release builds

Wireframe routes are **not** registered in release. The gallery screen shows a short “debug only” message if opened accidentally.

---

## Related docs

- ASCII wireframes: [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md) §3  
- User flows: [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md)  
- Onboarding: [START_HERE.md](./START_HERE.md)  
