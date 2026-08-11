> **Doc:** docs/backend/03-d2d-websocket-lifecycle.md
> **Updated:** 2026-08-05 11:37 IST
> **Session:** Migrated from project-talk-guide/backend/03-d2d-websocket-lifecycle.md

# Backend — Live D2D WebSocket Lifecycle

**Most critical backend feature.** Real-time shared queue for morning outbound trips.

**Status:** ✅ Fixes 1 & 2 applied (Aug 2026).

## Endpoint

- URL: `ws://<host>/ws/<batch_id>/` or `/ws/<batch_id>`
- Routing: `d2d_log/routing.py` → `consumers.d2d`
- ASGI: `c2s/asgi.py` → `AuthMiddlewareStack` → `routing.websocket_urlpatterns`

## Connect flow (`consumers.py` → `connect`)

1. `await self.accept()` — no auth check today
2. Parse `batch_id` from URL
3. Channel group: `{YYYY-MM-DD}batch{batch_id}` (uses `timezone.localdate()` via `get_trip_date()`)
4. `group_add` to channel layer
5. `get_batch_Data(batch)` — load Batch
6. `create_d2d_Data(batch, trip_date)` — **`get_or_create(batchId, tripDate)`**
7. **Ended-trip guard (Fix 1):** if log exists and `not isActive` or `endTime` set → close **4001**, return
8. Load or build **DS** from Redis (`live_state.get_live_state`):
   - If Redis miss → rebuild from DB (commuters `isComing=True`, exclude CList) → write Redis
   - Attach `D2D_id`, optional `driver`
9. Send `{"result": DS}` to connecting client

## Actions (`receive`)

Client sends JSON: `{"ACTION": "...", "CLIST": ...}`

DS loaded/saved via **Redis** on each action (Fix 2).

### REMOVE (driver confirm pickup)

- Append user IDs to `DTODLOG.CList`, remove from DS.data, save Redis, broadcast

### ADD (admin add to live list)

- CLIST is **scalar** user ID; append to DS if not in CList/data
- Capacity check: rejects with `{"error":"capacity_full"}` if cab full

### DELETE (remove from live list only)

- Remove from DS.data only; does not update CList

### STOP (end trip)

- `isActive=False`, `endTime=now()`, CList **and queue** commuters `isComing=False`
- Clear DS, broadcast, **`delete_live_state()`**, disconnect

## Disconnect

- `group_discard` only — DS remains in Redis for other clients
- Trip continues if driver closes app without STOP

## Admin discovery (REST)

`GET /d2d/running_batches/<admin_code>` — active DTODLOG for today.

## Reconnect / restart behavior (current)

| Scenario | Behavior |
|----------|----------|
| Django restart mid-trip | Redis DS restored on reconnect (Fix 2) |
| Reconnect after STOP same day | **Rejected** close 4001 (Fix 1) |
| Admin joins mid-trip | Reads same Redis DS |

## Known remaining issues

- No WebSocket auth (deferred)
- InMemoryChannelLayer for broadcast only (OK for single worker)
- See [05-audit-and-gaps.md](./05-audit-and-gaps.md) for full backlog

## Flutter mapping

See [../../lib/features/d2d/README.md](../../lib/features/d2d/README.md). Ended-trip UI: close code **4001** in `D2dChannelProvider`.

## Related

- [02-data-model.md](./02-data-model.md)
- [06-planned-fixes.md](./06-planned-fixes.md)
- [../../lib/features/d2d/README.md](../../lib/features/d2d/README.md)
