> **Doc:** docs/setup/RETURN_QR_UI_PREP.md
> **Updated:** 2026-09-08 15:18 IST
> **Session:** Return-trip QR boarding UI prep — await Dock BE contract

# Return-trip QR boarding — UI prep

**Status:** Flutter **UI scaffolding only**. Discuss-only until Dock green-flags BE.  
**Product lock:** evening / return trip uses the **same** QR boarding flow as morning (commuter scans cab QR). Do **not** invent parallel endpoints or camelCase fields.

## Reuse map (morning → return)

| Concern | Morning (shipped) | Return (this prep) |
|---------|-------------------|--------------------|
| Driver **show** QR | `BoardingQrPanel` on `/d2dLog/:batchId` | `ReturnBoardingQrPanel` → wraps `BoardingQrPanel`; screen `/returnBoardingQr/:batchId` |
| Commuter **scan** | `BoardingScanScreen` `/boardingScan` | Alias `/returnBoardingScan` → **same** screen |
| API | `GET /d2d/boarding_qr/<batch_id>/` · `POST /d2d/boarding_scan/` | **No new URLs.** Live call off by default (`useLiveMorningApi: false`) |
| Models | `boarding_models.dart` (`token`, `qr_payload`, `expires_in`, …) | Reuse only — no fabricated fields |
| Roles | DRIVER show; COMMUTER/STAFF scan; ADMIN channel **no** QR | DRIVER/ADMIN/SUPERVISOR may open show route; STAFF/COMMUTER scan alias |

Wire owners: [docs/API_CONTRACTS.md](../API_CONTRACTS.md) (client pack QR) · [lib/features/d2d/README.md](../../lib/features/d2d/README.md) · [lib/features/batches/README.md](../../lib/features/batches/README.md).

## Entry points

| Who | Where | Action |
|-----|-------|--------|
| DRIVER | Return list → **BOARDING QR** | `/returnBoardingQr/:batchId` (stub chrome until Dock) |
| STAFF / COMMUTER | Home → Return today → **Scan return boarding QR** | `/returnBoardingScan` (= morning scan) |
| ADMIN / SUPERVISOR | Deep-link / driver prefix (monitor) | May open show route; admin return list stays list-only (same as morning “no QR on channel”) |

## Await Dock

When Dock green-flags that return shares morning boarding helpers:

1. Set `useLiveMorningApi: true` on `ReturnBoardingQrScreen` / `ReturnBoardingQrPanel`.
2. Confirm token eligibility for return confirmed riders (not morning live queue) — **BE decision**, not Flutter invention.
3. Update [API_CONTRACTS.md](../API_CONTRACTS.md) only with Dock-approved paths/fields.
4. Un-park journey rows in [FLOWS_BY_ROLE.md](../FLOWS_BY_ROLE.md).

Until then: stub shows cream-board “Awaiting Dock boarding contract”; no invented `return_boarding_qr` clients.

## Cream-board UI language

No separate `CREAM_BOARD_SCHEMA_UI.md` in tree yet — follow existing theme:

- Page: `scheme.surfaceContainerHighest` / `AppColors.acCream`
- Ink: `CtsColors.navy` + hairline borders `navy @ ~0.14–0.2`
- Primary CTA: yellow fill (`cts.yellow`) for **BOARDING QR** (mirrors START TRIP / SCAN)
- Shared widgets preferred over mobile-only one-offs (web-ready structure)

## Tests

- `test/features/batches/return_boarding_role_policy_test.dart`
- `test/features/batches/return_boarding_qr_panel_test.dart`
- `test/app/router/auth_redirect_test.dart` — `/returnBoardingQr` · `/returnBoardingScan`
