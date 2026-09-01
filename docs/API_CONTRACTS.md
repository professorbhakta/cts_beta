> **Doc:** docs/API_CONTRACTS.md
> **Updated:** 2026-09-01 10:20 IST
> **Session:** Doc sync — view/ waiting[] example; headers aligned to Phase 3

# API Contracts — Backend ↔ Flutter

Single reference for aligning `D:\cts-docker` endpoints with `D:\cts_beta` client code.

**Base URL:** `API_BASE_URL` in Flutter = `http://<host>/` via Nginx port 80. Stack/LAN: [LOCAL_DEV.md](./LOCAL_DEV.md).

**Feature owners:** [lib/features/d2d/README.md](../lib/features/d2d/README.md) · [lib/features/batches/README.md](../lib/features/batches/README.md)

### Client truth contract (P1)

Flutter normalizes JSON bodies through `lib/api/api_response_contract.dart` before mapping to `ApiResult`:

| Rule | Behavior |
|------|----------|
| HTTP 200 + `status: error` (or `fail` / `failed`) | **Failure** — never `ApiResult.success` |
| Known success `status` | `ok`, `success`, `added`, `removed`, `ended`, `already_confirmed` |
| Unknown / new `status` | Fail closed → failure with safe fallback message |
| Message fields (first match) | `message`, `msg`, `detail`, then string `error` / `code` |
| Status aliases | `status`, `result`, `state` |
| UI toasts / SnackBars | Provider/screen only — repositories return `ApiResult`, no side effects |

HTTP 4xx/5xx still flow through `ApiExceptionHandler` (Dio `badResponse`), which reuses the same message extraction.

---

## Authentication (REST)

| Backend | Flutter | Notes |
|---------|---------|-------|
| `POST /user/login` | `ApiUrl.loginUrl` | Session cookie stored in FlutterSecureStorage |
| `POST /user/logout` | `ApiUrl.logoutUrl` | Client always clears cookies + prefs, even if POST fails |
| HTTP 401 (not login) | Dio interceptor + `createSessionInvalidatedHandler` | Clears local session; snackbar; go_router → `/signIn` |

Public `/signUp` is disabled on the Flutter client (redirects to sign-in). **Backend `POST /user/` (P2):** unauthenticated callers may only create `COMMUTER`; `DRIVER`/`ADMIN` require authenticated admin session. `PATCH /user/<pk>` `userType` changes are admin-only.

On startup/splash, Flutter calls `GET /user/<userId>` via `refreshSessionFromServer()` to reconcile cached role with server.

D2D WebSocket requires a Django session cookie. Role is checked **once on connect** (anonymous **4401**, wrong role **4403**). Actions on an accepted socket are not re-authorized per message.

---

## Admin commuter CRUD (REST)

Admin create/update goes through `CommuterForm` → `CommuterController` → `CommuterRepositoryImpl`. Django `PATCH /user/<pk>` is **partial**.

| Backend | Flutter | Notes |
|---------|---------|-------|
| `GET /user/admin/commuter/<adminCode>` | `getCommuters` | `customCommuterSerializer` — nested user has **no** email/address |
| `GET /user/<pk>` | `getUser` | Full `userSerializer` (email, address). Loaded on **edit** so the form can prefill |
| `POST /user/` | `createCommuter` | Body `user` + `user_data`; `userType: COMMUTER` from the admin form |
| `PATCH /user/<pk>` | `updateCommuter` user map | Username, mobile, email, address, `userType` |
| `PATCH /user/commuter/<pk>` | `updateCommuter` commuter map | college, pop, batch, cab, adminCode |
| `PATCH /user/commuter/<pk>` | `updateCommuterIsComing` | Body `{isComing}`. **pk = user ID**. Success `{status: ok, isComing}`. Admin Coming switch on `CommuterScreen` and nested `CommuterListScreen` |
| `PATCH /user/admin/commuter/<adminCode>/isComing` | `markAllComing` | Body must be `{isComing: true}`. **ADMIN** only; path `adminCode` must match session admin. Sets all org commuters `isComing=true`. Success `{status: ok, isComing: true, updated: N}`. AppBar “Mark all coming” on `CommuterScreen` |

**Email / address (Flutter, 2026-08-14):**

- Email is required on the form. Never send `mail@email.com`.
- `User.address` is max **100** chars. Address on the form is optional.
- **Create:** empty address → send the email value (truncated to 100).
- **Update:** send the typed address; if empty, send the last saved address from `GET /user/<pk>`; if that was blank or the old placeholder `"address"`, send email. If the user fetch fails, **omit** address so PATCH keeps the DB value.
- Prefill skips placeholders `mail@email.com` and `"address"`.

---

## Live D2D — WebSocket

| Backend | Flutter |
|---------|---------|
| `ws://<host>/ws/<batch_id>/` or `wss://…` | `AppConfig.webSocketUrl` + `$batchId/` with `Cookie: sessionid=…` |

Handshake: `ADMIN` may join any batch; `DRIVER` only if assigned to that batch. Commuters and anonymous clients are rejected.

### Server → client

### Server → client

```json
{ "result": { "data": [...], "already_in": [...], "D2D_id": 12, "driver": { ... } } }
```

- **`data`** — live fly queue.
- **`already_in`** — CList riders confirmed in the cab (same entry shape as `data`).
- **`waiting`** — FCFS waiting pool (Phase 2); `POST boarding_scan` with `action: join_waiting`; auto-boarded to CList when a seat opens.

### Client → server

| ACTION | CLIST | Flutter method |
|--------|-------|----------------|
| `REMOVE` | `[user_id]` | `confirmCommuter()` |
| `DELETE` | `[user_id]` | `denyCommuter()` / `removeCommuter()` |
| `ADD` | scalar `user_id` | `addCommuter()` — lookup by user ID (this batch first, then any). Needs a POP. Flutter success toast only after the rider is on the live list |
| `STOP` | — | `stopTrip()` — **driver only**. Clears org home-batch `isComing`, cross-batch participants (queue/CList/waiting), flushes Redis live + waiting pools, broadcasts `{ result: { isActive: false, data: [] } }`, then closes **4001**. Admin Close channel / back is disconnect, not STOP |

### Ended trip / auth close

| Close code | Meaning | Flutter |
|------------|---------|---------|
| **4001** | Trip already ended | `isTripEnded` |
| **4401** | Unauthenticated | error state, not an empty list |
| **4403** | Authenticated but not ADMIN / assigned DRIVER | error state |

### Error responses (server → client)

When an action fails, server sends JSON (not `result`):

```json
{ "error": "capacity_full", "message": "Cab is at capacity for this trip." }
```

| `error` code | When |
|--------------|------|
| `invalid_json` | Malformed request body |
| `missing_action` | No `ACTION` field |
| `no_live_state` | Redis live queue missing (trip ended or not started) |
| `capacity_full` | WS ADD would exceed cab capacity |
| `no_driver` / `no_cab` | Batch has no driver/cab assigned |
| `invalid_commuter` | Commuter missing popId or user not found |
| `unknown_action` | Unsupported ACTION value |
| `forbidden` | Authenticated user not allowed to mutate this trip (wrong role for ACTION) |

Flutter should check for `error` key before reading `result`. `invalid_commuter` / `capacity_full` do **not** close the socket.

### Reconnect / restart

| Scenario | Behavior |
|----------|----------|
| Django restart mid-trip | Redis DS restored on reconnect |
| Reconnect after STOP same day | Close **4001** |
| Admin joins mid-trip | Same Redis DS |
| Leave screen / dispose | Disconnect only — trip stays active until STOP |

---

## Redis — two key namespaces (one Redis)

Same `C2S-redis` container; keys do not overwrite each other.

| | Morning live D2D | Evening return |
|--|------------------|----------------|
| Key | `d2d:live:{YYYY-MM-DD}:{batch_id}` | `{dd-mm-yyyy}_{batch_id}` |
| Value | JSON DS blob | Set of user ID strings |
| Cleared by | WS `STOP` | `POST/GET end/{batch_id}` |
| Module | `d2d_log/live_state.py` | `d2d_log/return_batch_utils.py` + `return_waiting_pool.py` |

Morning STOP does not empty the evening confirmed set; ending return does not touch morning live DS.

---

## Live D2D — REST

| Backend | Flutter | Status |
|---------|---------|--------|
| `GET /d2d/running_batches/<admin_code>` | `dtotLogUrl` | ✅ Admin running list |
| `GET /d2d/get_d2d_log_status/<batch_id>` | `d2dLogStatus` | ✅ Driver log pre-connect via `D2dRepository` |

Response shape (`get_d2d_log_status`):

```json
{
  "id": 4,
  "batch_id": 1,
  "trip_date": "2026-08-05",
  "is_active": false,
  "status": "ended"
}
```

---

## Client pack — odometer + QR boarding (2026-08-24)

Backend: `cts-docker/django/d2d_log/` (`odometer_views.py`, `boarding_views.py`, `board_commuter` shared with WS REMOVE).  
Flutter: `D2dRepository` + `ApiUrl` + UI (`odometer_km_sheet`, `boarding_qr_panel`, `boarding_scan_screen`) — **STEPS 1–7 shipped**; STEP 8 smoke pending.  
Schema: nullable KM/photo columns on **`DTODLOG`**. Media on disk; photo URLs = auth download.

| Backend | Auth | Flutter |
|---------|------|---------|
| `POST /d2d/odometer/start/` | DRIVER / ADMIN | `submitOdometerStart` — multipart `batch_id`, `leg`, `km`, optional `photo` |
| `POST /d2d/odometer/end/` | DRIVER / ADMIN | `submitOdometerEnd` |
| `GET /d2d/odometer/<batch_id>/?date=` | DRIVER / ADMIN | `getOdometer` |
| `GET /d2d/odometer/org/<admin_code>/?date=` | ADMIN | `getOdometerOrg` |
| `GET /d2d/odometer/photo/…` | DRIVER / ADMIN | URL on snapshot (session cookie) |
| `GET /d2d/boarding_qr/<batch_id>/` | DRIVER / ADMIN | `getBoardingQr` |
| `POST /d2d/boarding_scan/` | COMMUTER | `boardingScan` — body `{token, action?}` · `action`: **`board`** (default) or **`join_waiting`** |
| `POST /d2d/boarding_unboard/` | DRIVER / ADMIN | `boardingUnboard` |

Error body: `{ "status": "error", "code": "<code>", "message": "…" }`.  
Flutter maps `code` via `ClientPackErrorMessages` → SnackBar text; `ApiFailure.code` for branching (`shouldRefreshQr`, `needsActiveTrip`, `isAuthFailure`).

| Code | Typical cause |
|------|----------------|
| `unauthorized` / `forbidden` | Session / role |
| `km_required` / `invalid_km` | Missing or bad KM |
| `already_started` / `already_ended` | Duplicate submit |
| `start_required` / `km_below_start` / `km_below_morning_end` | Leg order / validation |
| `expired_token` / `invalid_token` | Refresh QR |
| `trip_not_active` / `no_live_state` | Need live WS trip |
| `not_coming` / `not_in_queue` / `wrong_batch` | Commuter eligibility — scan requires **in live queue**; cross-batch guests admin ADDed to queue may scan (`require_home_batch=false`). Join waiting list is Phase 2 (separate action) |
| `capacity_full` | Cab full |
| `not_boarded` | Unboard target not in CList |

Shared `board_commuter()` for WS `REMOVE` and `boarding_scan`. WS ACTION names unchanged.

---

## Return batch — REST

Evening trip — **REST only** (no WebSocket). Endpoints below are used by the Flutter app through `ReturnBatchRepositoryImpl` → `ReturnBatchProvider` (admin/driver) and `CommuterHomeProvider` (intent).

Constants: `lib/api/api_list.dart`. Feature owner: [lib/features/batches/README.md](../lib/features/batches/README.md).

| Backend | Purpose | Flutter `ApiUrl` / method | UI |
|---------|---------|---------------------------|----|
| `GET /d2d/return_batch/view/<batch_id>` | Available `home[]`, `overflow[]`, **`waiting[]`** (FCFS pool) | `returnBatchView` · `getAvailableCommuters` | Available tab + **Waiting line** banner |
| `GET /d2d/return_batch/status/<batch_id>` | Counts, capacity, confirmed ids, `is_active`; optional pool extras | `returnBatchStatus` · `getReturnBatchStatus` | Batch picker cards |
| `GET /d2d/return_batch/get_commuter/<batch_id>` | Confirmed ids + profiles (any assigned batch) | `returnBatchGetCommuter` · `getConfirmedCommuters` | Confirmed tab + capacity banner |
| `POST /d2d/return_batch/add_commuter` | Confirm seat (default) **or** `action: join_waiting` (commuter self-serve FCFS line) | `returnBatchAddCommuter` · `addCommuterToConfirmList` / `joinReturnWaiting` | Admin + driver Confirm · commuter home **Join waiting line** |
| `POST /d2d/return_batch/remove_commuter` | Remove seat; FCFS promotes waiting head when capacity opens | `returnBatchRemoveCommuter` · `removeCommuterFromConfirmList` | Admin + driver swipe Remove |
| `POST /d2d/return_batch/end/<batch_id>` | Clear Redis confirmed + **return waiting**; `isComing=false` for home batch + cross-batch confirmed/waiting | `returnBatchEnd` · `endReturnTrip` | Driver End FAB |
| `GET /d2d/return_batch/intent` | Current user’s return intent for today | `returnBatchIntent` · `getReturnIntent` | Commuter home — Return today |
| `POST /d2d/return_batch/intent` | Set intent `skip` \| `home` \| `earlier` (+ `target_batch_id`) | `returnBatchIntent` · `setReturnIntent` | Commuter home chips |
| `GET /d2d/return_batch/intent_options` | Org batches with strictly earlier `end_time` than home | `returnBatchIntentOptions` · `getReturnIntentOptions` | Earlier… picker |

### Return intent (26d)

- **COMMUTER only**; self user id from session. Requires morning `isComing=true`. Preference only — seat confirm stays admin/driver `add_commuter`.
- Redis HASH `d2d:return_intent:{dd-mm-yyyy}` field=`user_id`, value=`home` \| `skip` \| `earlier:{batch_id}`. Missing → **home**.
- `earlier` requires `target_batch_id` with strictly earlier return time than home. Rejects if already confirmed on a return today.
- Pool: **skip** drops home hold; **earlier(D)** is overflow candidate for D. Cutoff / no-show release is **not** in this slice.

### Client notes (verified in app)

- **`get_commuter`:** backend default is `?hydrate=1` (profiles in `commuters`). Flutter does **not** send a hydrate query; it parses `commuters`. `?hydrate=0` (IDs only) is unused.
- **`end`:** backend accepts GET or POST. Flutter uses **POST only** (`postApi({}, …end/$batchId)`).
- **`commuter_id`** in add/remove = **user ID** (`CommuterModel.userId.id`), not the commuter-row PK. Lookup is by user ID (any morning batch in the same org).
- Admin return screen can add from Available and view Confirmed. Driver return screen can confirm/remove/end.
- Available is `home[]` then `overflow[]` from GET view, built from current org commuters with `isComing=true` and split by home batch. Flutter drops anyone already on today's confirmed set. Old flat `commuters` is ignored.
- **`status/` extras (M3, additive):** `home_hold`, `overflow_confirmed`, `overflow_remaining` may appear. Flutter `ReturnBatchStatusModel` parses them only when **all three** keys are present (`hasPoolExtras`). Fail closed (keys omitted) → extras stay null; picker/banner hide those rows. **Seats left** is still `remaining_capacity` (empty cab seats), never `overflow_remaining`. `available_count` is still org-pool size. `get_commuter/` does not include extras.
- **R7 cutoff (T−15):** when **college-local** now ≥ `Batch.end_time − 15m` (Django `TIME_ZONE`, default **Asia/Kolkata**), unconfirmed home holds stop counting toward `home_hold`. Status may also include `cutoff_applied: true` (optional; Flutter shows “Holds released”). Soft leftover seats (R5) were already open before cutoff. After a departure’s T−15 it stays cut off until `trip_date` rolls.
- Overflow Confirm is disabled when `hasPoolExtras` and `overflow_remaining == 0`. That is not Seats left.

### POST body (add / remove)

```json
{ "batch_id": "1", "commuter_id": "4", "action": "confirm" }
```

`action` optional: **`confirm`** (default, admin/driver) or **`join_waiting`** (COMMUTER only, self `commuter_id`). Join waiting is a **separate explicit action** — not a silent fallback on failed confirm. FCFS auto-confirms waiting head to Redis confirmed set when a seat opens (after remove or on join when capacity allows).

Redis return waiting key: `d2d:return_waiting:{YYYY-MM-DD}:{batch_id}` — flushed on **End return** (same trip-end `isComing` scope as morning STOP).

`commuter_id` = **user ID** (`CommuterModel.userId.id`).

### `status/` response

```json
{
  "status": "ok",
  "batch_id": "1",
  "trip_date": "19-08-2026",
  "is_active": true,
  "available_count": 12,
  "confirmed_count": 3,
  "confirmed_user_ids": ["4", "7"],
  "total_capacity": 40,
  "remaining_capacity": 37,
  "home_hold": 25,
  "overflow_confirmed": 0,
  "overflow_remaining": 28,
  "cutoff_applied": true
}
```

`home_hold` / `overflow_confirmed` / `overflow_remaining` are optional. Omitted when the adapter fail-closes (`extras == {}`). `cutoff_applied` is optional (R7; only when that departure is past T−15). `get_commuter/` does **not** include these keys.

### `view/` response

```json
{
  "status": "ok",
  "batch_id": "4",
  "home": [{ "userId": { "id": 21 }, "popId": {...}, "batchId": {...} }],
  "overflow": [{ "userId": { "id": 780 }, "popId": {...}, "batchId": {...} }],
  "waiting": [{ "userId": { "id": 42 }, "popId": {...}, "batchId": {...} }],
  "home_count": 1,
  "overflow_count": 1,
  "waiting_count": 1
}
```

`home[]` = current `isComing=true` commuters whose home batch is this departure. `overflow[]` = current `isComing=true` commuters from other batches in the same org. `waiting[]` = FCFS pool (commuter `join_waiting`; auto-promoted to confirmed when a seat opens). No flat `commuters` key.

### `get_commuter/` response

```json
{
  "commuter_list": ["4"],
  "commuters": [{ "userId": {...}, "popId": {...} }],
  "total_capacity": 40,
  "remaining_capacity": 38
}
```

---

## ID conventions

| Context | ID type |
|---------|---------|
| D2D WebSocket CLIST / CList | **User ID** |
| Return batch Redis + POST body | **User ID** |
| Flutter | Always use `userId.id` |

---

## Related

- [API_AND_ENV.md](./API_AND_ENV.md) — env vars, dio setup
- [LOCAL_DEV.md](./LOCAL_DEV.md) — Docker / Nginx / LAN
- [GLOSSARY.md](./GLOSSARY.md) — Redis keys, channel group names
- `lib/api/api_list.dart`
