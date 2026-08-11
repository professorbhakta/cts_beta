> **Doc:** lib/features/d2d/README.md
> **Updated:** 2026-08-05 11:37 IST
> **Session:** Merged sprint detail from talk-guide; removed legacy source link

# D2D Feature — Live WebSocket

Feature owner for morning door-to-door live trips. Single provider powers admin monitor and driver log screens.

**Full API spec:** [docs/API_CONTRACTS.md](../../../docs/API_CONTRACTS.md) · **E2E flow:** [docs/features/D2D_E2E.md](../../../docs/features/D2D_E2E.md)

---

## Key files

| Role | Path |
|------|------|
| Provider | `providers/d2d_channel_provider.dart` |
| Admin screen | `screens/d2d_channel.dart` |
| Driver screen | `screens/d2d_log_screen.dart` |
| Live widgets | `widgets/d2d_live_widgets.dart` |
| Add commuter sheet | `widgets/d2d_add_commuter_sheet.dart` |

---

## Connect flow

```dart
final uri = Uri.parse('${AppConfig.instance.webSocketUrl}$batchId/');
_channel = WebSocketChannel.connect(uri);
// Stays loading until first message or close
```

Both screens call `provider.connect(batchId)` in `initState` and `disconnect()` on dispose.

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
| Admin add sheet | `addCommuter(id)` | `{ACTION: ADD, CLIST: id}` |
| Driver STOP FAB | `stopTrip()` | `{ACTION: STOP}` |

Always use **user ID** in CLIST.

---

## Ended trip

Server close code **4001** → `D2dChannelProvider.isTripEnded == true`

Message: *"This trip has already ended. A new trip can be started tomorrow."* — retry hidden.

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
| `invalid_commuter` | Commuter not on this batch |
| `no_driver` / `no_cab` | Batch missing driver or cab |
| `unknown_action` | Unsupported action |

Connection errors (`isTripEnded`, retry UI) are separate from action errors.

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
3. **Ended trip:** Driver STOP; admin tries ADD → SnackBar (`no_live_state`).
4. **Happy path:** Valid ADD/REMOVE → list updates, no error SnackBar.
5. Repeat on **driver log** (swipe green/red).
6. Reconnect after STOP → ended-trip message (4001), not action error.
