import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/session_manager.dart';
import 'package:cts/domain/repositories/authentication_repository.dart';
import 'package:cts/features/auth/models/login_response.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  AuthenticationRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  @override
  Future<ApiResult<String>> login({
    required String mobileNumber,
    required String password,
  }) async {
    try {
      final loginData = {
        'mobileNumber': mobileNumber,
        'password': password,
      };

      final loginResponse = await _apiService.postApi(
        loginData,
        ApiUrl.loginUrl,
      );

      if (loginResponse is! Map) {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: 'Invalid login response format from server.',
          ),
        );
      }

      final LoginResponse parsed;
      try {
        parsed = LoginResponse.fromJson(
          Map<String, dynamic>.from(loginResponse),
        );
      } on FormatException catch (e) {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: e.message,
          ),
        );
      }

      await SessionManager().setTokens(
        access: parsed.access,
        refresh: parsed.refresh,
      );

      _persistLoginUser(parsed);

      return ApiResult.success(parsed.user.userType);
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  /// Persist required Phase A user fields. Empty org arrays / null profile
  /// stubs are ignored safely (no crash, no extra table fetches).
  void _persistLoginUser(LoginResponse parsed) {
    final user = parsed.user;

    AppManager.instance.setBool(ManagerKey.isLogin, true);
    AppManager.instance.setString(ManagerKey.userType, user.userType);
    AppManager.instance.setString(ManagerKey.userId, user.id);
    AppManager.instance.setString(ManagerKey.userName, user.username);
    AppManager.instance.setString(ManagerKey.mobile, user.mobileNumber);
    AppManager.instance.setString(ManagerKey.email, user.email ?? '');
    AppManager.instance.setBool(ManagerKey.hasPaid, user.hasPaid);
    if (user.deviceId != null && user.deviceId!.isNotEmpty) {
      AppManager.instance.setString(ManagerKey.deviceId, user.deviceId!);
    }

    final adminCode = _stringifyAdminCode(parsed.adminCode);
    if (adminCode != null && adminCode.isNotEmpty) {
      AppManager.instance.setString(ManagerKey.adminCode, adminCode);
    }

    // Optional profile stub may carry role hints without requiring secondary GETs.
    final profile = parsed.profile;
    if (profile != null && profile.isNotEmpty) {
      _applyOptionalProfileStub(user.userType, profile);
    }

    _syncAppClassUserType(user.userType);
  }

  String? _stringifyAdminCode(dynamic adminCode) {
    if (adminCode == null) return null;
    if (adminCode is String || adminCode is num) {
      return adminCode.toString();
    }
    if (adminCode is Map) {
      final id = adminCode['id'] ?? adminCode['adminCode'];
      return id?.toString();
    }
    return adminCode.toString();
  }

  void _applyOptionalProfileStub(
    String userType,
    Map<String, dynamic> profileData,
  ) {
    switch (userType) {
      case 'COMMUTER':
      case 'DRIVER':
        final batch = profileData['batchId'];
        if (batch is Map) {
          AppManager.instance.setString(
            ManagerKey.batchId,
            batch['id']?.toString() ?? '',
          );
          AppManager.instance.setString(
            ManagerKey.batchName,
            batch['batchName']?.toString() ?? '',
          );
          AppManager.instance.setString(
            ManagerKey.batchTime,
            batch['batchTime']?.toString() ?? '',
          );
        }
        final cab = profileData['cabId'];
        if (cab is Map) {
          AppManager.instance.setString(
            ManagerKey.cabId,
            cab['id']?.toString() ?? '',
          );
          AppManager.instance.setString(
            ManagerKey.cabNumb,
            cab['regNumber']?.toString() ?? '',
          );
        }
        if (userType == 'COMMUTER' && profileData.containsKey('isComing')) {
          AppManager.instance.setString(
            ManagerKey.isComing,
            profileData['isComing']?.toString() ?? 'false',
          );
        }
        // Nested subAdmin UUID (Add Commuter sheet); top-level adminCode
        // from the login envelope is already stored in _persistLoginUser.
        final nestedAdmin = profileData['adminCode'];
        if (nestedAdmin is Map) {
          final nestedId = nestedAdmin['id']?.toString();
          if (nestedId != null && nestedId.isNotEmpty) {
            AppManager.instance.setString(ManagerKey.adminCode, nestedId);
          }
        }
        break;
      case 'ADMIN':
      case 'SUPERVISOR':
      case 'STAFF':
        final id = profileData['id']?.toString();
        if (id != null && id.isNotEmpty) {
          AppManager.instance.setString(ManagerKey.adminCode, id);
        }
        break;
    }
  }

  @override
  Future<bool> refreshSessionFromServer() async {
    final userId = AppManager.instance.getString(ManagerKey.userId);
    if (userId.isEmpty || userId == '0') return false;

    try {
      final response = await _apiService.getApi("${ApiUrl.userUrl}/$userId");
      if (response is! Map) return true;

      final map = Map<String, dynamic>.from(response);
      final serverType = map['userType']?.toString().trim();
      if (serverType == null || serverType.isEmpty) return true;

      final localType = AppManager.instance.getString(ManagerKey.userType);
      if (localType != serverType) {
        AppManager.instance.setString(ManagerKey.userType, serverType);
        _syncAppClassUserType(serverType);
      }
      return true;
    } catch (e) {
      final failure = ApiExceptionHandler.handle(e);
      if (failure.type == ApiFailureType.unauthorized) {
        return false;
      }
      return true;
    }
  }

  void _syncAppClassUserType(String userType) {
    AppClass.userType = switch (userType) {
      'COMMUTER' => 1,
      'DRIVER' => 2,
      'ADMIN' => 3,
      'SUPERVISOR' => 4,
      'STAFF' => 5,
      _ => 0,
    };
  }

  @override
  Future<ApiResult<void>> signUp({
    required String username,
    required String mobileNumber,
    required String password,
  }) async {
    // Public self-registration is disabled. Admins, drivers, and commuters
    // are created by an existing admin (CRUD). Do not send userType: ADMIN.
    return ApiResult.failure(
      ApiFailure(
        type: ApiFailureType.invalidRequest,
        message:
            'Public registration is disabled. Ask your administrator to create an account.',
      ),
    );
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      await _apiService.postApi({}, ApiUrl.logoutUrl);
    } catch (_) {
      // Always clear locally so a failed POST cannot trap the user in-app.
    } finally {
      await AppManager.instance.clearLocalSession();
    }
    return ApiResult.success(null);
  }
}
