# Start here

**Who you are** → **What to read** → **Optional: see layouts in the app**

This guide is for anyone new to the CTS (c2s) mobile app—product, design, QA, or development.

---

## 1. Pick your path

| I am… | Read first | Then | Try layouts |
|--------|------------|------|-------------|
| **Product / PM** | [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) | [guides/ADMIN_USER_GUIDE.md](./guides/ADMIN_USER_GUIDE.md) | **[wireframes/index.html](./wireframes/index.html)** (browser) |
| **Designer** | [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) | [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md) §3 · **[wireframes/](./wireframes/)** | **[wireframes/index.html](./wireframes/index.html)** locally |
| **New developer** | [CODE_MAP.md](./CODE_MAP.md) | [ARCHITECTURE.md](./ARCHITECTURE.md) → [FEATURES.md](./FEATURES.md) | HTML demo first; optional Flutter `/designWireframes` |
| **QA** | [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) · [TESTING.md](./TESTING.md) | [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md) · [wireframes/INTERACTIONS.md](./wireframes/INTERACTIONS.md) | **[wireframes/index.html](./wireframes/index.html)** + role test accounts |

Full doc index: [README.md](./README.md)

### Documentation packs (all published)

| Pack | Docs |
|------|------|
| **P1 Architecture** | [ARCHITECTURE.md](./ARCHITECTURE.md) · [ROUTING_AND_AUTH.md](./ROUTING_AND_AUTH.md) · [FEATURES.md](./FEATURES.md) |
| **P2 Operations** | [OFFLINE_AND_SYNC.md](./OFFLINE_AND_SYNC.md) · [BUILD_AND_RELEASE.md](./BUILD_AND_RELEASE.md) · [TESTING.md](./TESTING.md) · [API_AND_ENV.md](./API_AND_ENV.md) |
| **P3 Guides & visuals** | [guides/](./guides/) · **[wireframes/index.html](./wireframes/index.html)** · [WIREFRAME_GALLERY.md](./WIREFRAME_GALLERY.md) · [SCREENSHOTS.md](./SCREENSHOTS.md) |

---

## 2. The app in one minute

- **Flutter** app for **iOS & Android**.
- **Three roles:** Admin (manage transport), Driver (run trips), Commuter (mark “coming today”).
- **Navigation:** `go_router` with login guards ([`lib/app/router/app_router.dart`](../lib/app/router/app_router.dart)).
- **State:** Provider (`ChangeNotifier`) wired in [`lib/app/app_providers.dart`](../lib/app/app_providers.dart).
- **UI building blocks:** [`lib/widgets/`](../lib/widgets/) (drawer, dashboard shell, lists, forms).

```mermaid
flowchart LR
  open[Open app] --> splash[Splash]
  splash --> login{Logged in?}
  login -->|No| signIn[Sign in]
  login -->|Yes| role{Role}
  role --> admin[Admin dashboard]
  role --> driver[Driver home]
  role --> commuter[Commuter home]
  signIn --> role
```

---

## 3. Folder map (simple)

| Folder | What lives here |
|--------|------------------|
| `lib/app/` | App entry, theme, router, dependency injection |
| `lib/features/*/` | One folder per feature (screens + providers + data) |
| `lib/widgets/` | Reusable UI (drawer, buttons, list cards) |
| `lib/design/wireframes/` | Debug layout previews (no API) |
| `docs/` | You are here |

Details: [CODE_MAP.md](./CODE_MAP.md).

---

## 4. See layouts locally (no Flutter needed)

**Preferred for design review:** open the HTML gallery:

1. Go to [wireframes/](./wireframes/)
2. Open **`index.html`** in your browser (double-click or see [wireframes/README.md](./wireframes/README.md))

**Optional — Flutter debug stubs:**

1. Run the app (`flutter run`).
2. On **Sign in**, tap **Preview UI wireframes (debug)**, or open `/designWireframes`.

See [WIREFRAME_GALLERY.md](./WIREFRAME_GALLERY.md).

---

## 5. Keep docs updated

When you change routes, roles, or major screens, update:

1. [UI_ARCHITECTURE.md](./UI_ARCHITECTURE.md) navigation table  
2. [FLOWS_BY_ROLE.md](./FLOWS_BY_ROLE.md) if user journeys change  
3. [wireframe_catalog.dart](../lib/design/wireframes/wireframe_catalog.dart) if layout patterns change  
