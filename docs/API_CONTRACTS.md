> **Doc:** docs/API_CONTRACTS.md
> **Updated:** 2026-08-14 22:00 IST
> **Session:** Return ADD any batch; driver confirm/remove

# API Contracts — Backend ↔ Flutter

Single reference for aligning `D:\cts-docker` endpoints with `D:\cts_beta` client code.

**Base URL:** `API_BASE_URL` in Flutter = `http://<host>/` via Nginx port 80.

**Feature owners:** [lib/features/d2d/README.md](../lib/features/d2d/README.md) · [lib/features/batches/README.md](../lib/features/batches/README.md)

---

## Authentication (REST)

| Backend | Flutter | Notes |
|---------|---------|-------|
| `POST /user/login` | `ApiUrl.loginUrl` | Session cookie stored in FlutterSecureStorage |
| `POST /user/logout` | `ApiUrl.logoutUrl` | Client always clears cookies + prefs, even if POST fails |
| HTTP 401 (not login) | Dio interceptor | Clears local session; go_router returns to `/signIn` |

Public `/signUp` is disabled on the Flutter client (redirects to sign-in). **Backend `POST /user/` still trusts client `userType`.**

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
{ "result": { "data": [...], "D2D_id": 12, "driver": { ... } } }
```

### Client → server

| ACTION | CLIST | Flutter method |
|--------|-------|----------------|
| `REMOVE` | `[user_id]` | `confirmCommuter()` |
| `DELETE` | `[user_id]` | `denyCommuter()` / `removeCommuter()` |
| `ADD` | scalar `user_id` | `addCommuter()` — lookup by user ID (this batch first, then any). Needs a POP. Flutter success toast only after the rider is on the live list |
| `STOP` | — | `stopTrip()` — **driver only**. Admin Close channel / back is disconnect, not STOP |

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
| `forbidden` | Authenticated user not allowed to mutate this trip |

Flutter should check for `error` key before reading `result`.

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

## Return batch — REST

Evening trip — **REST only** (no WebSocket). All six endpoints below are used by the Flutter app through `ReturnBatchRepositoryImpl` → `ReturnBatchProvider`.

Constants: `lib/api/api_list.dart`. Feature owner: [lib/features/batches/README.md](../lib/features/batches/README.md).

| Backend | Purpose | Flutter `ApiUrl` / method | UI |
|---------|---------|---------------------------|----|
| `GET /d2d/return_batch/view/<batch_id>` | Available pool (org commuters not confirmed today) | `returnBatchView` · `getAvailableCommuters` | Available tab |
| `GET /d2d/return_batch/status/<batch_id>` | Counts, capacity, confirmed ids, `is_active` | `returnBatchStatus` · `getReturnBatchStatus` | Batch picker cards |
| `GET /d2d/return_batch/get_commuter/<batch_id>` | Confirmed ids + profiles (any assigned batch) | `returnBatchGetCommuter` · `getConfirmedCommuters` | Confirmed tab + capacity banner |
| `POST /d2d/return_batch/add_commuter` | Confirm seat | `returnBatchAddCommuter` · `addCommuterToConfirmList` | Admin + driver swipe Confirm |
| `POST /d2d/return_batch/remove_commuter` | Remove seat | `returnBatchRemoveCommuter` · `removeCommuterFromConfirmList` | Admin + driver swipe Remove |
| `POST /d2d/return_batch/end/<batch_id>` | Clear Redis set, restore `isComing` | `returnBatchEnd` · `endReturnTrip` | Admin End FAB |

### Client notes (verified in app)

- **`get_commuter`:** backend default is `?hydrate=1` (profiles in `commuters`). Flutter does **not** send a hydrate query; it parses `commuters`. `?hydrate=0` (IDs only) is unused.
- **`end`:** backend accepts GET or POST. Flutter uses **POST only** (`postApi({}, …end/$batchId)`).
- **`commuter_id`** in add/remove = **user ID** (`CommuterModel.userId.id`), not the commuter-row PK. Lookup is by user ID (any morning batch in the same org).
- Driver screen `/driverReturnCommuter/:batchId` reuses `loadReturnTrip` — confirm/remove enabled; End FAB stays admin-only (`canEndTrip: false`).
- Available excludes anyone already in a return Redis set today. Flutter also drops confirmed IDs from the Available tab.

### POST body (add / remove)

```json
{ "batch_id": "1", "commuter_id": "4" }
```

`commuter_id` = **user ID** (`CommuterModel.userId.id`).

### `view/` response

```json
{ "status": "ok", "commuters": [{ "userId": { "id": 4 }, "popId": {...} }] }
```

Not filtered by morning `batchId` or `isComing`. Same org as the return batch. Omits user IDs confirmed on **any** return trip today.

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
- [backend/02-data-model.md](./backend/02-data-model.md)
- `lib/api/api_list.dart`
