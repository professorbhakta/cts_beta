import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/models/pop_model.dart';

class D2dCommuterModel {
  final UserId? userId;
  final PickUpPointModel? popId;
  final int? inLine;

  /// Home batch id when present on WS payload (`batchId` / `batch_id`).
  final String? homeBatchId;

  D2dCommuterModel({
    this.userId,
    this.popId,
    this.inLine,
    this.homeBatchId,
  });

  String get username => userId?.username ?? 'Unknown commuter';

  String? get mobileNumber => userId?.mobileNumber;

  int? get id => userId?.id;

  /// Parses commuter payloads from the D2D WebSocket.
  ///
  /// Supported shapes:
  /// ```json
  /// { "4": { "pickUpPoint": "...", "inLine": 1, "mobile_number": "...", "username": "...", "batchId": 2 } }
  /// ```
  /// or a flat map with `id`, `username`, `mobile_number` / `mobileNumber`.
  factory D2dCommuterModel.fromJson(Map<String, dynamic> json) {
    return D2dCommuterModel(
      userId: _parseUserId(json),
      popId: _parsePopId(json['pickUpPoint'] ?? json['popId']),
      inLine: _parseInLine(json['inLine']),
      homeBatchId: _parseBatchId(json['batchId'] ?? json['batch_id']),
    );
  }

  static String? _parseBatchId(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  static UserId? _parseUserId(Map<String, dynamic> json) {
    final nested = json['userId'];
    if (nested is Map<String, dynamic>) {
      return _userIdFromMap(nested);
    }
    if (nested is Map) {
      return _userIdFromMap(Map<String, dynamic>.from(nested));
    }
    if (nested is int) return UserId(id: nested);
    if (nested is String) return UserId(username: nested);

    final id = _parseInLine(json['id'] ?? json['user_id']);
    final username = json['username']?.toString();
    final mobile = json['mobile_number'] ?? json['mobileNumber'];

    if (id == null && username == null && mobile == null) return null;

    return UserId(
      id: id,
      username: username,
      mobileNumber: mobile?.toString(),
    );
  }

  static UserId _userIdFromMap(Map<String, dynamic> json) {
    return UserId(
      id: _parseInLine(json['id']),
      username: json['username']?.toString(),
      mobileNumber: (json['mobile_number'] ?? json['mobileNumber'])?.toString(),
    );
  }

  static PickUpPointModel? _parsePopId(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return PickUpPointModel.fromJson(value);
    if (value is Map) {
      return PickUpPointModel.fromJson(Map<String, dynamic>.from(value));
    }
    if (value is String) {
      return PickUpPointModel(pickUpPointName: value);
    }
    return null;
  }

  static int? _parseInLine(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
