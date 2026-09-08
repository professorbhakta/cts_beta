> **Doc:** docs/setup/RETURN_QR_UI_PREP.md
> **Updated:** 2026-09-08 15:45 IST
> **Session:** LOCKED — RCList ID list; End archives to history; FE no archive UI

# Return-trip QR boarding — UI prep

**Status:** Flutter **UI scaffolding only**. Discuss-only until Dock / BHAKTA green-flags BE + schema.  
**Product lock:** evening / return trip uses the **same QR boarding UX as morning** (commuter scans cab QR).  
**Schema direction (discuss-only):** do **not** hard-wire FE to old morning DTODLOG `return_*` fields.

## Schema redesign (await Dock gap-list)

| Layer | Direction |
|-------|-----------|
| Morning | `DTODLOG` + **CList** keep **morning-only** fields |
| Return | **New return trip log** + **RCList** |
| Cleanup | Drop `return_*` off the wide morning DTODLOG table |

### RCList + End (LOCKED)

- **Live RCList** = **user-ID list on the return trip log row** (like morning **CList**).
- **Not** a row-per-rider table for live boarding UI.
- **On End (BE):** archives RCList to a **history table**; the trip row keeps an **archive ID only**.
- **FE live UI** only needs the **ID list** — **do not build archive UI** (history is BE-side).

TODO(Dock): when gap-list lands in [API_CONTRACTS.md](../API_CONTRACTS.md), FE binds live ID list only; ignore archive payload for boarding screens.

**UI can look the same as morning.** Variables / repository bindings **update when the schema locks** — not by flipping a switch onto morning `boarding_qr` / `boarding_scan` or inventing camelCase fields.

Pointer for wire names when ready: [docs/API_CONTRACTS.md](../API_CONTRACTS.md) (gap-list TBD by Dock). Prep models: `lib/features/batches/models/return_trip_log_placeholders.dart`.

## Reuse map (visual only)

| Concern | Morning (shipped) | Return (this prep) |
|---------|-------------------|--------------------|
| Driver **show** QR | `BoardingQrPanel` on `/d2dLog/:batchId` | `ReturnBoardingQrPanel` / `ReturnBoardingQrScreen` — **visual parity**; stub until Dock |
| Commuter **scan** | `BoardingScanScreen` `/boardingScan` | `ReturnBoardingScanScreen` `/returnBoardingScan` — **visual shell**; no morning scan call |
| Live API | `GET …/boarding_qr/` · `POST …/boarding_scan/` | **Not used for return.** Future: `ReturnBoardingRepository` → return trip log + RCList (user-ID list) |
| Models | `boarding_models.dart` (morning) | `ReturnTripLogRef` · `RclistRef` · `ReturnBoardingQrViewModel` — placeholders, **no fabricated wire fields** |
| Roles | DRIVER show; COMMUTER/STAFF scan | Same role split via `ReturnBoardingRolePolicy` |

## Entry points

| Who | Where | Action |
|-----|-------|--------|
| DRIVER | Return list → **BOARDING QR** | `/returnBoardingQr/:batchId` (stub chrome) |
| STAFF / COMMUTER | Home → Return today → **Scan return boarding QR** | `/returnBoardingScan` (stub shell) |
| ADMIN / SUPERVISOR | Deep-link / driver prefix (monitor) | May open show route; admin return list stays list-only |

## Await Dock (checklist)

1. Publish return trip log + RCList as **user-ID list on log row** (+ boarding QR/scan) into [API_CONTRACTS.md](../API_CONTRACTS.md) — **gap-list**, approved snake_case only.
2. Implement `ReturnBoardingRepository` against those paths — **not** morning DTODLOG `return_*` / morning boarding helpers for evening.
3. Feed `ReturnBoardingQrViewModel.qrPayload` and scan → append to live RCList ID list.
4. **Do not** build FE archive/history UI — on End, BE archives; trip keeps archive ID only.
5. Un-park journey rows in [FLOWS_BY_ROLE.md](../FLOWS_BY_ROLE.md).

Until then: cream-board “Awaiting Dock …” stubs; no invented URLs or camelCase fields.

## Cream-board UI language

- Page: `scheme.surfaceContainerHighest` / `AppColors.acCream`
- Ink: `CtsColors.navy` + hairline borders `navy @ ~0.14–0.2`
- Primary CTA: yellow fill (`cts.yellow`) for **BOARDING QR**
- Shared widgets preferred over mobile-only one-offs (web-ready structure)

## Tests

- `test/features/batches/return_boarding_role_policy_test.dart`
- `test/features/batches/return_boarding_qr_panel_test.dart`
- `test/features/batches/return_trip_log_placeholders_test.dart`
- `test/app/router/auth_redirect_test.dart` — `/returnBoardingQr` · `/returnBoardingScan`
