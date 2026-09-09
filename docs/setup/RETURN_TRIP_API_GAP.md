> **Doc:** docs/setup/RETURN_TRIP_API_GAP.md
> **Updated:** 2026-09-09 20:15 IST
> **Session:** FE agent names — returnTripLogId / tripLeg

# Return trip API gap — Phase 2 boarding QR

**Status:** Dock Phase 2 on BE tip `professor-dock` (return trip log + QR). FE wired on `professor-cts`.  
**FE owner note:** [RETURN_QR_UI_PREP.md](./RETURN_QR_UI_PREP.md).

If response fields differ in lab, Dock adjusts — **do not invent camelCase** beyond snake_case shown here and morning boarding client parsing.

## Boarding QR mint

| Leg | Request | Notes |
|-----|---------|-------|
| Morning | `GET /d2d/boarding_qr/<batchId>/` or `?trip=morning` | Unchanged |
| Return | `GET /d2d/boarding_qr/<batchId>/?trip=return` | Token + **`return_trip_id`** (return trip log PK) |

Flutter: `ApiUrl.boardingQr(batchId, trip: 'return')` → `D2dRepository.getBoardingQr`.

## Boarding scan

| | |
|--|--|
| Request | `POST /d2d/boarding_scan/` body `{ "token": "…" }` (+ optional `action` **morning only**) |
| Leg | Encoded **in the token** (`morning` \| `return`) — not a separate FE body field |
| Return board | Token from return mint → RCList on return trip log row |
| Return waiting | **Not** via `boarding_scan` — use `POST return_batch/add_commuter` `action: join_waiting` |

## FE Dart names (agents — prefer these)

| Dart | Wire | Meaning |
|------|------|---------|
| `returnTripLogId` | `return_trip_id` | PK of BE `return_trip_log` / ReturnTripLog |
| `tripLeg` | `trip` | `morning` \| `return` |
| `isReturnLeg` | (derived) | true when return leg / id present |

Stored on: `BoardingQrPayload`, `BoardingScanResult`, `OdometerSnapshot`, `ReturnTripLogRef` / `RclistRef`.

## Related return REST (unchanged confirm/end)

| | |
|--|--|
| Confirm | `POST /d2d/return_batch/add_commuter` (also ensures trip log + RCList) |
| End | Archives RCList → `return_board_archive`; trip keeps archive ID only |
| Morning STOP | → `going_board_archive` |

## FE locks

- Live **RCList** = user-ID list on return trip log row (like CList).
- **Do not** build FE archive UI (BE/history only).
- **Do not** bind morning DTODLOG `return_*` columns (removed from DB).
