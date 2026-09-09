> **Doc:** docs/setup/RETURN_TRIP_API_GAP.md
> **Updated:** 2026-09-08 23:50 IST
> **Session:** Dock Phase 2 green-flag — return QR mint/scan contract (lab)

# Return trip API gap — Phase 2 boarding QR

**Status:** Dock Phase 2 on BE tip `professor-dock` (return trip log + QR). FE wired on `professor-cts`.  
**FE owner note:** [RETURN_QR_UI_PREP.md](./RETURN_QR_UI_PREP.md).

If response fields differ in lab, Dock adjusts — **do not invent camelCase** beyond snake_case shown here and morning boarding client parsing.

## Boarding QR mint

| Leg | Request | Notes |
|-----|---------|-------|
| Morning | `GET /d2d/boarding_qr/<batchId>/` or `?trip=morning` | Unchanged |
| Return | `GET /d2d/boarding_qr/<batchId>/?trip=return` | Token + **`return_trip_id`** (return trip log) |

Flutter: `ApiUrl.boardingQr(batchId, trip: 'return')` → `D2dRepository.getBoardingQr`.

## Boarding scan

| | |
|--|--|
| Request | `POST /d2d/boarding_scan/` body `{ "token": "…" }` (+ optional `action`) |
| Leg | Encoded **in the token** (`morning` \| `return`) — not a separate FE body field |
| Return board | Token from return mint → RCList on return trip log row |

## Related return REST (unchanged confirm/end)

| | |
|--|--|
| Confirm | `POST /d2d/return_batch/add_commuter` (also ensures trip log + RCList) |
| End | Archives RCList → `return_board_archive`; trip keeps archive ID only |
| Morning STOP | → `going_board_archive` |

## FE locks

- Live **RCList** = user-ID list on return trip log row (like CList).
- **Do not** build FE archive UI (BE/history only).
- **Do not** bind morning DTODLOG `return_*` columns.
