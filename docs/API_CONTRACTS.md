> **Doc:** docs/API_CONTRACTS.md
> **Updated:** 2026-08-05 11:30 IST
> **Session:** Migrated from project-talk-guide/shared/03-api-contracts.md

# API Contracts — Backend ↔ Flutter

Single reference for aligning `D:\cts-docker` endpoints with `D:\cts_beta` client code.

**Base URL:** `API_BASE_URL` in Flutter = `http://<host>/` via Nginx port 80.

**Feature owners:** [lib/features/d2d/README.md](../lib/features/d2d/README.md) · [lib/features/batches/README.md](../lib/features/batches/README.md)

---

## Authentication (REST)

| Backend | Flutter | Notes |
|---------|---------|-------|
| `POST /user/login` | `ApiUrl.loginUrl` | Session cookie |
| `POST /user/logout` | `ApiUrl.logoutUrl` | |

WebSocket has no auth (dev/debugging).

---

## Live D2D — WebSocket

| Backend | Flutter |
|---------|---------|
| `ws://<host>/ws/<batch_id>/` | `AppConfig.webSocketUrl` + `$batchId/` |

### Server → client

```json
{ "result": { "data": [...], "D2D_id": 12, "driver": { ... } } }
```

### Client → server

| ACTION | CLIST | Flutter method |
|--------|-------|----------------|
| `REMOVE` | `[user_id]` | `confirmCommuter()` |
| `DELETE` | `[user_id]` | `denyCommuter()` / `removeCommuter()` |
| `ADD` | scalar `user_id` | `addCommuter()` |
| `STOP` | — | `stopTrip()` |

### Ended trip

Server close code **4001** → `D2dChannelProvider.isTripEnded`

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
| `invalid_commuter` | Commuter missing popId or not on batch |
| `unknown_action` | Unsupported ACTION value |

Flutter should check for `error` key before reading `result`.

---

## Live D2D — REST

| Backend | Flutter | Status |
|---------|---------|--------|
| `GET /d2d/running_batches/<admin_code>` | `dtotLogUrl` | ✅ Wired |
| `GET /d2d/get_d2d_log_status/<batch_id>` | (no constant) | Backend ✅; Flutter optional |

Response shape:

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

| Backend | Flutter `ApiUrl` | Status |
|---------|------------------|--------|
| `GET /d2d/return_batch/status/<batch_id>` | `returnBatchStatus` | ✅ Batch picker |
| `GET /d2d/return_batch/view/<batch_id>` | `returnBatchView` | ✅ Available tab |
| `GET /d2d/return_batch/get_commuter/<batch_id>` | `returnBatchGetCommuter` | ✅ Confirmed tab |
| `POST /d2d/return_batch/add_commuter` | `returnBatchAddCommuter` | ✅ Confirm |
| `POST /d2d/return_batch/remove_commuter` | `returnBatchRemoveCommuter` | ✅ Remove |
| `POST /d2d/return_batch/end/<batch_id>` | `returnBatchEnd` | ✅ End FAB |

### POST body (add / remove)

```json
{ "batch_id": "1", "commuter_id": "4" }
```

`commuter_id` = **user ID** (`CommuterModel.userId.id`).

### `view/` response

```json
{ "status": "ok", "commuters": [{ "userId": { "id": 4 }, "popId": {...} }] }
```

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
