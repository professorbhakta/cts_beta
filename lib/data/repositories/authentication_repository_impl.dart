import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/device_utils.dart';
import 'package:cts/domain/repositories/authentication_repository.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  AuthenticationRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  @override
  Future<ApiResult<String>> login({
    required String mobileNumber,
    required String password,
  }) async {
    try {
      final loginData = {"mobileNumber": mobileNumber, "password": password};

      final loginResponse = await _apiService.postApi(
        loginData,
        ApiUrl.loginUrl,
      );

      // Enhanced error handling for login response
      if (loginResponse is! Map<String, dynamic>) {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: "Invalid login response format from server.",
          ),
        );
      }

      final userId = loginResponse['user_id']?.toString();
      final userType = loginResponse['user_type']?.toString().trim();

      if (userId == null ||
          userType == null ||
          userId.isEmpty ||
          userType.isEmpty) {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: "Invalid login response: missing user_id or user_type.",
          ),
        );
      }

      final genericProfileResponse = await _apiService.getApi(
        "${ApiUrl.userUrl}/$userId",
      );
      if (genericProfileResponse is! Map<String, dynamic>) {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: "Invalid generic profile data format.",
          ),
        );
      }

      _saveGenericUserData(genericProfileResponse);

      final String roleProfileUrl = _getRoleProfileUrl(userType, userId);
      if (roleProfileUrl.isNotEmpty) {
        final roleProfileResponse = await _apiService.getApi(roleProfileUrl);
        if (roleProfileResponse is! Map<String, dynamic>) {
          return ApiResult.failure(
            ApiFailure(
              type: ApiFailureType.parsing,
              message:
                  "Invalid role-specific profile data format for user type: $userType",
            ),
          );
        }
        _saveRoleSpecificData(userType, roleProfileResponse);
      }

      AppManager.instance.setBool(ManagerKey.isLogin, true);
      AppManager.instance.setString(ManagerKey.userType, userType);
      AppManager.instance.setString(ManagerKey.userId, userId);

      return ApiResult.success(userType);
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> signUp({
    required String username,
    required String mobileNumber,
    required String password,
  }) async {
    try {
      // Get actual device ID
      final deviceId = await DeviceUtils.getDeviceId();

      final registrationData = {
        'user': {
          "userType": "ADMIN",
          "username": username,
          "mobileNumber": mobileNumber,
          "password": password,
          "address": "", // Address can be updated later in profile
          "deviceId": deviceId,
        },
        "user_data": {},
      };

      final response = await _apiService.postApi(
        registrationData,
        "${ApiUrl.userUrl}/",
      );

      if (response != null && response.toString().contains("admin created")) {
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message:
                response?.toString() ??
                "Registration failed. No response from server.",
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      await _apiService.postApi({}, ApiUrl.logoutUrl);
      await AppManager.instance.clearSharedPreferences();
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  String _getRoleProfileUrl(String userType, String userId) {
    switch (userType) {
      case 'COMMUTER':
        return "${ApiUrl.commuterUrl}/$userId";
      case 'DRIVER':
        return "${ApiUrl.driverUrl}/$userId";
      case 'ADMIN':
        return "${ApiUrl.adminUrl}$userId";
      default:
        return "";
    }
  }

  void _saveGenericUserData(Map<String, dynamic> userData) {
    AppManager.instance.setString(
      ManagerKey.userName,
      userData["username"] ?? '',
    );
    AppManager.instance.setString(
      ManagerKey.mobile,
      userData["mobileNumber"]?.toString() ?? '',
    );
    AppManager.instance.setString(
      ManagerKey.address,
      userData["address"]?.toString() ?? '',
    );
    AppManager.instance.setBool(
      ManagerKey.hasPaid,
      userData["hasPaid"] ?? false,
    );
  }

  void _saveRoleSpecificData(
    String userType,
    Map<String, dynamic> profileData,
  ) {
    switch (userType) {
      case 'COMMUTER':
        AppClass.userType = 1;
        AppManager.instance.setString(
          ManagerKey.batchId,
          profileData["batchId"]?["id"]?.toString() ?? '',
        );
        AppManager.instance.setString(
          ManagerKey.batchName,
          profileData["batchId"]?["batchName"]?.toString() ?? '',
        );
        AppManager.instance.setString(
          ManagerKey.batchTime,
          profileData["batchId"]?["batchTime"]?.toString() ?? '',
        );
        AppManager.instance.setString(
          ManagerKey.cabId,
          profileData["cabId"]?["id"]?.toString() ?? '',
        );
        AppManager.instance.setString(
          ManagerKey.cabNumb,
          profileData["cabId"]?["regNumber"]?.toString() ?? '',
        );
        AppManager.instance.setString(
          ManagerKey.isComing,
          profileData["isComing"]?.toString() ?? 'false',
        );
        break;
      case 'DRIVER':
        AppClass.userType = 2;
        AppManager.instance.setString(
          ManagerKey.batchId,
          profileData["batchId"]?["id"]?.toString() ?? '',
        );
        AppManager.instance.setString(
          ManagerKey.batchName,
          profileData["batchId"]?["batchName"]?.toString() ?? '',
        );
        AppManager.instance.setString(
          ManagerKey.batchTime,
          profileData["batchId"]?["batchTime"]?.toString() ?? '',
        );
        AppManager.instance.setString(
          ManagerKey.cabId,
          profileData["cabId"]?["id"]?.toString() ?? '',
        );
        AppManager.instance.setString(
          ManagerKey.cabNumb,
          profileData["cabId"]?["regNumber"]?.toString() ?? '',
        );
        break;
      case 'ADMIN':
        AppClass.userType = 3;
        AppManager.instance.setString(
          ManagerKey.adminCode,
          profileData["id"]?.toString() ?? '',
        );
        break;
    }
  }
}
