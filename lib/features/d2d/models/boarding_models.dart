// Boarding QR / scan API models.

class BoardingQrPayload {
  const BoardingQrPayload({
    required this.token,
    required this.qrPayload,
    required this.expiresIn,
    required this.batchId,
    required this.d2dId,
    required this.tripDate,
  });

  final String token;

  /// Value to encode in the QR (same as [token] today).
  final String qrPayload;
  final int expiresIn;
  final String batchId;
  final int d2dId;
  final String tripDate;

  factory BoardingQrPayload.fromJson(Map<String, dynamic> json) {
    return BoardingQrPayload(
      token: json['token']?.toString() ?? '',
      qrPayload: json['qr_payload']?.toString() ?? json['token']?.toString() ?? '',
      expiresIn: int.tryParse(json['expires_in']?.toString() ?? '') ?? 0,
      batchId: json['batch_id']?.toString() ?? '',
      d2dId: int.tryParse(json['d2d_id']?.toString() ?? '') ?? 0,
      tripDate: json['trip_date']?.toString() ?? '',
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
