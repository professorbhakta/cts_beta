/// Return boarding context helpers (Phase 2).
///
/// Live **RCList** = user-ID list on the return trip log row (like morning CList).
/// On End, BE archives to history; trip keeps archive ID only — **FE no archive UI**.
///
/// Mint/scan wire: [docs/setup/RETURN_TRIP_API_GAP.md] — `?trip=return` +
/// `return_trip_id` (snake_case). Do not invent extra camelCase fields.
library;

/// Batch context for return boarding routes (UI / routing).
class ReturnTripLogRef {
  const ReturnTripLogRef({required this.batchId, this.returnTripId});

  final String batchId;

  /// From mint response `return_trip_id` when present.
  final String? returnTripId;
}

/// RCList context — live boarded **user-ID list** on the return trip log row.
class RclistRef {
  const RclistRef({required this.batchId, this.returnTripId});

  final String batchId;
  final String? returnTripId;
}
