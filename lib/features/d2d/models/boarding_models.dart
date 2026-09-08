// Boarding QR / scan API models.
//
// Wire fields are snake_case from BE. Return Phase 2 adds optional
// `return_trip_id` on mint when `?trip=return` (see docs/setup/RETURN_TRIP_API_GAP.md).

class BoardingQrPayload {
  const BoardingQrPayload({
    required this.token,
    required this.qrPayload,
    required this.expiresIn,
    required this.batchId,
    required this.d2dId,
    required this.tripDate,
    this.returnTripId,
  });

  final String token;

  /// Value to encode in the QR (same as [token] today).
  final String qrPayload;
  final int expiresIn;
  final String batchId;
  final int d2dId;
  final String tripDate;

  /// Present on return-leg mint (`?trip=return`) — binds to return trip log, not
  /// morning DTODLOG `return_*`. Null for morning mint.
  final String? returnTripId;

  factory BoardingQrPayload.fromJson(Map<String, dynamic> json) {
    final returnTripRaw = json['return_trip_id'];
    return BoardingQrPayload(
      token: json['token']?.toString() ?? '',
      qrPayload:
          json['qr_payload']?.toString() ?? json['token']?.toString() ?? '',
      expiresIn: int.tryParse(json['expires_in']?.toString() ?? '') ?? 0,
      batchId: json['batch_id']?.toString() ?? '',
      d2dId: int.tryParse(json['d2d_id']?.toString() ?? '') ?? 0,
      tripDate: json['trip_date']?.toString() ?? '',
      returnTripId: returnTripRaw == null || returnTripRaw.toString().isEmpty
          ? null
          : returnTripRaw.toString(),
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
  });

  final bool alreadyBoarded;
  final String batchId;
  final int userId;
  final String action;
  final int queuePosition;
  final String? message;

  factory BoardingScanResult.fromJson(Map<String, dynamic> json) {
    return BoardingScanResult(
      alreadyBoarded: json['already_boarded'] == true,
      batchId: json['batch_id']?.toString() ?? '',
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      action: json['action']?.toString() ?? 'board',
      queuePosition: int.tryParse(json['queue_position']?.toString() ?? '') ?? 0,
      message: json['message']?.toString(),
    );
  }
}
