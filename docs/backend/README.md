> **Doc:** docs/backend/README.md
> **Updated:** 2026-08-25 21:50 IST
> **Session:** Stable BE pointer map (+ client pack modules)

# Backend guide — pointers only

Canonical docs live outside this folder. Do **not** reintroduce numbered `01–04` specs here.

| Concern | Owner |
|---------|--------|
| Docker / Nginx / LAN / Postgres backup | [../LOCAL_DEV.md](../LOCAL_DEV.md) |
| REST + WebSocket wire (incl. client pack 7 APIs) | [../API_CONTRACTS.md](../API_CONTRACTS.md) |
| Morning D2D UI + consumer notes | [../../lib/features/d2d/README.md](../../lib/features/d2d/README.md) |
| Return batch UI + Redis notes | [../../lib/features/batches/README.md](../../lib/features/batches/README.md) |
| E2E morning / return | [../features/D2D_E2E.md](../features/D2D_E2E.md) · [../features/RETURN_BATCH_E2E.md](../features/RETURN_BATCH_E2E.md) |
| Session status | [../../PROJECT_BRAIN.md](../../PROJECT_BRAIN.md#6-status-snapshot) |

## Repo layout (`D:\cts-docker`)

```
D:\cts-docker\
├── docker-compose.yml
├── .env
├── nginx/nginx.conf          # client_max_body_size 8m
├── postgres/                 # + backups/ via C2S-PostgresBackup
└── django/
    ├── c2s/
    ├── user_servcies/
    ├── cab_services/
    └── d2d_log/              # WS + return REST + client pack
```

### `d2d_log` modules (stable)

| Module | Role |
|--------|------|
| `consumers.py` | Morning WS (ADD/REMOVE/DELETE/STOP); auth 4401/4403; ended 4001 |
| `live_state.py` | Redis `d2d:live:…` |
| `board_commuter` (helper) | Shared by WS REMOVE + `boarding_scan` |
| `odometer_views.py` | start / end / get / org / photo |
| `boarding_views.py` | boarding_qr / boarding_scan / boarding_unboard |
| `boarding_tokens.py` / `boarding_auth.py` | QR token |
| `return_batch_views.py` + `return_batch_utils.py` | Evening REST + Redis `{dd-mm-yyyy}_{id}` |
| `models.py` | DTODLOG (+ nullable odometer cols) |
| `urls.py` | All `/d2d/…` routes |
| `test_odometer.py` / `test_boarding_scan.py` | BE unit tests |
