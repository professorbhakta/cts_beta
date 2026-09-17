// Boarding QR / scan API models.
//
// Wire fields are snake_case from BE. Return Phase 2 adds optional
// `return_trip_id` / `trip` on mint+scan when `?trip=return`
// (see docs/setup/RETURN_TRIP_API_GAP.md).
//
// Agent / future UI field map (Dart ← wire):
//   returnTripLogId ← return_trip_id  // PK of BE table return_trip_log (ReturnTripLog)
//   tripLeg         ← trip            // "morning" | "return" (which boarding leg)
// Do not rename wire keys. Prefer these Dart names in new screens/providers.

String? _optionalWireString(dynamic raw) {
  if (raw == null) return null;
  final text = raw.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null' || text == 'None') {
    return null;
  }
  return text;
}

class BoardingQrPayload {
  const BoardingQrPayload({
    required this.token,
    required this.qrPayload,
    required this.expiresIn,
    required this.batchId,
    required this.d2dId,
    required this.tripDate,
    this.returnTripLogId,
    this.tripLeg,
  });

  final String token;

  /// Value to encode in the QR (same as [token] today).
  final String qrPayload;
  final int expiresIn;
  final String batchId;

  /// Morning DTODLOG id when present; `0` on return mint (return uses [returnTripLogId]).
  final int d2dId;
  final String tripDate;

  /// BE `return_trip_id` — primary key of `return_trip_log` / ReturnTripLog.
  /// Null on morning mint. Use for later RCList / return odo consumers.
  final String? returnTripLogId;

  /// BE `trip` — boarding leg: `morning` | `return` (when present).
  final String? tripLeg;

  /// True when this mint/scan is the return (evening) leg.
  bool get isReturnLeg => tripLeg == 'return' || returnTripLogId != null;

  factory BoardingQrPayload.fromJson(Map<String, dynamic> json) {
    return BoardingQrPayload(
      token: json['token']?.toString() ?? '',
      qrPayload:
          json['qr_payload']?.toString() ?? json['token']?.toString() ?? '',
      expiresIn: int.tryParse(json['expires_in']?.toString() ?? '') ?? 0,
      batchId: json['batch_id']?.toString() ?? '',
      d2dId: int.tryParse(json['d2d_id']?.toString() ?? '') ?? 0,
      tripDate: json['trip_date']?.toString() ?? '',
      returnTripLogId: _optionalWireString(json['return_trip_id']),
      tripLeg: _optionalWireString(json['trip']),
    );
  }
}

class BoardingScanResult {
  const BoardingScanResult({
    required this.alreadyBoarded,
    required this.batchId,
    required this.userId,
    this.action = 'board',
    this.queuePosition = 0,
    this.message,
    this.returnTripLogId,
    this.tripLeg,
  });

  final bool alreadyBoarded;
  final String batchId;
  final int userId;
  final String action;
  final int queuePosition;
  final String? message;

  /// BE `return_trip_id` — ReturnTripLog PK after a return-leg scan.
  /// Keep for live RCList / history consumers (no archive UI on FE).
  final String? returnTripLogId;

  /// BE `trip` — `morning` | `return` when present.
  final String? tripLeg;

  /// True when scan boarded the return (evening) leg.
  bool get isReturnLeg => tripLeg == 'return' || returnTripLogId != null;

  factory BoardingScanResult.fromJson(Map<String, dynamic> json) {
    return BoardingScanResult(
      alreadyBoarded: json['already_boarded'] == true,
      batchId: json['batch_id']?.toString() ?? '',
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      action: json['action']?.toString() ?? 'board',
      queuePosition: int.tryParse(json['queue_position']?.toString() ?? '') ?? 0,
      message: _optionalWireString(json['message']),
      returnTripLogId: _optionalWireString(json['return_trip_id']),
      tripLeg: _optionalWireString(json['trip']),
    );
  }
}
