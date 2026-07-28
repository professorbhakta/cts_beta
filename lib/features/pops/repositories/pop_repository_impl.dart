import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/features/pops/repositories/pop_repository.dart';
import 'package:cts/models/pop_model.dart';

class PopRepositoryImpl implements PopRepository {
  PopRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  @override
  Future<ApiResult<List<PickUpPointModel>>> getPops() async {
    try {
      final adminCode = AppManager.instance.getString(ManagerKey.adminCode);
      final response = await _apiService.getApi(
        "${ApiUrl.adminPickUpPointUrl}$adminCode",
      );

      if (response is List<dynamic>) {
        final pops = response
            .map(
              (json) =>
                  PickUpPointModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
        return ApiResult.success(pops);
      } else {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: 'Invalid response format',
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> createPop(Map<String, dynamic> data) async {
    try {
      final adminCode = AppManager.instance.getString(ManagerKey.adminCode);
      final requestData = {...data, 'adminCode': adminCode};

      final response = await _apiService.postApi(
        requestData,
        ApiUrl.pickUpPointUrl,
      );

      if (response != null) {
        // Check if response is "PICK UP POINT CREATED" - this means success
        if (response.toString() == "PICK UP POINT CREATED") {
          SnackBarService.showsSuccessSnackbar(
            "Pick-up point created successfully!",
            "",
          );
          return ApiResult.success(null);
        } else {
          // If response is not "PICK UP POINT CREATED", treat as error
          return ApiResult.failure(
            ApiFailure(
              type: ApiFailureType.server,
              message: response.toString(),
            ),
          );
        }
      } else {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: response?.toString() ?? "Create POP failed.",
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> updatePop(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patchApi(
        id,
        data,
        ApiUrl.pickUpPointUrl,
      );
      // Check if response is "PICK UP POINT UPDATED" - this means success
      if (response != null && response.toString() == "PICK UP POINT UPDATED") {
        SnackBarService.showsSuccessSnackbar(
          "Pick-up point updated successfully!",
          "",
        );
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.server,
            message: response?.toString() ?? "Update pick-up point failed.",
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> deletePop(int id) async {
    try {
      final response = await _apiService.deleteApi(id, ApiUrl.pickUpPointUrl);
      // Check if response contains "DELETED" (case-insensitive)
      if (response != null) {
        final responseStr = response.toString().toUpperCase();
        if (responseStr.contains("DELETED")) {
          SnackBarService.showsSuccessSnackbar(
            "Pick-up point deleted successfully!",
            "",
          );
          return ApiResult.success(null);
        } else {
          return ApiResult.failure(
            ApiFailure(
              type: ApiFailureType.server,
              message: response.toString(),
            ),
          );
        }
      } else {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: "Delete pick-up point failed. No response from server.",
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }
}

