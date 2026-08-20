> **Doc:** docs/backend/03-d2d-websocket-lifecycle.md
> **Updated:** 2026-08-14 21:55 IST
> **Session:** Doc sync — ADD user-ID lookup; Http404 no longer kills socket

# Backend — Live D2D WebSocket Lifecycle

**Most critical backend feature.** Real-time shared queue for morning outbound trips.

**Status:** ✅ Fixes 1 & 2 applied (Aug 2026). Connect-time session auth (4401/4403) added in the auth security wave.

## Endpoint

- URL: `ws://<host>/ws/<batch_id>/` or `/ws/<batch_id>`
- Routing: `d2d_log/routing.py` → `consumers.d2d`
- ASGI: `c2s/asgi.py` → `AuthMiddlewareStack` → `routing.websocket_urlpatterns`

## Connect flow (`consumers.py` → `connect`)

1. Parse `batch_id` from URL; `AuthMiddlewareStack` user on `scope`
2. **Auth (once):** anonymous → close **4401**; not ADMIN / assigned DRIVER → close **4403**. Remember `_authorized` — do not re-query on every action
3. `await self.accept()`
4. Channel group: `{YYYY-MM-DD}batch{batch_id}` (uses `timezone.localdate()` via `get_trip_date()`)
5. `group_add` to channel layer
6. `get_batch_Data(batch)` — load Batch
7. `create_d2d_Data(batch, trip_date)` — **`get_or_create(batchId, tripDate)`**
8. **Ended-trip guard (Fix 1):** if log exists and `not isActive` or `endTime` set → close **4001**, return
9. Load or build **DS** from Redis (`live_state.get_live_state`):
   - If Redis miss → rebuild from DB (commuters `isComing=True`, exclude CList) → write Redis
   - Attach `D2D_id`, optional `driver`
10. Send `{"result": DS}` to connecting client

## Actions (`receive`)

Client sends JSON: `{"ACTION": "...", "CLIST": ...}`

DS loaded/saved via **Redis** on each action (Fix 2). If the socket was never authorized, send `{"error":"forbidden"}` (in-memory flag — no extra DB lookup).

### REMOVE (driver confirm pickup)

- Append user IDs to `DTODLOG.CList`, remove from DS.data, save Redis, broadcast

### ADD (admin add to live list)

- CLIST is **scalar** user ID; append to DS if not in CList/data
- Lookup is by **user ID** (this batch first, then any batch) so the admin add sheet can add riders who are not assigned to this batch
- Missing commuter / no POP → `{"error":"invalid_commuter"}` (does **not** crash the socket)
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

- REST d2d views still open in dev (no DRF permissions)
- InMemoryChannelLayer for broadcast only (OK for single worker)
- Living backlog: [../../PROJECT_TODOS.md](../../PROJECT_TODOS.md)

## Flutter mapping

See [../../lib/features/d2d/README.md](../../lib/features/d2d/README.md). Close codes: **4001** ended trip, **4401** unauthenticated, **4403** forbidden role.

## Related

- [02-data-model.md](./02-data-model.md)
- [04-return-batch-lifecycle.md](./04-return-batch-lifecycle.md)
- [../../lib/features/d2d/README.md](../../lib/features/d2d/README.md)
