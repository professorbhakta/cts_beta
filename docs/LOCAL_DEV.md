> **Doc:** docs/LOCAL_DEV.md
> **Updated:** 2026-08-05 11:37 IST
> **Session:** Migrated from project-talk-guide/shared/02-local-dev-setup.md

# Local Development Setup

## Flutter `.env` (`D:\cts_beta\.env`)

```env
API_BASE_URL=http://<YOUR-LAN-IP>/
WEBSOCKET_URL=ws://<YOUR-LAN-IP>/ws/
DEFAULT_ADMIN_CODE=
```

- Use **LAN IP** of the PC running Docker (e.g. from `ipconfig`), not `localhost`, for physical devices.
- **No `:8000`** — Nginx exposes port **80**; Django is internal on 8000.
- Android emulator: use `10.0.2.2` instead of LAN IP.
- Android cleartext HTTP may need network security config for dev builds.

Load path: `AppConfig.initialize()` in `lib/appManager/app_class.dart`.

## Docker stack (`D:\cts-docker`)

Start from Docker Desktop:

```powershell
cd D:\cts-docker
docker compose up -d
```

### Running containers

| Container | Image | Ports | Role |
|-----------|-------|-------|------|
| C2S-Nginx | cts-docker-nginx | **80** → host | Reverse proxy + WS upgrade |
| C2D-Django | cts-docker-c2s | internal 8000 | Uvicorn ASGI |
| C2S-PostgresDB | cts-docker-postgres | internal 5432 | DB `c2s_dev_test` |
| C2S-redis | redis:latest | 6379 | Morning `d2d:live:…` + evening `{date}_{batch}` |

### After backend code edits

Volume mount `./django:/app/django` — Python changes apply without rebuild:

```powershell
docker restart C2S-Django
```

After `nginx.conf` changes:

```powershell
docker restart C2S-Nginx
```

### Verify

```powershell
docker ps
docker logs C2S-Django --tail 30
```

Postman WebSocket test: `ws://<LAN-IP>/ws/1/`

### Backend verification scripts

```powershell
docker exec -w /app/django C2S-Django python d2d_log/test_d2d_fixes.py
docker exec -w /app/django C2S-Django python d2d_log/test_return_batch_fixes.py
```

### Redis spot-check

```powershell
docker exec C2S-redis redis-cli KEYS 'd2d:live:*'
docker exec C2S-redis redis-cli SMEMBERS "05-08-2026_1"
```

## Backend env (`D:\cts-docker\.env`)

Copy from `.env.example`. Key vars: `SECRET_KEY`, `DB_HOST=postgres`, `DB_NAME`, `POSTGRES_*`.

## Seed data (typical dev DB)

~7 users, 2 batches, 4 commuters, 2 drivers, 3 d2d logs (from `postgres/dumps20.sql`).

## Troubleshooting

| Symptom | Check |
|---------|-------|
| Connection refused from phone | Same Wi‑Fi, firewall, correct LAN IP in `.env` |
| WebSocket fails | Nginx upgrade headers; see `D:\cts-docker\WEBSOCKET_FIXES.md` |
| REST 404 | Path must include `d2d/` prefix for return batch — see [API_CONTRACTS.md](./API_CONTRACTS.md) |
| Return batch empty | Commuters need `isComing=True`; batch needs driver+cab for capacity |
| Empty running batches | Driver must connect WS first to create active DTODLOG |

## Related

- [API_CONTRACTS.md](./API_CONTRACTS.md)
- [backend/01-docker-stack.md](./backend/01-docker-stack.md)
- [API_AND_ENV.md](./API_AND_ENV.md)
