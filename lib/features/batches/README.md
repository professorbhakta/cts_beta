> **Doc:** lib/features/batches/README.md
> **Updated:** 2026-08-19 22:45 IST
> **Session:** P1 Truth Contract on POST actions

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
| Models | `models/batch_model.dart`, `models/return_batch_status_model.dart`, `models/return_available_model.dart` |
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

**Truth contract (P1):** POST add/remove/end parse body via `ApiResponseContract` (`lib/api/api_response_contract.dart`). HTTP 200 + `{status:error}` → `ApiResult.failure` (provider skips reload; screen shows error SnackBar). Known success statuses: `added`, `removed`, `ended`, `already_confirmed`, `ok`. Unknown status → fail closed.

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

**ReturningBatchScreen:** `BatchProvider.fetchBatches()` + `ReturnBatchProvider.fetchStatusesForBatches()` — cards show return time, available count, **Seats left** (`remaining_capacity` / `total_capacity`), confirmed count, active dot, driver name. When GET status includes pool extras: **Home hold**, **Overflow in**, **Overflow open**. Fail closed (keys omitted) hides those three rows. Tap → `/returnCommuterScreen/$batchId`.

**ReturnCommuterListScreen (admin + driver):** capacity banner (seats remaining = `remaining_capacity`; extras line when `hasPoolExtras`); Available tab **Home** then **Overflow** (GET view `home[]` / `overflow[]`); Confirmed tab (swipe Remove); search by name, mobile, batch, POP. End return FAB is admin-only. Confirmed riders are dropped from both Available sections. Overflow Confirm is disabled when `overflow_remaining == 0` (not Seats left). `loadReturnTrip` also GET status (extras). Old flat `commuters` is ignored.

---

## Driver return screen (confirm / remove)

| Item | Value |
|------|-------|
| Route | `/driverReturnCommuter/:batchId` |
| Entry | Driver home → **RETURN LIST** (requires `batchId`) |
| Implementation | `canEndTrip: false` — swipe Confirm/Remove like admin; no End FAB |
| Provider | Reuses `loadReturnTrip(batchId)` (view + get_commuter + status) |
| Add API | `POST add_commuter` `{ batch_id, commuter_id }` — `commuter_id` = user ID. M7 rejects not yet. |

```dart
context.read<ReturnBatchProvider>().loadReturnTrip(batchId);
final status = context.read<ReturnBatchProvider>().statusForBatch(batchId);
// status.availableCount, confirmedCount, remainingCapacity, isActive
// status.hasPoolExtras → homeHold, overflowConfirmed, overflowRemaining
```

---

## Manual test checklist

1. Login as admin — Available shows Home (this batch, CList) then Overflow (later returnTime). Confirm moves them to Confirmed.
2. Login as assigned driver — tap **RETURN LIST**. Same Home / Overflow sections; no End FAB.
3. Driver swipe Confirm calls `POST add_commuter`; rider appears on Confirmed and leaves Available.
4. Driver can Remove; End FAB is admin-only.
5. Overflow Confirm is off when Overflow open is 0. Seats left is still remaining/total.
7. Picker **Seats left** is `remaining/total`, not Overflow open. Home hold `0` after no morning STOP is valid extras, not a bug.
8. If GET status omits extras (fail closed), Home hold / Overflow rows are hidden; old counts still show.
9. No morning STOP today → Available Home/Overflow empty (not 1500 org names).
