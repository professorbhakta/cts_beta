> **Doc:** lib/features/batches/README.md
> **Updated:** 2026-08-05 11:37 IST
> **Session:** Merged driver return screen detail from talk-guide

# Batches Feature — CRUD, Running, Return REST

Feature owner for batch management, running batches, and evening return trips (REST only — no WebSocket).

**Full API spec:** [docs/API_CONTRACTS.md](../../../docs/API_CONTRACTS.md) · **E2E flow:** [docs/features/RETURN_BATCH_E2E.md](../../../docs/features/RETURN_BATCH_E2E.md)

---

## Key files

| Role | Path |
|------|------|
| Batch CRUD screen | `screens/batch_screen.dart` |
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
| `/runningBatchScreen` | `RunningBatchScreen` |
| `/driverReturnCommuter/:batchId` | Driver read-only return list |

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

**ReturnCommuterListScreen (admin):** capacity banner; Available tab (swipe Confirm); Confirmed tab (swipe Remove); End return FAB with confirm dialog.

---

## Driver return screen (read-only)

| Item | Value |
|------|-------|
| Route | `/driverReturnCommuter/:batchId` |
| Entry | Driver home → **VIEW RETURN LIST** (requires `batchId`) |
| Implementation | `readOnly: true` on `ReturnCommuterListScreen` — no swipe actions, no End FAB |
| Provider | Reuses `loadReturnTrip(batchId)` + optional `fetchStatusesForBatches([batchId])` |

```dart
context.read<ReturnBatchProvider>().loadReturnTrip(batchId);
final status = context.read<ReturnBatchProvider>().statusForBatch(batchId);
// status.availableCount, confirmedCount, remainingCapacity, isActive
```

---

## Manual test checklist

1. Login as admin — confirm/add commuters on return batch.
2. Login as assigned driver — tap **VIEW RETURN LIST**.
3. Verify Available and Confirmed tabs match admin counts.
4. Confirm no swipe actions and no End FAB on driver screen.
5. Admin removes a commuter — driver pull-to-refresh shows update.
6. Login as commuter — direct URL to `/driverReturnCommuter/1` redirects or denies.
