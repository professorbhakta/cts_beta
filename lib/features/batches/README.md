> **Doc:** lib/features/batches/README.md
> **Updated:** 2026-08-14 22:00 IST
> **Session:** Driver return ADD; any-batch pool; hide confirmed

# Batches Feature — CRUD, Running, Return REST

Feature owner for batch management, running batches, and evening return trips (REST only — no WebSocket).

**Full API spec:** [docs/API_CONTRACTS.md](../../../docs/API_CONTRACTS.md) · **E2E flow:** [docs/features/RETURN_BATCH_E2E.md](../../../docs/features/RETURN_BATCH_E2E.md)

---

## Key files

| Role | Path |
|------|------|
| Batch CRUD screen | `screens/batch_screen.dart` |
| Nested batch commuters | `../commuters/screens/commuter_list_screen.dart` — swipe EDIT passes `CommuterModel`; `ComingTodaySwitch` → `updateCommuterIsComing` (`PATCH /user/commuter/<userId>`) |
| Running batch screen | `screens/running_batch_screen.dart` |
| Return batch picker | `screens/returning_batch_screen.dart` |
| Return commuter UI | `../commuters/screens/return_batch_commuter_screen.dart` |
| Return provider | `providers/return_batch_provider.dart` |
| Running provider | `providers/running_batch_provider.dart` |
| Batch form provider | `providers/batch_form_provider.dart` |
| Batch controller | `providers/batch_controller.dart` |
| Repositories | `repositories/batch_repository*.dart`, `running_batch_repository*.dart`, `return_batch_repository*.dart`, `offline_first_batch_repository.dart` |
| Models | `models/batch_model.dart`, `models/return_batch_status_model.dart` |
| Batch form | `forms/batch_form.dart` |

---

## Routes

| Route | Screen |
|-------|--------|
| `/returnBatchScreen` | `ReturningBatchScreen` — batch picker |
| `/returnCommuterScreen/:batchId` | `ReturnCommuterListScreen` — admin confirm/remove/end |
| `/runningBatchScreen` | `RunningBatchScreen` — morning live DTODLOG snapshot only |
| `/driverReturnCommuter/:batchId` | Driver return list (confirm/remove; no End) |

**Running batches (morning D2D):** `GET` running list on screen open, pull-to-refresh, app resume, return from the D2D channel, and when the admin channel sees trip-ended. No 20s poll. Live pickup is WebSocket on `/d2dChannel/:id`. Evening return is a different backend (`ReturnBatchProvider`).

Entry: Admin home or batch screen → Return Batches.

---

## ReturnBatchProvider methods

| Method | Backend |
|--------|---------|
| `fetchStatusesForBatches(ids)` | `GET return_batch/status/{id}` |
| `loadReturnTrip(batchId)` | Parallel `view/` + `get_commuter/` |
| `confirmCommuter(userId, batchId)` | `POST add_commuter` |
| `removeCommuter(userId, batchId)` | `POST remove_commuter` |
| `endReturnTrip(batchId)` | `POST end/{id}` |

**ID rule:** Always pass **`userId.id`** as `commuter_id` in POST body.

**Client notes:** `get_commuter` does not send `?hydrate=` (backend default hydrates `commuters`). `end` is **POST only** from Flutter even though the backend also allows GET.

---

## ApiUrl constants (`lib/api/api_list.dart`)

```dart
returnBatchView = "d2d/return_batch/view/";
returnBatchStatus = "d2d/return_batch/status/";
returnBatchGetCommuter = "d2d/return_batch/get_commuter/";
returnBatchAddCommuter = "d2d/return_batch/add_commuter";
returnBatchRemoveCommuter = "d2d/return_batch/remove_commuter";
returnBatchEnd = "d2d/return_batch/end/";
```

---

## UI behavior (return)

**ReturningBatchScreen:** `BatchProvider.fetchBatches()` + `ReturnBatchProvider.fetchStatusesForBatches()` — cards show return time, available count, seats left, confirmed count, active dot, driver name; tap → `/returnCommuterScreen/$batchId`.

**ReturnCommuterListScreen (admin):** capacity banner; Available tab (swipe Confirm); Confirmed tab (swipe Remove); End return FAB with confirm dialog. Available is every org commuter not already confirmed today (any assigned batch). Confirmed riders are dropped from Available.

---

## Driver return screen (confirm / remove)

| Item | Value |
|------|-------|
| Route | `/driverReturnCommuter/:batchId` |
| Entry | Driver home → **RETURN LIST** (requires `batchId`) |
| Implementation | `canEndTrip: false` — swipe Confirm/Remove like admin; no End FAB |
| Provider | Reuses `loadReturnTrip(batchId)` + `fetchStatusesForBatches([batchId])` |
| Add API | `POST add_commuter` `{ batch_id, commuter_id }` — `commuter_id` = user ID, any org commuter |

```dart
context.read<ReturnBatchProvider>().loadReturnTrip(batchId);
final status = context.read<ReturnBatchProvider>().statusForBatch(batchId);
// status.availableCount, confirmedCount, remainingCapacity, isActive
```

---

## Manual test checklist

1. Login as admin — Available lists all org commuters; Confirm moves them to Confirmed and drops them from Available (this batch and others).
2. Login as assigned driver — tap **RETURN LIST**.
3. Driver swipe Confirm calls `POST add_commuter`; rider appears on Confirmed and leaves Available.
4. Driver can Remove; End FAB is admin-only.
5. Confirm a rider assigned to another morning batch — they hydrate on Confirmed.
6. Login as commuter — direct URL to `/driverReturnCommuter/1` redirects or denies.
