> **Doc:** docs/backend/README.md
> **Updated:** 2026-08-19 18:25 IST
> **Session:** M4 view split home/overflow + Flutter Available sections

# Backend Guide — `D:\cts-docker`

Entry point for Django/Docker backend work.

## Repo layout

```
D:\cts-docker\
├── docker-compose.yml
├── .env
├── nginx/nginx.conf
├── postgres/          # Dockerfile, dumps20.sql seed
└── django/
    ├── c2s/           # settings, urls, asgi
    ├── user_servcies/
    ├── cab_services/
    └── d2d_log/       # ★ D2D WebSocket + REST
```

## Key files for D2D

| File | Purpose |
|------|---------|
| `d2d_log/consumers.py` | WebSocket — connect auth (4401/4403), REMOVE/ADD (user ID lookup)/DELETE/STOP (driver only) |
| `d2d_log/live_state.py` | Morning live queue Redis (`d2d:live:…`) |
| `d2d_log/routing.py` | WS URL patterns `/ws/<batch_id>/` |
| `d2d_log/views.py` | REST: running_batches, get_d2d_log_status |
| `d2d_log/return_batch_views.py` | REST: return batch endpoints |
| `d2d_log/return_batch_utils.py` | Return Redis + business logic |
| `d2d_log/return_attendance.py` | STOP-gated CList read (live trip not eligible) |
| `d2d_log/return_allocator.py` | Pure home/overflow math; JSON extras names |
| `d2d_log/return_pool.py` | Adapter views should call; fail closed omits extras |
| `d2d_log/test_return_allocator.py` | Allocator + extras (no live DB, no REST / WS) |
| `d2d_log/utils.py` | Shared helpers, get_d2d_log_data, Redis connect |
| `d2d_log/models.py` | DTODLOG model |
| `d2d_log/test_d2d_fixes.py` | Morning D2D verification script |
| `d2d_log/test_return_batch_fixes.py` | Return batch verification script |

## Return batch REST (evening)

All used by Flutter. Full mapping: [../API_CONTRACTS.md](../API_CONTRACTS.md). Lifecycle: [04-return-batch-lifecycle.md](./04-return-batch-lifecycle.md).

| Method | Path | Role in app |
|--------|------|-------------|
| GET | `/d2d/return_batch/view/<batch_id>` | Available tab: `home[]` then `overflow[]` (breaking; not org dump) |
| GET | `/d2d/return_batch/status/<batch_id>` | Picker counts / capacity / `is_active`; optional `home_hold`, `overflow_confirmed`, `overflow_remaining` |
| GET | `/d2d/return_batch/get_commuter/<batch_id>` | Confirmed list (hydrate default on) |
| POST | `/d2d/return_batch/add_commuter` | Confirm `{ batch_id, commuter_id }` |
| POST | `/d2d/return_batch/remove_commuter` | Remove (same body) |
| POST | `/d2d/return_batch/end/<batch_id>` | End trip (Flutter POST; backend also allows GET) |

## Docs in this guide

| Doc | Topic |
|-----|-------|
| [../../PROJECT_BRAIN.md](../../PROJECT_BRAIN.md#6-status-snapshot) | Done vs pending (short) |
| [01-docker-stack.md](./01-docker-stack.md) | Containers, Nginx, startup |
| [02-data-model.md](./02-data-model.md) | Postgres, **two Redis key spaces**; User.email / address Flutter rules |
| [03-d2d-websocket-lifecycle.md](./03-d2d-websocket-lifecycle.md) | Live D2D |
| [04-return-batch-lifecycle.md](./04-return-batch-lifecycle.md) | Evening REST + Redis |
| [05-audit-and-gaps.md](./05-audit-and-gaps.md) | Remaining flaws |
| [06-planned-fixes.md](./06-planned-fixes.md) | Morning fixes ✅ done |
| [04-return-batch-lifecycle.md](./04-return-batch-lifecycle.md) | Evening return ✅ done |

## Cross-repo references

- API ↔ Flutter: [../API_CONTRACTS.md](../API_CONTRACTS.md)
- E2E morning trip: [../features/D2D_E2E.md](../features/D2D_E2E.md)
- E2E return trip: [../features/RETURN_BATCH_E2E.md](../features/RETURN_BATCH_E2E.md)

## Also in backend repo

- `D:\cts-docker\WEBSOCKET_FIXES.md` — Nginx/uvicorn/routing fixes log
