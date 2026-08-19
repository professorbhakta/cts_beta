> **Doc:** lib/features/d2d/README.md
> **Updated:** 2026-08-19 23:15 IST
> **Session:** P2 — WS 4401/4403 triggers session invalidation

# D2D Feature — Live WebSocket

Feature owner for morning door-to-door live trips. Single provider powers admin monitor and driver log screens.

**Full API spec:** [docs/API_CONTRACTS.md](../../../docs/API_CONTRACTS.md) · **E2E flow:** [docs/features/D2D_E2E.md](../../../docs/features/D2D_E2E.md)

---

## Key files

| Role | Path |
|------|------|
| Provider | `providers/d2d_channel_provider.dart` |
| Status API | `repositories/d2d_repository.dart` (+ impl) |
| Admin screen | `screens/d2d_channel.dart` |
| Driver screen | `screens/d2d_log_screen.dart` |
| Live widgets | `widgets/d2d_live_widgets.dart` |
| Action error SnackBar | `widgets/d2d_action_error_listener.dart` |
| Add commuter sheet | `widgets/d2d_add_commuter_sheet.dart` — search by name, mobile, batch, POP |

---

## Connect flow

```dart
final uri = Uri.parse('${AppConfig.instance.webSocketUrl}$batchId/');
_channel = IOWebSocketChannel.connect(uri, headers: {HttpHeaders.cookieHeader: cookie});
// Stays loading until first message or close (4001 ended, 4401/4403 auth)
```

Both screens call `provider.connect(batchId)` in `initState` and `disconnect()` on dispose.

**Disconnect ≠ STOP.** Leaving the screen (back, Close channel, `dispose`) only closes the WebSocket. The `DTODLOG` row stays `isActive=true` until the driver **STOP TRIP** FAB sends `{ACTION: STOP}`.

The DB row is created on **connect** (`get_or_create(batchId, tripDate)`), not on STOP. Reconnect the same day after a real STOP is closed **4001**.

Driver log also calls `provider.fetchTripStatus(batchId)` — REST `GET d2d/get_d2d_log_status/:batchId` via `D2dRepository` (not from the screen). Result is `D2dTripStatus` (`unknown` / `none` / `active` / `ended`).

Also loads driver via REST: `_driverRepository.getDriverByBatch(batchId)`.

---

## ViewState

`idle` → `loading` on connect → `success` on first WS message or `error` (including ended trip).

---

## WS actions (client → server)

| UI action | Provider method | WS payload |
|-----------|-----------------|------------|
| Driver swipe green | `confirmCommuter(id)` | `{ACTION: REMOVE, CLIST: [id]}` |
| Driver swipe red | `denyCommuter(id)` | `{ACTION: DELETE, CLIST: [id]}` |
| Admin swipe red | `removeCommuter(id)` | `{ACTION: DELETE, CLIST: [id]}` |
| Admin add sheet | `addCommuter(id)` | `{ACTION: ADD, CLIST: id}` — success toast only after the rider appears on the live list |
| Driver STOP FAB | `stopTrip()` | `{ACTION: STOP}` |

Always use **user ID** in CLIST.

---

## Ended trip / auth close

| Close code | Meaning | UI |
|------------|---------|-----|
| **4001** | Trip already ended | `isTripEnded`; retry hidden |
| **4401** | No session cookie | error + session invalidation → sign-in |
| **4403** | Not ADMIN / assigned DRIVER | error + session invalidation → sign-in |

Message for 4001: *"This trip has already ended. A new trip can be started tomorrow."*

Role is checked on connect only. Do not re-query the user on every ADD/DELETE/STOP.

---

## Error frames (WS action errors)

Check `error` key **before** `result`:

```json
{ "error": "capacity_full", "message": "Cab is at capacity for this trip." }
```

Provider sets `actionErrorMessage` without disconnecting. Admin + driver show SnackBar; cleared on next valid `result` frame.

| `error` code | Fallback label |
|--------------|----------------|
| `capacity_full` | Cab is at capacity |
| `no_live_state` | Trip is not active |
| `invalid_commuter` | Commuter not found or has no pick-up point |
| `no_driver` / `no_cab` | Batch missing driver or cab |
| `unknown_action` | Unsupported action |
| `forbidden` | You are not allowed to change this live trip |

Connection errors (`isTripEnded`, retry UI) are separate from action errors.

When admin is on the channel and the trip ends, the provider sets `isTripEnded` from:

1. STOP snapshot `{ "result": { "isActive": false, "data": [] } }`, or
2. WebSocket close **4001**

The admin screen then calls `RunningBatchProvider.fetchOnce()` and `AdminProvider.refreshRunningBatches()` once. Close channel / Go back also snapshot those lists so the dashboard LIVE tile is not stale. Evening return trips stay on `ReturnBatchProvider` REST and are never mixed into this path.

Driver **STOP TRIP** FAB is hidden when `isTripEnded` or REST status is `ended`.

**QA 2026-08-17:** Admin watching STOP showed ended UI (not WAITING). Close channel cleared Batch-01 LIVE tile. Driver same-day START showed 4001 / TRIP ENDED TODAY.

---

## Incoming payload

```json
{ "result": { "data": [...], "D2D_id": 12, "driver": { ... } } }
```

Parsed by `_decodePayload`, `_parseCommutersFromData`, `D2dCommuterModel.fromJson`.

---

## Manual test checklist

1. Start morning D2D — driver connects, admin opens channel.
2. **Capacity:** Fill cab; admin ADD via sheet → SnackBar with server message.
3. **Happy path:** Valid ADD (any commuter with a POP) → list updates, then success SnackBar. Missing POP → `invalid_commuter`, socket stays up.
4. **Ended trip:** Driver STOP; admin watching shows ended UI (not WAITING); dashboard LIVE tile clears without pull-to-refresh. ADD is unavailable.
5. Repeat on **driver log** (swipe green/red). STOP FAB hidden after ended / 4001.
6. Reconnect after STOP → ended-trip message (4001), not action error.
7. Leave Channel / back **without** STOP → trip stays active; reconnect joins the same live queue.
