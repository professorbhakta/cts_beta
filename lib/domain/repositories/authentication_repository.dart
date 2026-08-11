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
}
