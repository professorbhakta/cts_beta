> **Doc:** docs/setup/RETURN_QR_UI_PREP.md
> **Updated:** 2026-09-12 15:55 IST
> **Session:** Absorbed CLIENT_RETURN_QR_NOTE locks; note retired

# Return-trip QR boarding — UI prep → Phase 2 wired

**Status:** Flutter **Phase 2 wired** (Dock / BHAKTA green-flag).  
**Product lock (BHAKTA):** evening / return trip uses the **same QR boarding UX as morning** — only that ask; no invented extra return features.  
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

**FE names for agents (Dart ← wire):**
| Dart | Wire | Meaning |
|------|------|---------|
| `returnTripLogId` | `return_trip_id` | PK of BE `return_trip_log` / ReturnTripLog |
| `tripLeg` | `trip` | `morning` \| `return` |
| `isReturnLeg` | (derived) | true when return leg / id present |

Stored on: `BoardingQrPayload`, `BoardingScanResult`, `OdometerSnapshot`, `ReturnTripLogRef` / `RclistRef`.

## Schema locks (client + dock)

| Layer | Direction |
|-------|-----------|
| Morning | `DTODLOG` + **CList** morning-only |
| Return | Full **return trip log** (DTODLOG-like shell) + **RCList** = user-ID list on trip row (not one row per rider) |
| Truth | Live = Redis + sockets + list on trip row — **not** Redis-only boarding truth |
| Cleanup | No FE use of morning DTODLOG `return_*` |
| **On End** | BE archives list to history; trip keeps archive ID only |
| **FE** | Live UI = **ID list only** — **do not build archive UI** |
| Race | Concurrent QR list writes OK for small audience; no extra tables for now |

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
