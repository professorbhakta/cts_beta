> **Doc:** lib/features/d2d/README.md
> **Updated:** 2026-09-01 10:20 IST
> **Session:** Phase 1+2 morning waiting pool + scan join_waiting + Waiting line UI

# D2D Feature — Live WebSocket

Feature owner for morning door-to-door live trips (Flutter UI + consumer notes). Single provider powers admin monitor and driver log screens.

**Wire:** [docs/API_CONTRACTS.md](../../../docs/API_CONTRACTS.md) · **Lab:** [docs/LOCAL_DEV.md](../../../docs/LOCAL_DEV.md) · **E2E:** [docs/features/D2D_E2E.md](../../../docs/features/D2D_E2E.md) · **BE↔FE dots:** [PROJECT_BRAIN §10](../../../PROJECT_BRAIN.md#10-deep-docs--stable-befe-map)

**Backend path:** `cts-docker/django/d2d_log/` — `consumers.py`, `live_state.py`, `odometer_views.py`, `boarding_views.py`, `board_commuter`. Channel group: `{YYYY-MM-DD}batch{batch_id}`.

---

## Key files

| Role | Path |
|------|------|
| Role policy | `models/d2d_channel_role_policy.dart` |
| Provider | `providers/d2d_channel_provider.dart` |
| Status + client pack API | `repositories/d2d_repository.dart` (+ impl) |
| Odometer / boarding models | `models/odometer_models.dart`, `models/boarding_models.dart` |
| Error copy | `lib/api/client_pack_error_messages.dart` |
| Camera + feedback helpers | `helpers/odometer_camera_helper.dart`, `helpers/client_pack_feedback.dart` |
| Odometer sheet | `widgets/odometer_km_sheet.dart` — start/end KM + camera photo |
| Driver boarding QR | `widgets/boarding_qr_panel.dart` — wakelock + auto-refresh |
| Commuter scan | `screens/boarding_scan_screen.dart` — route `RouteName.boardingScan` |
| Admin screen | `screens/d2d_channel.dart` (**no** QR) — **Remaining** first; **Already IN** collapsed |
| Driver screen | `screens/d2d_log_screen.dart` — start KM → large QR + CList → end KM → full-width **STOP TRIP** bar (no admin drawer) |
| Live widgets | `widgets/d2d_live_widgets.dart` — includes `D2dAlreadyInSection` |
| Action error SnackBar | `widgets/d2d_action_error_listener.dart` |
| Add commuter sheet | `widgets/d2d_add_commuter_sheet.dart` — search by name, mobile, batch, POP |

### Client pack UI (Phase 7)

| Flow | Behavior |
|------|----------|
| Driver start | After WS connect → start-KM sheet (**hard lock** until recorded; skip if already set) |
| Driver live | Large boarding QR (~280) + swipe REMOVE fallback; **Remaining** queue first (pickup label, not POP jargon); **Waiting line**; **Already IN** collapsed |
| Driver STOP | Full-width bottom **STOP TRIP** bar; end-KM sheet first (**skip if endKm already set**); soft “Stop anyway” if dismissed |
| Commuter | Mark Coming → Scan boarding QR → `boardingScan` |

Camera: **ImageSource.camera only** when used. Odometer: **KM required**, **photo optional**. Sheet: **Close** (top) / **Skip** (bottom) — no swipe-dismiss; Confirm submits without photo OK. Soft STOP (BE does not block).

Parked: return-leg KM UI, admin org odometer list, unboard UI.

Repo methods (unchanged): `submitOdometerStart`/`End`, `getOdometer`, `getBoardingQr`, `boardingScan`, `boardingUnboard`.

Failures return `ApiResult.failure` with `ApiFailure.code` + `ClientPackErrorMessages` / `ClientPackFeedback`.

---

## Connect flow

```dart
final uri = Uri.parse('${AppConfig.instance.webSocketUrl}$batchId/');
_channel = IOWebSocketChannel.connect(uri, headers: {HttpHeaders.cookieHeader: cookie});
// Stays loading until first message or close (4001 ended, 4401/4403 auth)
```

Both screens call `provider.connect(batchId)` in `initState` and `disconnect()` on dispose.

**Backend connect (once):** AuthMiddlewareStack → anonymous **4401** / wrong role **4403** → `accept` → group_add → `get_or_create` DTODLOG → if already ended **4001** → load Redis DS (`d2d:live:…`) or rebuild from `isComing` minus CList → send `{result: DS}`.

**Lifecycle (P3):** `AppLifecycleHost` observes OS foreground/background. On resume after background: session reconcile, running batches refresh, D2D reconnect if socket dropped (keeps stale list + `D2dConnectionLostBanner` until fresh WS frame). Android may kill the process; iOS may suspend with a dead socket — both recover on resume. Explicit leave/back still only `disconnect()` (not STOP).

**Disconnect ≠ STOP.** Leaving the screen (back, Close channel, `dispose`) only closes the WebSocket (`group_discard`). Redis DS remains for other clients. The `DTODLOG` row stays `isActive=true` until the driver **STOP TRIP** FAB sends `{ACTION: STOP}`.

The DB row is created on **connect** (`get_or_create(batchId, tripDate)`), not on STOP. Reconnect the same day after a real STOP is closed **4001**. Django restart mid-trip: Redis DS restored on reconnect.

Driver log also calls `provider.fetchTripStatus(batchId)` — REST `GET d2d/get_d2d_log_status/:batchId` via `D2dRepository`. Result is `D2dTripStatus` (`unknown` / `none` / `active` / `ended`). Admin discovery: `GET /d2d/running_batches/<admin_code>`.

Also loads driver via REST: `_driverRepository.getDriverByBatch(batchId)`.

---

## ViewState

`idle` → `loading` on connect → `success` on first WS message or `error` (including ended trip).

---

## WS actions (client → server)

| UI action | Who | Provider method | WS payload | Backend effect |
|-----------|-----|-----------------|------------|----------------|
| Driver swipe green | Driver | `confirmCommuter(id)` | `{ACTION: REMOVE, CLIST: [id]}` | CList += id; drop from live DS; `board_commuter` path |
| Driver swipe red | Admin/Driver | `denyCommuter` / `removeCommuter` | `{ACTION: DELETE, CLIST: [id]}` | Remove from DS only (not CList) |
| Add sheet **+** | Admin/Driver | `addCommuter(id)` | `{ACTION: ADD, CLIST: id}` | Lookup by **user ID** (this batch then any); needs POP; `capacity_full` / `invalid_commuter` |
| Driver STOP FAB | Driver only | `stopTrip()` | `{ACTION: STOP}` | `isActive=false`, endTime, clear isComing for CList+queue, `delete_live_state`, broadcast ended |

Role gating: Flutter `D2dChannelRolePolicy` + BE connect auth. Unauthorized mutation → `{error:"forbidden"}` without disconnect.

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

**STOP side effects (2026-08-31):** `set_commuters_is_coming(is_coming=False, scope='trip_end', …)` — home batch bulk + cross-batch participants (queue/CList/waiting). Redis live + waiting keys deleted via `live_state.py`. Phase 2 adds waiting join + FCFS auto-board.

**QR scan:** commuter must be in the live queue to board (`action: board`); cross-batch guests admin/driver ADDed may scan. Not in queue → `action: join_waiting` on same endpoint (separate tap after scan prompt). FCFS auto-boards waiting riders when seats open (DELETE / capacity).

**Waiting UI:** driver/admin see **Waiting line** between Remaining and collapsed Already IN.

**QA 2026-08-17:** Admin watching STOP showed ended UI (not WAITING). Close channel cleared Batch-01 LIVE tile. Driver same-day START showed 4001 / TRIP ENDED TODAY.

---

## Incoming payload

```json
{ "result": { "data": [...], "already_in": [...], "D2D_id": 12, "driver": { ... } } }
```

- **`data`** — live queue (not yet picked up).
- **`already_in`** — confirmed pickups (CList), hydrated same shape as queue entries.

Parsed by `_decodePayload`, `_parseCommutersFromData`, `parseAlreadyInFromResult`, `D2dCommuterModel.fromJson`.

---

## Manual test checklist

1. Start morning D2D — driver connects, admin opens channel.
2. **Start KM:** sheet after connect; camera photo + KM required.
3. **QR:** driver sees boarding QR; swipe REMOVE still works; admin has no QR.
4. **Scan:** commuter Mark Coming → Scan boarding QR → Already IN grows.
5. **End KM → STOP:** end sheet before STOP; soft “Stop anyway” if skipped.
6. **Capacity:** Fill cab; admin ADD via sheet → SnackBar with server message.
7. **Happy path:** Valid ADD → list updates. Missing POP → `invalid_commuter`.
8. **Ended trip:** Driver STOP; admin ended UI; dashboard LIVE tile clears.
9. Leave without STOP → trip stays active; reconnect joins same queue.
10. Device smoke (STEP 8) only after user says go.
