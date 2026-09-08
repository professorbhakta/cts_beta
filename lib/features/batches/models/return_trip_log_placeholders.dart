/// Placeholder bindings for the **future** return-trip log + RCList schema.
///
/// Discuss-only (Dock / BHAKTA): table schema is being redesigned.
/// - Morning [DTODLOG] / CList keep **morning-only** fields.
/// - Return gets a **new return trip log** + **RCList**.
/// - Drop `return_*` off the wide morning DTODLOG table.
///
/// **RCList lock:** user-ID list **on the return trip log row** (like morning
/// CList) — **not** a row-per-rider table. Live UI binds that ID list.
/// Possible future archive-on-end is **BE/history only** — not a live UI model.
///
/// **Do not** invent final camelCase API fields here. Wire names land only after
/// Dock publishes the gap-list into [docs/API_CONTRACTS.md] and
/// [docs/setup/RETURN_QR_UI_PREP.md].
///
/// UI may look the same as morning QR boarding; **variables / bindings update
/// when the schema locks** — not by reusing morning DTODLOG `return_*` columns
/// or hard-wiring FE to morning `boarding_qr` / `boarding_scan` for evening.
library;

/// TODO(Dock): future **return trip log** row identity (separate from morning DTODLOG).
///
/// Hold only a batch/context handle for UI prep. No fabricated wire fields.
/// RCList (boarded user IDs) will live **on this row**, like CList on DTODLOG.
class ReturnTripLogRef {
  const ReturnTripLogRef({required this.batchId});

  /// Batch this evening trip is for — UI routing only until schema locks.
  final String batchId;
}

/// TODO(Dock): future **RCList** — user-ID list on the return trip log row
/// (same shape idea as morning CList; **not** row-per-rider).
///
/// Live UI binds the ID list. Archive-on-end (if any) is BE/history only.
/// Prep handle only — do not invent member DTOs or camelCase payload keys.
class RclistRef {
  const RclistRef({required this.batchId});

  final String batchId;
}

/// TODO(Dock): future return boarding QR **display** binding.
///
/// When Dock locks the contract, map approved snake_case wire → this view model.
/// Until then [qrPayload] stays null and the panel shows await-Dock chrome.
///
/// Intentionally **not** typed to morning [BoardingQrPayload] / DTODLOG fields.
class ReturnBoardingQrViewModel {
  const ReturnBoardingQrViewModel({
    required this.tripLog,
    required this.rclist,
    this.qrPayload,
  });

  final ReturnTripLogRef tripLog;

  /// Points at the return trip log's RCList (user-ID list) context — not riders table.
  final RclistRef rclist;

  /// Opaque string to encode in the QR face once Dock defines the token source.
  /// Null → stub UI. Do not invent token field names.
  final String? qrPayload;
}

/// TODO(Dock): repository surface for return boarding show/scan.
///
/// Bind to return-trip-log + RCList (user-ID list on log row) when
/// API_CONTRACTS gap-list lands. Live UI stays on the ID list; any
/// archive-on-end is BE/history only.
/// **Do not** call morning `GET /d2d/boarding_qr/` or `POST /d2d/boarding_scan/`
/// for evening trips, and **do not** read morning DTODLOG `return_*` columns.
abstract class ReturnBoardingRepository {
  /// Issue / refresh driver-facing QR payload for an active return trip log.
  Future<ReturnBoardingQrViewModel> getReturnBoardingQr(ReturnTripLogRef trip);

  /// Commuter scan → append user id onto RCList on the return trip log row
  /// (action vocabulary / wire names TBD by Dock — do not invent).
  Future<void> scanReturnBoarding({
    required String rawQr,
    required RclistRef rclist,
  });
}
