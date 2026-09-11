> **Doc:** docs/testing/LIVE_API_TEST_REPORT.md  
> **Updated:** 2026-09-11  
> **Session:** Live API + real-case probe against VPS

# Live API test report — `https://abhimaarg.tech`

Real-case REST/WS probe from Cloud Agent against the public CTS stack (same host serves Flutter web + Django via nginx).

**Repro script:** [`scripts/live_api_probe.sh`](../../scripts/live_api_probe.sh)

---

## Environment

| Item | Value |
|------|-------|
| REST base | `https://abhimaarg.tech/` |
| WebSocket | `wss://abhimaarg.tech/ws/` |
| Web app | `https://abhimaarg.tech/` (Flutter web) |
| Bundled `.env` (public asset) | `API_BASE_URL=https://abhimaarg.tech/` · `WEBSOCKET_URL=wss://abhimaarg.tech/ws/` |
| Django admin | `https://abhimaarg.tech/void/` |
| Org | Parul University · `adminCode` `081fa96e-e9e2-4b33-b46a-c50ee16150d1` |
| Batches seen | 1–5 (`vps-batch` = id 5) |

Lab LAN defaults (`172.20.10.2` / `192.168.1.6`) are **not** reachable from the cloud VM and are **not** what APK/web release builds use.

---

## Accounts used (live Parul dump)

Lab seed mobiles (`7069036462`, `9000000000`, `9876544111`, …) → **`Invalid credentials`** on live.

| Role | Mobile | Password | Notes |
|------|--------|----------|-------|
| ADMIN | `9879105576` | `password` | `dharmesh patel` · id 1 |
| DRIVER (batch 3) | `6351505091` | `password` | Pravin Bhai · cab GJ06BY7024 |
| DRIVER (batch 1/2/4) | `8347336864` / `8141912378` / `9106674255` | `password` | |
| COMMUTER | `6206361827` | `password` | batch 2 sample |
| STAFF | `9898927941` | `password` | your account · commuter-shaped profile |

**Security note:** the shared seed password works for admin, drivers, and every sampled live mobile. Treat as urgent before wider APK/web testing with real riders.

---

## Results matrix (high signal)

### Auth / session — mostly PASS

| Case | Result |
|------|--------|
| `POST /user/login` camelCase `{mobileNumber,password}` | PASS |
| Wrong password / missing fields | 401 / 400 as expected |
| `POST /user/refresh` | PASS |
| `Authorization: Bearer` on protected routes | PASS |
| `POST /user/logout` | 200 `"User Logged Out"` |
| Refresh after logout | **FAIL** — refresh token still issues new access |
| Lab seed logins on live | **FAIL** — not provisioned |

### Admin — PASS (with path caveat)

| Case | Result |
|------|--------|
| `GET /user/admin-bootstrap/` | PASS — org + batches/drivers/commuters luggage |
| `GET /user/admin/commuter/<adminCode>` | PASS (~227) |
| `GET /user/admin/driver/<adminCode>` | PASS (4 drivers) |
| `GET /cab/admin/{batch,route,cab,pickuppoint}/<adminCode>` | PASS |
| `GET /cab/admin/route/` (no code) | 404 — FE correctly appends `adminCode` |
| `PATCH …/admin/commuter/<adminCode>/isComing` | PASS `updated: 227` |
| `GET /d2d/running_batches/<adminCode>` | PASS `[]` (no morning live trips at probe time) |
| `GET /d2d/odometer/org/<adminCode>/` | PASS |

### Driver / client pack — mixed

| Case | Result |
|------|--------|
| Return QR `GET …/boarding_qr/<batch>/?trip=return` | PASS + `return_trip_id` |
| Morning QR without active D2D | `trip_not_active` (expected) |
| Odometer start/end with **integer** `km` | PASS — also created active D2D log |
| Odometer with float `km` (`100.5`) | **FAIL** `invalid_km` — must be positive integer |
| Morning QR after odometer | PASS (`d2d_id`) |
| Morning `boarding_scan` | `no_live_state` — needs WS live queue |
| Driver QR for other batch | 403 `Driver not assigned` (good) |
| `wss://…/ws/<batch>/` + Bearer | **FAIL** always close **4401** (admin + driver) |

### Return batch — functional but authz broken

| Case | Result |
|------|--------|
| view / status / get_commuter | PASS |
| Driver `add_commuter` / `remove_commuter` | PASS (201/200) |
| Commuter `intent` get/set + `intent_options` | PASS |
| Commuter `join_waiting` | PASS |
| STAFF `intent` | 403 — FE routes STAFF to commuter UX; product mismatch |
| `POST …/return_batch/end/<batch>` as COMMUTER / STAFF / wrong-batch DRIVER | **CRITICAL FAIL** — all returned `ended` |

### Security — CRITICAL failures

| Finding | Severity | Evidence |
|---------|----------|----------|
| `GET /user/<id>` **without auth** returns full user incl. **password hash** | Critical | `curl https://abhimaarg.tech/user/1` → 200 + `pbkdf2_sha256$…` |
| Return **End** has no role/assignment check | Critical | COMMUTER ended batch 2; STAFF ended batch 4; cross-batch DRIVER ended batch 3 |
| STAFF can `PATCH /user/commuter/<otherUserId>` `isComing` | High | STAFF token patched user 6 |
| Default password `password` on live Parul accounts | High | Admin + drivers + sampled riders |
| Logout does not revoke refresh JWT | Medium | refresh OK after logout |
| Public `assets/.env` exposed | Low | confirms prod URLs only (no secrets) |

---

## Side effects on live (this probe)

These mutations hit production Parul data — call out for ops:

1. Admin **Mark all coming** → `updated: 227`
2. Return trips **ended** for batches **2, 3, 4** (authz test)
3. Return QR boarded user **11** onto batch **1** return earlier in the run
4. Morning odometer written for batch **3** (100→125 km); D2D log left **active**
5. Temporary user `9000111222` / `api_test_tmp` created then **deleted**
6. Commuter 194 intent toggled skip→home; joined waiting on batch 2 (later cleared by end)

---

## Implications for APK / web testing

| Surface | Expectation |
|---------|-------------|
| JWT login (admin/driver/commuter/staff) | Should work if `.env` points at `https://abhimaarg.tech/` |
| Admin bootstrap + lists | Should populate |
| Return QR mint + scan | Should work when roles correct |
| Morning live D2D (WS fly queue / boarding from queue) | **Blocked** until WS auth (4401) is fixed on nginx/Channels |
| STAFF “commuter” return intent chips | Will 403 until BE allows STAFF or FE hides chips |
| Any client relying on float KM | Will hit `invalid_km` |

---

## Recommended BE fixes (priority)

1. **Auth-gate `GET /user/<pk>`** — never return `password`; require self-or-admin.
2. **Lock `return_batch/end`** to assigned DRIVER or ADMIN/SUPER_ADMIN for that org/batch.
3. **Lock `PATCH /user/commuter/<pk>`** — self for `isComing` only; admin for other fields.
4. **Force password reset** / disable shared `password` on live before rider testing.
5. **Fix WS JWT** — ensure nginx passes `Authorization` on Upgrade; verify Channels middleware (always 4401 today).
6. **Blacklist/rotate refresh** on logout.
7. Align STAFF with return-intent policy (allow or FE-hide).

---

## Probe command

```bash
BASE_URL=https://abhimaarg.tech ./scripts/live_api_probe.sh
```


---

## Web UI smoke (same host)

Manual Flutter web login against `https://abhimaarg.tech/` (2026-09-11):

| Step | Result |
|------|--------|
| App load (CanvasKit) | PASS |
| Sign-in screen | PASS |
| ADMIN login `9879105576` / `password` | PASS → `#/adminHomeScreen` |
| Dashboard counts (5 batches / 227 commuters / 4 drivers) | PASS |
| Logout | PASS |

Screenshots: `web-signin-screen.webp`, `web-admin-dashboard.webp` (agent artifacts).
