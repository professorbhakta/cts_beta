import 'package:cts/api/api_result.dart';

/// Normalized outcome parsed from a JSON API body (may arrive on HTTP 200 or 4xx).
enum ApiResponseOutcome {
  success,
  businessError,
}

/// Central contract for `{status, message, code}` (and common aliases) across modules.
///
/// Fail-closed rules:
/// - Explicit failure statuses (`error`, `fail`, …) → [ApiResponseOutcome.businessError]
/// - Unknown non-success `status` values → business error with safe fallback message
/// - `error` / `non_field_errors` keys → business error unless `status` is a known success
class ApiResponseContract {
  const ApiResponseContract({
    required this.outcome,
    this.status,
    this.code,
    required this.message,
  });

  final ApiResponseOutcome outcome;
  final String? status;
  final String? code;
  final String message;

  bool get isSuccess => outcome == ApiResponseOutcome.success;
  bool get isFailure => outcome == ApiResponseOutcome.businessError;

  /// Lowercase tokens treated as success across backend modules.
  static const successStatuses = {
    'ok',
    'success',
    'added',
    'removed',
    'ended',
    'already_confirmed',
  };

  /// Lowercase tokens treated as explicit business failure.
  static const failureStatuses = {
    'error',
    'fail',
    'failed',
    'failure',
  };

  /// Return-batch POST action messages keyed by success `status`.
  static const returnBatchActionMessages = {
    'added': 'Commuter confirmed for return',
    'removed': 'Commuter removed from return list',
    'already_confirmed': 'Commuter is already confirmed',
    'ended': 'Return trip ended',
  };

  /// Parse a response body into a normalized contract.
  static ApiResponseContract parse(
    dynamic body, {
    String successMessage = 'Operation completed successfully.',
    String failureMessage = 'The request could not be completed.',
    Map<String, String> statusMessages = const {},
  }) {
    if (body is! Map) {
      return ApiResponseContract(
        outcome: ApiResponseOutcome.success,
        message: successMessage,
      );
    }

    final map = Map<String, dynamic>.from(body);
    final status = _readString(map, const ['status', 'result', 'state']);
    final code = _readCode(map);
    final extracted = extractMessage(map);
    final normalizedStatus = status?.toLowerCase();

    if (_isBusinessFailure(map, normalizedStatus, code)) {
      return ApiResponseContract(
        outcome: ApiResponseOutcome.businessError,
        status: status,
        code: code,
        message: _nonEmpty(extracted) ?? failureMessage,
      );
    }

    if (normalizedStatus != null &&
        !successStatuses.contains(normalizedStatus)) {
      return ApiResponseContract(
        outcome: ApiResponseOutcome.businessError,
        status: status,
        code: code,
        message: _nonEmpty(extracted) ?? failureMessage,
      );
    }

    final mapped =
        normalizedStatus != null ? statusMessages[normalizedStatus] : null;

    return ApiResponseContract(
      outcome: ApiResponseOutcome.success,
      status: status,
      code: code,
      message: mapped ?? _nonEmpty(extracted) ?? successMessage,
    );
  }

  /// Map body → [ApiResult<String>] for action endpoints that surface a message.
  static ApiResult<String> toStringResult(
    dynamic body, {
    required String successMessage,
    String failureMessage = 'The request could not be completed.',
    Map<String, String> statusMessages = const {},
  }) {
    final contract = parse(
      body,
      successMessage: successMessage,
      failureMessage: failureMessage,
      statusMessages: statusMessages,
    );
    if (contract.isFailure) {
      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.invalidRequest,
          message: contract.message,
          code: contract.code,
        ),
      );
    }
    return ApiResult.success(contract.message);
  }

  /// Map body → [ApiResult<void>] for void action endpoints.
  static ApiResult<void> toVoidResult(
    dynamic body, {
    String successMessage = 'Operation completed successfully.',
    String failureMessage = 'The request could not be completed.',
  }) {
    final contract = parse(
      body,
      successMessage: successMessage,
      failureMessage: failureMessage,
    );
    if (contract.isFailure) {
      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.invalidRequest,
          message: contract.message,
          code: contract.code,
        ),
      );
    }
    return ApiResult.success(null);
  }

  /// Best-effort user-facing message from common backend keys.
  static String? extractMessage(Map<String, dynamic> map) {
    final direct = _readString(map, const ['message', 'msg', 'detail']);
    if (direct != null) return direct;

    final errorValue = map['error'];
    if (errorValue is String && errorValue.isNotEmpty) {
      return errorValue;
    }
    if (errorValue != null && errorValue.toString().isNotEmpty) {
      return errorValue.toString();
    }

    final code = _readCode(map);
    if (code != null && code != map['status']?.toString()) {
      return code;
    }

    return null;
  }

  static bool _isBusinessFailure(
    Map<String, dynamic> map,
    String? normalizedStatus,
    String? code,
  ) {
    if (normalizedStatus != null &&
        failureStatuses.contains(normalizedStatus)) {
      return true;
    }

    if (map.containsKey('non_field_errors')) {
      return true;
    }

    if (_hasFieldValidationErrors(map)) {
      return true;
    }

    if (code != null &&
        normalizedStatus != null &&
        !successStatuses.contains(normalizedStatus)) {
      return true;
    }

    if (code != null && normalizedStatus == null && map.containsKey('error')) {
      return true;
    }

    return false;
  }

  static bool _hasFieldValidationErrors(Map<String, dynamic> map) {
    const skipKeys = {
      'status',
      'result',
      'state',
      'message',
      'msg',
      'detail',
      'error',
      'code',
      'error_code',
      'errorCode',
    };
    for (final entry in map.entries) {
      if (skipKeys.contains(entry.key)) continue;
      // Django REST field errors are string lists, e.g. {"isComing": ["..."]}.
      if (entry.value is List && (entry.value as List).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  static String? _readCode(Map<String, dynamic> map) {
    final code = _readString(map, const ['code', 'error_code', 'errorCode']);
    if (code != null) return code;

    final errorValue = map['error'];
    if (errorValue is String && errorValue.isNotEmpty) {
      return errorValue;
    }
    return null;
  }

  static String? _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  static String? _nonEmpty(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
