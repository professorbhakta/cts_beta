> **Doc:** docs/backend/04-return-batch-lifecycle.md
> **Updated:** 2026-08-20 22:15 IST
> **Session:** Verified unchanged

# Backend — Return Batch Lifecycle (Redis + REST)

Evening return trip management — **separate from live D2D WebSocket**.

**Status:** ✅ Implemented Aug 2026 (R1–R6). Summary: [../../PROJECT_BRAIN.md](../../PROJECT_BRAIN.md#6-status-snapshot).

## Overview

| | Live D2D | Return Batch |
|--|----------|--------------|
| Transport | WebSocket | REST |
| State | Redis `d2d:live:…` + DTODLOG.CList | Redis set `{date}_{batch}` |
| Real-time | Yes | Pull-to-refresh |
| Capacity | Not enforced on WS | Enforced on add |
| Driver UI | Yes | Confirm/remove/end (`/driverReturnCommuter/:batchId`) |
| ID in Redis | N/A (DS uses user IDs in JSON) | **User ID** strings |

## Redis key

```
{dd-mm-yyyy}_{batch_id}
```

Example: `05-08-2026_1`

Implementation: `d2d_log/return_batch_utils.py` — `get_set_name()`, `timezone.localdate()`.

**Not the same key as morning** `d2d:live:2026-08-05:1` — see [02-data-model.md](./02-data-model.md).

## REST endpoints

Base: `/d2d/return_batch/...`  
Handlers: `d2d_log/return_batch_views.py`

### GET `status/<batch_id>` — Batch summary ✅

One call for admin batch cards:

```json
{
  "status": "ok",
  "batch_id": "1",
  "trip_date": "05-08-2026",
  "is_active": true,
  "available_count": 12,
  "confirmed_count": 3,
  "confirmed_user_ids": ["4", "7"],
  "total_capacity": 40,
  "remaining_capacity": 37,
  "home_hold": 25,
  "overflow_confirmed": 0,
  "overflow_remaining": 28
}
```

`remaining_capacity` is still empty cab seats (`capacity - confirmed`). `available_count` is the current org `isComing=True` pool minus riders already confirmed today. Pool extras (`home_hold`, `overflow_confirmed`, `overflow_remaining`) are additive; omitted when the adapter fail-closes. Flutter picker/banner show those three only when all are present (`hasPoolExtras`). `get_commuter/` does not include extras.

### GET `view/<batch_id>` — Available pool ✅

Two lists, not the old flat org dump. `home[]` = current `isComing=True` riders whose home batch is this departure. `overflow[]` = current `isComing=True` riders from other batches in the same org. Confirmed today are omitted.

```json
{
  "status": "ok",
  "batch_id": "4",
  "home": [{ "userId": { "id": 21 }, "popId": { ... }, "batchId": { "id": 4, "batchName": "Batch-01" } }],
  "overflow": [{ "userId": { "id": 780 }, "popId": { ... }, "batchId": { "id": 13, "batchName": "Batch-10" } }],
  "home_count": 1,
  "overflow_count": 1
}
```

There is no `commuters` key. `available_count` stays on **status/** and now reflects the live `isComing=True` pool.

### GET `get_commuter/<batch_id>` — Confirmed + capacity ✅

```json
{
  "status": "ok",
  "commuter_list": ["4", "7"],
  "commuters": [{ "userId": {...}, "popId": {...} }],
  "total_capacity": 40,
  "remaining_capacity": 38,
  "confirmed_count": 2
}
```

`?hydrate=1` is the **backend default** (profiles in `commuters`). Hydrate looks up by **user ID** and preserves Redis order so names match IDs. `?hydrate=0` — IDs only. Flutter does not pass a query string; it relies on the default and parses `commuters`.

### POST `add_commuter` ✅

Body: `{ "batch_id": "1", "commuter_id": "4" }` — **`commuter_id` = user ID** (any morning batch, same org)

- Rejects if already confirmed on another return trip today
- Capacity check, Redis SADD, `isComing=False`
- Returns structured JSON `{ "status": "added", ... }` or `409 capacity_full`

### POST `remove_commuter` ✅

- Redis SREM + **`isComing=True`** (restore available pool)

### GET or POST `end/<batch_id>` ✅

- Deletes Redis key; restores `isComing=True` for all confirmed commuters
- `{ "status": "ended", "restored_count": 3, ... }`
- Flutter calls **POST only** (empty body). GET is accepted by the backend but unused by the app.

## Relationship to morning D2D

- Morning STOP sets `isComing=False` for picked-up CList + queue — that does **not** empty the evening available pool
- Return `view/` is `home[]` then `overflow[]` from the current `isComing=True` pool. Not the org dump.
- Confirm still sets `isComing=False`; remove/end restore `isComing=True` (commuter home switch)

## Flutter status

✅ All six REST endpoints wired — [../API_CONTRACTS.md](../API_CONTRACTS.md) · [../../lib/features/batches/README.md](../../lib/features/batches/README.md)

Admin: picker + Available/Confirmed monitor + add from Available. Driver: same view/get_commuter/add/remove/end.

## Verify

```bash
docker exec -w /app/django C2S-Django python d2d_log/test_return_batch_fixes.py
```

## Implementation notes (R1–R6)

| Fix | Files |
|-----|-------|
| User ID in Redis + isComing lookup | `return_batch_utils.py` |
| Structured JSON responses | `return_batch_views.py` |
| Redis `redis_connection()` cleanup | `return_batch_utils.py` |
| Remove restores `isComing=True` | `remove_commuter_from_return()` |
| `GET status/{id}`, POST end | `urls.py`, views |
| Test script | `d2d_log/test_return_batch_fixes.py` |

**Decisions:** user ID everywhere; `timezone.localdate()` for key date; admin toggles `isComing` for this trip only.

## Manual test checklist

- [x] GET status / view / get_commuter
- [x] POST add (user ID) / remove / end
- [x] capacity_full, remove restores pool

## Related

- [../features/RETURN_BATCH_E2E.md](../features/RETURN_BATCH_E2E.md)
- [../API_CONTRACTS.md](../API_CONTRACTS.md)
- [../../lib/features/batches/README.md](../../lib/features/batches/README.md)
