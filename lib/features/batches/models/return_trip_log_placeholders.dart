/// Return boarding context helpers (Phase 2).
///
/// Live **RCList** = user-ID list on the return trip log row (like morning CList).
/// On End, BE archives to history; trip keeps archive ID only — **FE no archive UI**.
///
/// Mint/scan wire: [docs/setup/RETURN_TRIP_API_GAP.md] — `?trip=return` +
/// `return_trip_id` (snake_case).
///
/// Agent map: Dart `returnTripLogId` ← wire `return_trip_id` (ReturnTripLog PK).
library;

/// Batch context for return boarding routes (UI / routing).
class ReturnTripLogRef {
  const ReturnTripLogRef({required this.batchId, this.returnTripLogId});

  final String batchId;

  /// From mint/scan `return_trip_id` — PK of BE `return_trip_log`.
  final String? returnTripLogId;
}

/// RCList context — live boarded **user-ID list** on the return trip log row.
class RclistRef {
  const RclistRef({required this.batchId, this.returnTripLogId});

  final String batchId;

  /// Same id as [ReturnTripLogRef.returnTripLogId] (wire `return_trip_id`).
  final String? returnTripLogId;
}
