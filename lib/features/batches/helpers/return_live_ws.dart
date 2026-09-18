/// Return live WebSocket helpers (Step 5). Path: `ws/return/<batchId>/` —
/// NOT morning `ws/<batchId>/`.
library;

import 'package:cts/features/batches/models/return_batch_status_model.dart';

/// [wsBaseUrl] is AppConfig.webSocketUrl (already ends with `/ws/`).
String buildReturnLiveWsUrl({
  required String wsBaseUrl,
  required String batchId,
}) {
  final base = wsBaseUrl.endsWith('/') ? wsBaseUrl : '$wsBaseUrl/';
  final id = batchId.trim();
  return '${base}return/$id/';
}

class ReturnLiveWsPayload {
  const ReturnLiveWsPayload({
    required this.status,
    this.event,
    this.leg = 'return',
  });

  final ReturnBatchStatusModel status;
  final String? event;
  final String leg;

  bool get isEnded =>
      status.isActive == false || (event?.toLowerCase() == 'ended');

  bool get shouldRefreshLists {
    final e = event?.toLowerCase();
    return e == 'added' ||
        e == 'already_confirmed' ||
        e == 'removed';
  }

  /// Parses envelope `{"result": { ...status fields..., "leg", "event"? }}`.
  static ReturnLiveWsPayload? tryParse(dynamic decoded) {
    if (decoded is! Map) return null;
    final root = Map<String, dynamic>.from(decoded);
    final rawResult = root['result'];
    if (rawResult is! Map) return null;
    final result = Map<String, dynamic>.from(rawResult);
    final event = (result['event'] ?? root['event'])?.toString();
    final leg = result['leg']?.toString() ?? 'return';
    final status = ReturnBatchStatusModel.fromJson(result);
    return ReturnLiveWsPayload(status: status, event: event, leg: leg);
  }
}
