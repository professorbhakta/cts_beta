// EditRecord audit rows — snake_case wire from GET /d2d/edit_record/.

class EditRecordItem {
  const EditRecordItem({
    required this.id,
    this.userId,
    this.username,
    this.editedAt,
    this.method,
    this.path,
    this.resourceType,
    this.resourceId,
    this.payloadSummary = const {},
    this.ip,
  });

  final int id;
  final int? userId;
  final String? username;
  final String? editedAt;
  final String? method;
  final String? path;
  final String? resourceType;
  final String? resourceId;
  final Map<String, dynamic> payloadSummary;
  final String? ip;

  bool get isTripOdometer =>
      (resourceType ?? '').toLowerCase() == 'trip_odometer';

  /// from→to when trip_odometer payload has previous_end_km + end_km.
  String? get endKmChangeLabel {
    final prev = payloadSummary['previous_end_km'];
    final next = payloadSummary['end_km'];
    if (prev == null && next == null) return null;
    if (prev == null) return '→ $next';
    if (next == null) return '$prev →';
    return '$prev → $next';
  }

  factory EditRecordItem.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload_summary'];
    final payload = rawPayload is Map
        ? Map<String, dynamic>.from(rawPayload)
        : <String, dynamic>{};
    return EditRecordItem(
      id: _asInt(json['id']) ?? 0,
      userId: _asInt(json['userId'] ?? json['user_id']),
      username: _asString(json['username']),
      editedAt: _asString(json['edited_at']),
      method: _asString(json['method']),
      path: _asString(json['path']),
      resourceType: _asString(json['resource_type']),
      resourceId: _asString(json['resource_id']),
      payloadSummary: payload,
      ip: _asString(json['ip']),
    );
  }

  static int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  static String? _asString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}

class EditRecordListResponse {
  const EditRecordListResponse({
    required this.count,
    required this.items,
  });

  final int count;
  final List<EditRecordItem> items;

  factory EditRecordListResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <EditRecordItem>[];
    if (rawItems is List) {
      for (final row in rawItems) {
        if (row is Map) {
          items.add(EditRecordItem.fromJson(Map<String, dynamic>.from(row)));
        }
      }
    }
    final count = EditRecordItem._asInt(json['count']) ?? items.length;
    return EditRecordListResponse(count: count, items: items);
  }
}
