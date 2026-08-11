> **Doc:** docs/backend/01-docker-stack.md
> **Updated:** 2026-08-05 11:37 IST
> **Session:** Migrated from project-talk-guide/backend/01-docker-stack.md

# Backend — Docker Stack

## docker-compose.yml services

| Service | Container | Build | Ports |
|---------|-----------|-------|-------|
| redis | C2S-redis | image redis:latest | 6379:6379 |
| postgres | C2S-PostgresDB | ./postgres/Dockerfile | internal 5432 |
| c2s | C2S-Django | django/Dockerfile | internal 8000 |
| nginx | C2S-Nginx | ./nginx | **80:80** |

Network: `backend` bridge. Django code bind-mount: `./django:/app/django`.

## Django startup (`django/entrypoint.sh`)

1. `python manage.py makemigrations`
2. `python manage.py migrate`
3. `python -m uvicorn c2s.asgi:application --host 0.0.0.0 --port 8000`

## Settings highlights (`c2s/settings.py`)

| Setting | Value | Note |
|---------|-------|------|
| `AUTH_USER_MODEL` | `user_servcies.User` | Login: mobileNumber |
| `ASGI_APPLICATION` | `c2s.asgi.application` | HTTP + WebSocket |
| `CHANNEL_LAYERS` | `InMemoryChannelLayer` | Not Redis-backed for Channels yet |
| `CACHES` | django-redis → `redis://redis` | Django cache |
| `DEBUG` | True | Dev only |
| `ALLOWED_HOSTS` | `["*"]` | Dev only |
| `TIME_ZONE` | UTC | Watch date.today() vs timezone |

## Nginx (`nginx/nginx.conf`)

- Upstream: `c2s:8000`
- WebSocket: `map $http_upgrade $connection_upgrade`
- Headers: Upgrade, Connection, Host, X-Forwarded-*
- `proxy_read_timeout 86400` for long WS sessions

## Root URL routing (`c2s/urls.py`)

```
/void/     → Django admin
/user/     → user_servcies
/cab/      → cab_services
/d2d/      → d2d_log REST
/ws/...    → ASGI websocket (not in urls.py — routing.py)
```

## Requirements (`django/requirements.txt`)

Django 4.2.5, djangorestframework, channels 4, uvicorn, psycopg2-binary, redis, django-redis, python-dotenv.

**Not installed:** `channels_redis` (planned for later broadcast scaling).

## Dev seed

`postgres/dumps20.sql` mounted at init → sample users, batches, commuters.

Typical counts: 7 users, 2 batches, 4 commuters, 2 drivers, 3 d2d logs.

## Restart after changes

```powershell
docker restart C2S-Django
docker restart C2S-Nginx   # if nginx.conf changed
```

## Related

- [../LOCAL_DEV.md](../LOCAL_DEV.md)
- [03-d2d-websocket-lifecycle.md](./03-d2d-websocket-lifecycle.md)
