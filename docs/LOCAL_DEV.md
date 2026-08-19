> **Doc:** docs/LOCAL_DEV.md
> **Updated:** 2026-08-20 01:30 IST
> **Session:** Lab QA cleanup steps (Batch-08)

# Local Development Setup

## Flutter `.env` (`D:\cts_beta\.env`)

```env
API_BASE_URL=http://<YOUR-LAN-IP>/
WEBSOCKET_URL=ws://<YOUR-LAN-IP>/ws/
DEFAULT_ADMIN_CODE=
```

- Use **LAN IP** of the PC running Docker (e.g. from `ipconfig`), not `localhost`, for physical devices.
- **No `:8000`** — Nginx exposes port **80**; Django is internal on 8000.
- **Phone + emulator together:** keep one LAN IP in `.env` (current home lab `192.168.1.6`) so both hit Docker. Do **not** switch the emulator to `10.0.2.2` in that mixed run — `10.0.2.2` is emulator-only (host loopback).
- Android emulator **alone** (no phone): `10.0.2.2` is fine if Django is on the same PC.
- Android **debug/profile** allow cleartext HTTP (`usesCleartextTraffic` on those manifests only). **Release** does not — use `https://` / `wss://` in production `.env`.
- AppConfig keeps the scheme you set (no `https→http` rewrite).

Load path: `AppConfig.initialize()` in `lib/appManager/app_class.dart`.

## Two-device lab (2026-08-15)

| Role | Device | Id |
|------|--------|----|
| Driver (or Commuter) | Xiaomi `2107113SI` | `5f36af49` |
| Admin | AVD **Pixel_10_Pro** | `emulator-5554` |

```powershell
flutter devices
flutter emulators --launch Pixel_10_Pro
# Prefer cold boot if the window is missing:
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd Pixel_10_Pro -no-snapshot-load
flutter run -d emulator-5554
flutter run -d 5f36af49
```

**Emulator in taskbar but no window:** Qt restored it off-screen (`Y ≈ -942` on this laptop). Bring it back:

1. Click the **Android Emulator** taskbar icon, then **Win + Left**.
2. Or `SetWindowPos` `qemu-system-x86_64` to `(40, 16)`. Saved in `%USERPROFILE%\.android\avd\Pixel_10_Pro.avd\emulator-user.ini`.

**Window too tall for the laptop:** Pixel 10 Pro skin at auto scale (`window.scale = -1`) was **864px** high; this PC’s work area is **1536×816** (taskbar eats the rest). Set **`window.scale = 0.25`**, `window.x = 40`, `window.y = 16` (about **340×740**). Drag a corner if you want it smaller.

Ask the user for passwords. Seed extra dummy routes/POPs/cabs/drivers/commuters via **admin CRUD** if the dump is too thin (`postgres/dumps20.sql` already has a small set). Dummy org `7069036462` is already loaded — do not add more users unless D2D needs a named rider.

**Xiaomi phone:** User must tap the **cts_beta** icon once (MIUI `am start` still drops to launcher). `adb shell input` works for LOGIN / START / swipe Confirm / STOP. Flutter **Switch** thumb on commuter home often misses — pull-to-refresh after a REST PATCH if needed.

**2026-08-17 lab:** Batch-01 morning **ended**. Return Batch-01 has 5 confirmed. Batch-08 still LIVE. Phone last role: UG4. Keep `.env` on LAN `192.168.1.6`.

### Lab QA cleanup (stale LIVE trips)

When manual QA leaves a morning trip **LIVE** (e.g. Batch-08, DTODLOG 10, WS `/ws/11/`), clear it before the next D2D test run:

1. Start `cts-docker` (`docker compose up -d`) and confirm `API_BASE_URL` resolves (e.g. `GET http://192.168.1.6/`).
2. **Driver path (preferred):** Phone login as Batch-08 driver (`9876544118`), open D2D log, tap **STOP**. Expect WS close **4001** and admin running list empty after refresh.
3. **Admin verify:** Login `7069036462`, pull-to-refresh **Running batches** — Batch-08 should not appear LIVE.
4. **Optional return cleanup:** Batch-01 return has 5 confirmed — admin may **End** return trip from return commuter list when testing end flow.
5. Do **not** wipe Parul commuter `9898927941` or re-seed dummy org `7069036462`.

If backend is down, status API returns 404 — defer cleanup until Docker is up.

org.gradle.jvmargs is now **-Xmx2G** in `android/gradle.properties`. The previous **-Xmx8G / 4G metaspace** crashed the Gradle JVM (`hs_err` Chunk::new) while Pixel_10_Pro used ~5GB on a 15GB Windows laptop. Keep 2G for mixed emulator runs.

See [TESTING.md](./TESTING.md) for the checklist.

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

Postman WebSocket test: `ws://<LAN-IP>/ws/1/` with `Cookie: sessionid=<login session>` (anonymous connect is closed **4401**).

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

## Seed data (dev DB)

Two orgs (do **not** wipe either without asking):

| Org | Admin mobile | Notes |
|-----|--------------|--------|
| Dump (Parul) | `9898927941` | Original `postgres/dumps20.sql` (~3 batches, 5 commuters) |
| Dummy QA | `7069036462` / `password` | `seed/load_cts_dummy.py` — 10 batches, 1500 commuters, 15 `isComing`/batch, cab capacity **53** |

QA logins (password `password`): Driver 1 `9876544111`, UG1 `9876556701`. Phone cold-start of a stale APK can crash; reinstall with `flutter run -d 5f36af49`.

## Troubleshooting

| Symptom | Check |
|---------|-------|
| Connection refused from phone | Same Wi‑Fi, firewall, correct LAN IP in `.env` |
| WebSocket fails | Nginx upgrade headers; session cookie on handshake; see `D:\cts-docker\WEBSOCKET_FIXES.md` |
| REST 404 | Path must include `d2d/` prefix for return batch — see [API_CONTRACTS.md](./API_CONTRACTS.md) |
| Return batch empty | Batch needs driver+cab for capacity; confirmed riders are hidden from Available |
| Empty running batches | Driver must connect WS first to create active DTODLOG |
| Gradle daemon disappeared / hs_err OOM | Lower `org.gradle.jvmargs` to `-Xmx2G` while the emulator is up |
| Xiaomi: app install OK but launcher stays | Tap `cts_beta`; enable USB debugging (Security settings) for `adb input` |
| Pixel “Try out your stylus” overlay | Dismiss Gboard handwriting sheet; it steals LOGIN / + taps |
| Emulator taskbar icon, no window | Window at `Y ≈ -942`. Win+Left, or `SetWindowPos` qemu to `(40, 16)` |
| Emulator taller than the laptop | `window.scale=0.25` in `Pixel_10_Pro.avd\emulator-user.ini` (work area 1536×816) |

## Related

- [API_CONTRACTS.md](./API_CONTRACTS.md)
- [backend/01-docker-stack.md](./backend/01-docker-stack.md)
- [API_AND_ENV.md](./API_AND_ENV.md)
