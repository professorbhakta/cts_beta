import 'package:cts/core/network/api_exceptions_handler.dart';
import 'package:cts/core/network/api_list.dart';
import 'package:cts/core/network/api_result.dart';
import 'package:cts/core/network/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/features/drivers/domain/repositories/driver_repository.dart';
import 'package:cts/features/drivers/domain/models/driver_model.dart';

class DriverRepositoryImpl implements DriverRepository {
  DriverRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  @override
  Future<ApiResult<List<DriverModel>>> getDrivers() async {
    try {
      final adminCode = AppManager.instance.getString(ManagerKey.adminCode);
      final response = await _apiService.getApi(
        "${ApiUrl.adminDriverUrl}$adminCode",
      );

      if (response is List<dynamic>) {
        final drivers = response
            .map(
              (json) => DriverModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
        return ApiResult.success(drivers);
      } else {
        return ApiResult.failure(
          ApiExceptionHandler.handle('Invalid response format'),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<DriverModel>> getDriverProfile() async {
    try {
      final userId = AppManager.instance.getString(ManagerKey.userId);
      final response = await _apiService.getApi("${ApiUrl.driverUrl}/$userId");
      final driver = DriverModel.fromJson(response);
      return ApiResult.success(driver);
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> createDriver(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.postApi(data, ApiUrl.cndUserUrl);
      if (response is Map<String, dynamic>) {
        //driver created
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: response?.toString() ?? "Create Driver failed.",
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> updateDriver(
    int id,
    Map<String, dynamic> userData,
    Map<String, dynamic> driverData,
  ) async {
    try {
      final driverUserResponse = await _apiService.patchApi(
        id,
        userData,
        ApiUrl.userUrl,
      );
      final driverUpdate = await _apiService.patchApi(
        id,
        driverData,
        ApiUrl.driverUrl,
      );

      if (driverUserResponse != null && driverUpdate != null) {
        return ApiResult.success(null);
      }
      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.parsing,
          message: driverUserResponse?.toString() ?? "Update Driver failed.",
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> deleteDriver(int id) async {
    try {
      final response = await _apiService.deleteApi(id, ApiUrl.userUrl);
      if (response != null && response.toString().contains("DELETED")) {
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: response?.toString() ?? "Delete Driver failed.",
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  // END INSERTION HERE
}
