// Boarding QR / scan API models.
//
// Wire fields are snake_case from BE. Return Phase 2 adds optional
// `return_trip_id` / `trip` on mint+scan when `?trip=return`
// (see docs/setup/RETURN_TRIP_API_GAP.md).

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
    this.returnTripId,
    this.trip,
  });

  final String token;

  /// Value to encode in the QR (same as [token] today).
  final String qrPayload;
  final int expiresIn;
  final String batchId;
  final int d2dId;
  final String tripDate;

  /// Present on return-leg mint (`?trip=return`) — binds to return trip log.
  /// Null for morning mint. Kept for later UI / sync consumers.
  final String? returnTripId;

  /// Wire `trip`: `morning` | `return` when present.
  final String? trip;

  factory BoardingQrPayload.fromJson(Map<String, dynamic> json) {
    return BoardingQrPayload(
      token: json['token']?.toString() ?? '',
      qrPayload:
          json['qr_payload']?.toString() ?? json['token']?.toString() ?? '',
      expiresIn: int.tryParse(json['expires_in']?.toString() ?? '') ?? 0,
      batchId: json['batch_id']?.toString() ?? '',
      d2dId: int.tryParse(json['d2d_id']?.toString() ?? '') ?? 0,
      tripDate: json['trip_date']?.toString() ?? '',
      returnTripId: _optionalWireString(json['return_trip_id']),
      trip: _optionalWireString(json['trip']),
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
    this.returnTripId,
    this.trip,
  });

  final bool alreadyBoarded;
  final String batchId;
  final int userId;
  final String action;
  final int queuePosition;
  final String? message;

  /// Present on return-leg scan; store for later consumers (live RCList sync).
  final String? returnTripId;

  /// Wire `trip`: `morning` | `return` when present.
  final String? trip;

  factory BoardingScanResult.fromJson(Map<String, dynamic> json) {
    return BoardingScanResult(
      alreadyBoarded: json['already_boarded'] == true,
      batchId: json['batch_id']?.toString() ?? '',
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      action: json['action']?.toString() ?? 'board',
      queuePosition: int.tryParse(json['queue_position']?.toString() ?? '') ?? 0,
      message: _optionalWireString(json['message']),
      returnTripId: _optionalWireString(json['return_trip_id']),
      trip: _optionalWireString(json['trip']),
    );
  }
}
