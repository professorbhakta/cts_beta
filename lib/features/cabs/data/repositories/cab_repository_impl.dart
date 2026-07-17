import 'package:cts/core/network/api_exceptions_handler.dart';
import 'package:cts/core/network/api_list.dart';
import 'package:cts/core/network/api_result.dart';
import 'package:cts/core/network/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/features/cabs/domain/repositories/cab_repository.dart';
import 'package:cts/models/cab_model.dart';

class CabRepositoryImpl implements CabRepository {
  CabRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  @override
  Future<ApiResult<List<CabModel>>> getCabs() async {
    try {
      final adminCode = AppManager.instance.getString(ManagerKey.adminCode);
      final response = await _apiService.getApi(
        "${ApiUrl.adminCabUrl}$adminCode",
      );

      if (response is List<dynamic>) {
        final cabs = response
            .map((json) => CabModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        return ApiResult.success(cabs);
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
  Future<ApiResult<void>> createCab(Map<String, dynamic> data) async {
    final adminCode = AppManager.instance.getString(ManagerKey.adminCode);
    final requestData = {...data, 'adminCode': adminCode};

    try {
      final response = await _apiService.postApi(requestData, ApiUrl.cabUrl);

      if (response != null) {
        if (response.toString() == "CAB CREATED") {
          SnackBarService.showsSuccessSnackbar("CAB CREATED", "");
        } else {
          SnackBarService.showsSuccessSnackbar(response.toString(), "ERROR");
        }
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: response?.toString() ?? "Create Cab failed.",
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  // START INSERTION HERE
  @override
  Future<ApiResult<void>> updateCab(int id, Map<String, dynamic> data) async {
    final adminCode = AppManager.instance.getString(ManagerKey.adminCode);
    final requestData = {...data, 'adminCode': adminCode};
    try {
      final response = await _apiService.patchApi(
        id,
        requestData,
        ApiUrl.cabUrl,
      );
      // Check for a success response, assuming it's a Map for updates
      if (response != null) {
        if (response.toString() == "CAB UPDATED") {
          SnackBarService.showsSuccessSnackbar("CAB UPDATED", "");
        } else {
          SnackBarService.showsSuccessSnackbar(response.toString(), "Error");
        }

        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: response?.toString() ?? "Update Cab failed.",
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> deleteCab(int id) async {
    try {
      final response = await _apiService.deleteApi(id, ApiUrl.cabUrl);
      // Check for a success message, assuming it's a string for deletes
      if (response != null ) {
        if(response.toString() == "CAB DELETED"){
          SnackBarService.showsSuccessSnackbar("CAB DELETED", "");
        }else{
          SnackBarService.showsSuccessSnackbar(response.toString(), "Error");
        }

        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: response?.toString() ?? "Delete Cab failed.",
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  // END INSERTION HERE
}

