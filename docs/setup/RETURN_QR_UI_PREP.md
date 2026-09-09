> **Doc:** docs/setup/RETURN_QR_UI_PREP.md
> **Updated:** 2026-09-09 18:55 IST
> **Session:** FE match — return scan no boarding_scan join_waiting

# Return-trip QR boarding — UI prep → Phase 2 wired

**Status:** Flutter **Phase 2 wired** (Dock / BHAKTA green-flag).  
**Product lock:** evening / return trip uses the **same QR boarding UX as morning**.  
**Contract:** [RETURN_TRIP_API_GAP.md](./RETURN_TRIP_API_GAP.md) · morning parsers in `boarding_models.dart`.

## Endpoints (wired)

| Role | Call |
|------|------|
| Driver mint return QR | `GET /d2d/boarding_qr/<batchId>/?trip=return` → token + `return_trip_id` |
| Morning mint | `GET /d2d/boarding_qr/<batchId>/` (unchanged) |
| Commuter scan | `POST /d2d/boarding_scan/` body `{token}` — token carries leg; **boards only** (return waiting = `add_commuter` `join_waiting`) |
| Confirm (existing) | `POST /d2d/return_batch/add_commuter` |
| End (existing) | BE → `return_board_archive`; trip keeps archive ID only |

Flutter: `BoardingQrPanel(trip: ApiUrl.boardingTripReturn)` via `ReturnBoardingQrPanel`; scan via `ReturnBoardingScanScreen` → shared `BoardingScanScreen` / `boardingScan`.

## Schema locks

| Layer | Direction |
|-------|-----------|
| Morning | `DTODLOG` + **CList** morning-only |
| Return | **Return trip log** + **RCList** (user-ID list on trip row) |
| Cleanup | No FE use of morning DTODLOG `return_*` |
| **On End** | BE archives to history; trip keeps archive ID only |
| **FE** | Live UI = **ID list only** — **do not build archive UI** |

## Screens / routes

| Who | Route | Widget |
|-----|-------|--------|
| DRIVER | `/returnBoardingQr/:batchId` | `ReturnBoardingQrScreen` → `ReturnBoardingQrPanel` |
| STAFF / COMMUTER | `/returnBoardingScan` | `ReturnBoardingScanScreen` → `BoardingScanScreen` |

## Cream-board

- Page cream / navy hairlines; yellow **BOARDING QR** CTA `borderRadius: 4` (match End Return)
- Rider-facing copy stays short (no docs paths in UI strings)

## Tests

- `test/features/d2d/client_pack_repository_test.dart` — `?trip=return` URL + `return_trip_id` parse
- `test/features/batches/return_boarding_*` — role / panel wrapper
- `test/app/router/auth_redirect_test.dart` — routes
