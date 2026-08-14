> **Doc:** docs/INTEGRATION.md
> **Updated:** 2026-08-14 21:55 IST
> **Session:** DTODLOG on connect; driver STOP; ADD by user ID

# Integration — Full-Stack Overview

College/office shuttle management platform spanning `D:\cts_beta` (Flutter) and `D:\cts-docker` (Django).

## Purpose

- **Admin** — routes, batches (time slots), pickup points (POPs), cabs, drivers, commuters
- **Driver** — live door-to-door (D2D) pickup log via WebSocket during morning runs
- **Commuter** — assigned to batch/cab/POP; toggles `isComing` for daily attendance

## Two codebases

| Repo | Path | Role |
|------|------|------|
| **Flutter app** | `D:\cts_beta` | iOS/Android mobile client |
| **Backend pack** | `D:\cts-docker` | Dockerized Django API + WebSocket server |

Separate git repos. Backend runs via Docker Desktop; Flutter connects over LAN HTTP/WebSocket.

## Technology summary

| Layer | Technology |
|-------|------------|
| Mobile | Flutter, Provider (`ChangeNotifier`), go_router |
| API | Django 4.2.5 + Django REST Framework 3.14 |
| Real-time | Django Channels 4 + Uvicorn ASGI |
| Database | PostgreSQL 16 |
| Cache | Redis — morning `d2d:live:…`, evening `{date}_{batch}`; Channels uses InMemoryLayer for WS broadcast |
| Reverse proxy | Nginx on host port 80 |

## Django apps (`D:\cts-docker\django`)

| App | Responsibility |
|-----|----------------|
| `user_servcies` | Custom User (mobile login), commuter, driver, subAdmin |
| `cab_services` | Routes, batches, pickup points, cabs |
| `d2d_log` | DTODLOG model, WebSocket consumer, D2D REST, return batch REST |

## API URL prefixes

| Prefix | Purpose |
|--------|---------|
| `/user/` | Auth, user CRUD by role |
| `/cab/` | Fleet & scheduling |
| `/d2d/` | Running batches, return batch, D2D status |
| `/void/` | Django admin (intentionally obscured) |
| `/ws/<batch_id>/` | Live D2D WebSocket (ASGI, proxied by Nginx) |

## User types

- `ADMIN` — manages fleet; monitors live D2D via WebSocket
- `DRIVER` — runs live D2D log; confirms pickups
- `COMMUTER` — self-service `isComing` toggle

Login field: **mobile number**. Auth uses Django session cookies on REST. D2D WebSocket sends the same `sessionid` on connect: anonymous **4401**, not ADMIN/assigned DRIVER **4403**. Role is not re-checked on every ADD/DELETE/STOP. Public Flutter sign-up is disabled; backend `POST /user/` still trusts client `userType`.

## Critical features

- **Live D2D WebSocket** — [features/D2D_E2E.md](./features/D2D_E2E.md) ✅ fixes applied. `DTODLOG` on connect; only driver `STOP` ends the day; admin ADD looks up by user ID
- **Evening return batch** — [features/RETURN_BATCH_E2E.md](./features/RETURN_BATCH_E2E.md) ✅ admin + driver UI wired

---

## Architecture diagrams

Mermaid diagrams — updated Aug 2026 after Fix 2 (live Redis) + return batch integration.

### Docker request flow

```mermaid
flowchart LR
  App[Flutter App / Postman]
  Nginx[C2S-Nginx :80]
  Django[C2S-Django Uvicorn :8000]
  PG[(C2S-PostgresDB)]
  Redis[(C2S-redis)]

  App -->|HTTP REST| Nginx
  App -->|WebSocket /ws/id/| Nginx
  Nginx --> Django
  Django --> PG
  Django --> Redis
```

### Backend Django apps + Redis key spaces

```mermaid
flowchart TB
  subgraph c2s [Django project c2s]
    US[user_servcies]
    CS[cab_services]
    D2D[d2d_log]
  end

  US -->|User commuter Driver| PG[(PostgreSQL)]
  CS -->|Batch Route cab POP| PG
  D2D -->|DTODLOG| PG
  D2D -->|Return set dd-mm-yyyy_batch| Redis[(Redis)]
  D2D -->|Live DS d2d:live:date:batch| Redis
  D2D -->|WebSocket consumer| WS[Channels / ASGI]
```

### Live D2D WebSocket sequence (current)

```mermaid
sequenceDiagram
  participant Driver as Driver App
  participant Admin as Admin App
  participant Nginx
  participant Consumer as d2d Consumer
  participant DB as DTODLOG Postgres
  participant Live as Redis d2d:live

  Driver->>Nginx: WS connect /ws/1/ + Cookie sessionid
  Nginx->>Consumer: upgrade
  Consumer->>Consumer: AuthMiddlewareStack — reject 4401/4403 if needed
  Consumer->>DB: get_or_create DTODLOG today
  Consumer->>Live: get or rebuild DS
  Consumer->>Driver: result snapshot

  Admin->>Nginx: WS connect /ws/1/
  Consumer->>Live: read same DS
  Consumer->>Admin: result snapshot

  Driver->>Consumer: REMOVE CLIST user_id
  Consumer->>DB: extend CList
  Consumer->>Live: update DS
  Consumer->>Driver: broadcast
  Consumer->>Admin: broadcast

  Driver->>Consumer: STOP
  Consumer->>DB: isActive=false endTime
  Consumer->>Live: delete key
  Note over Driver: Reconnect same day → close 4001
```

### Evening return REST sequence (current)

```mermaid
sequenceDiagram
  participant Admin as Admin App
  participant Dio as Dio REST
  participant API as return_batch_views
  participant R as Redis set
  participant DB as Postgres

  Admin->>Dio: GET status/batchId
  Dio->>API: batch card stats
  Admin->>Dio: GET view/batchId
  API->>DB: isComing True
  Admin->>Dio: POST add_commuter {batch_id, commuter_id}
  API->>R: SADD
  API->>DB: isComing False
  Admin->>Dio: GET get_commuter/batchId
  API->>R: SMEMBERS + hydrate default
  Admin->>Dio: POST remove_commuter {batch_id, commuter_id}
  API->>R: SREM
  API->>DB: isComing True
  Admin->>Dio: POST end/batchId
  API->>R: DEL key
```

### Morning vs evening (two systems, one Redis server)

```mermaid
flowchart TB
  subgraph morning [Live D2D Morning]
    WS[WebSocket]
    LiveKey["Redis d2d:live:YYYY-MM-DD:id"]
    WS --> LiveKey
  end

  subgraph evening [Return Batch Evening]
    REST[REST API]
    RetKey["Redis dd-mm-yyyy_id"]
    REST --> RetKey
  end

  morning -.->|Separate keys no cross-clear| evening
```

### Flutter app layers

```mermaid
flowchart TB
  Screens[Screens / Widgets]
  Providers[ChangeNotifier Providers]
  Repos[Repositories]
  API[Dio / WebSocketChannel]
  Config[AppConfig .env]

  Screens --> Providers
  Providers --> Repos
  Repos --> API
  API --> Config
```

### Live state architecture (Fix 2 — done)

```mermaid
flowchart LR
  Consumer[d2d Consumer]
  RedisLive["Redis d2d:live:date:batch"]
  PG[(DTODLOG audit CList)]
  Channel[InMemory Channel Layer broadcast only]

  Consumer --> RedisLive
  Consumer --> PG
  Consumer --> Channel
```

### Full day cycle

```mermaid
flowchart LR
  A[Commuters isComing True] --> B[Morning Live D2D WS]
  B --> C[Driver REMOVE to CList]
  B --> D[STOP isComing False for picked up]
  D --> E[Evening Return REST Admin]
  E --> F[Confirm add Redis set]
  F --> G[Remove or End return]
```

---

## Related

- [GLOSSARY.md](./GLOSSARY.md)
- [LOCAL_DEV.md](./LOCAL_DEV.md)
- [backend/02-data-model.md](./backend/02-data-model.md)
- [features/D2D_E2E.md](./features/D2D_E2E.md)
- [features/RETURN_BATCH_E2E.md](./features/RETURN_BATCH_E2E.md)
