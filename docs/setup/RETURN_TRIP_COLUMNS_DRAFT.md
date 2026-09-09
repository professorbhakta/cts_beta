> **Doc:** docs/setup/RETURN_TRIP_COLUMNS_DRAFT.md
> **Updated:** 2026-09-09
> **Session:** DTODLOG return_* stripped; return odometer on ReturnTripLog (BHAKTA green flag)

# Return / going board columns

Live boarded IDs: **Redis + sockets**, and **RCList / CList on the trip row** (needed for live pool).  
On **End**: snapshot into archive table; trip keeps archive id.

Table / model style: **lower snake_case** (e.g. `return_board_archive`).

---

## 1) `return_trip_log` — one evening trip per batch + date

| Column | Type | Notes |
|--------|------|--------|
| `id` | PK | |
| `batchId` | FK → Batch | |
| `tripDate` | date | unique with batchId |
| `isActive` | bool | |
| `startTime` | datetime | |
| `endTime` | datetime null | |
| `start_km` | int null | return odometer (was DTODLOG.return_*) |
| `end_km` | int null | |
| `start_photo` | file null | upload helpers still `odometer_return_*_upload` |
| `end_photo` | file null | |
| `start_recorded_at` | datetime null | |
| `end_recorded_at` | datetime null | |
| `RCList` | int[] | **live** boarded user ids (with Redis) |

**Unique:** (`batchId`, `tripDate`)

Archive link: OneToOne from `return_board_archive.return_trip` (related_name `board_archive`).

---

## 2) `return_board_archive` — after return End

| Column | Type | Notes |
|--------|------|--------|
| `id` | PK | |
| `return_trip_id` | FK → return_trip_log | |
| `userIds` | int[] | final list snapshot |
| `archivedAt` | datetime | |
| `batchId` | FK/int | copy for reports |
| `tripDate` | date | copy for reports |

---

## 3) `going_board_archive` — after morning End

| Column | Type | Notes |
|--------|------|--------|
| `id` | PK | |
| `dtodlog_id` | FK → DTODLOG | morning trip |
| `userIds` | int[] | final CList snapshot |
| `archivedAt` | datetime | |
| `batchId` | FK/int | |
| `tripDate` | date | |

---

## 4) Morning `DTODLOG` (kept columns)

| Column | Notes |
|--------|--------|
| `CList`, `batchId`, `startTime`, `endTime`, `tripDate`, `isActive` | trip shell |
| `morning_start_km`, `morning_end_km` | morning odometer |
| `morning_start_photo`, `morning_end_photo` | |
| `morning_start_recorded_at`, `morning_end_recorded_at` | |

**Removed (2026-09-09):** all `return_*` on DTODLOG — `return_start_time`, `return_end_time`, `return_start_km`, `return_end_km`, `return_start_photo`, `return_end_photo`, `return_start_recorded_at`, `return_end_recorded_at`. Return odometer lives on `ReturnTripLog` (`start_km` / `end_km` / photos / recorded_at, no `return_` prefix). Migration: `remove_dtodlog_return_fields`.

---

## Live flow (short)

1. Start → trip row + Redis  
2. Scan / pool → Redis + socket + update `RCList` / `CList` on trip  
3. End → write archive (`return_board_archive` or `going_board_archive`), stop live

---

## Locked from BHAKTA

- Names: snake_case (`return_trip_log`, `return_board_archive`, `going_board_archive`)  
- Live list on trip: **yes** (`RCList` / `CList`)  
- Morning also gets `going_board_archive`  
- **2026-09-09 green flag:** strip DTODLOG `return_*`; odometer return leg → ReturnTripLog
