import 'package:cts/api/api_result.dart';

abstract class AuthenticationRepository {
  Future<ApiResult<String>> login({
    required String mobileNumber,
    required String password,
  });

  Future<ApiResult<void>> signUp({
    required String username,
    required String mobileNumber,
    required String password,
  });

  Future<ApiResult<void>> logout();

  /// Validates stored session against server; updates local role if changed.
  /// Returns false when the session was cleared (e.g. 401).
  Future<bool> refreshSessionFromServer();
}
