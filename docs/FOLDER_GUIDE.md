# Documentation folder guide

Everything under `docs/` — open files in this order if you are lost.

```text
docs/
├── START_HERE.md          ← begin here
├── README.md              ← full library index
│
├── FLOWS_BY_ROLE.md       ← how each role clicks through the app
├── UI_ARCHITECTURE.md     ← every screen + provider + wireframe ASCII
├── CODE_MAP.md            ← where code lives in lib/
├── WIREFRAME_GALLERY.md   ← Flutter in-app debug stubs
├── wireframes/            ← interactive HTML demo (open index.html locally)
│   ├── index.html         ← start here in a browser
│   ├── styles.css
│   ├── app.js
│   ├── README.md
│   ├── DESIGN_SPEC.md
│   ├── INTERACTIONS.md
│   └── DOCS_ANALYSIS.md
├── SCREENSHOTS.md         ← what PNGs to capture
│
├── ARCHITECTURE.md        ← P1: layers, DI, data flow
├── ROUTING_AND_AUTH.md    ← P1: go_router + roles
├── FEATURES.md            ← P1: feature → screen → provider table
├── DESIGN_SYSTEM_REVIEW.md
│
├── OFFLINE_AND_SYNC.md    ← P2: batches sync + offline_temp
├── BUILD_AND_RELEASE.md   ← P2: APK / iOS / .env
├── TESTING.md             ← P2: analyze, test, QA checklists
├── API_AND_ENV.md         ← P2: API_BASE_URL, WebSocket
│
├── guides/                ← P3: end-user guides
│   ├── README.md
│   ├── ADMIN_USER_GUIDE.md
│   ├── DRIVER_USER_GUIDE.md
│   └── COMMUTER_USER_GUIDE.md
│
└── assets/screenshots/    ← P3: drop PNGs here (folders ready)
    ├── auth/
    ├── admin/
    ├── driver/
    ├── commuter/
    ├── shared/
    └── offline/
```

## Interactive HTML demo (preferred) + optional Flutter stubs

**Preferred:** open [wireframes/index.html](./wireframes/index.html) in a browser — no Flutter build.

```text
docs/wireframes/           ← interactive prototype (index.html)
lib/design/wireframes/     ← optional Flutter debug gallery
├── wireframe_catalog.dart
├── wireframe_gallery_screen.dart
├── wireframe_primitives.dart
└── screens/
```

Flutter route (debug only): `/designWireframes` — see [WIREFRAME_GALLERY.md](./WIREFRAME_GALLERY.md)
