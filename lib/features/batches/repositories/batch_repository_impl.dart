import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/repositories/batch_repository.dart';

class BatchRepositoryImpl implements BatchRepository {
  BatchRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  @override
  Future<ApiResult<List<BatchModel>>> getBatches() async {
    try {
      final adminCode = AppManager.instance.getString(ManagerKey.adminCode);
      final response = await _apiService.getApi(
        "${ApiUrl.adminBatchUrl}$adminCode",
      );

      if (response is List<dynamic>) {
        final batches = response
            .map((json) => BatchModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        return ApiResult.success(batches);
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
  Future<ApiResult<void>> createBatch(Map<String, dynamic> data) async {
    try {
      final adminCode = AppManager.instance.getString(ManagerKey.adminCode);
      final requestData = {...data, 'adminCode': adminCode};
      final response = await _apiService.postApi(requestData, ApiUrl.batchUrl);

      if (response != null) {
        if (response.toString() == "BATCH CREATED") {
          SnackBarService.showsSuccessSnackbar("BATCH CREATED", "");
        } else {
          SnackBarService.showsSuccessSnackbar(response.toString(), "error");
        }
        return ApiResult.success(null);
      } else {
        final errorMessage = response?.toString() ?? "Create Batch failed.";
        SnackBarService.showErrorSnackbar(errorMessage);
        return ApiResult.failure(
          ApiFailure(type: ApiFailureType.server, message: errorMessage),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> updateBatch(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patchApi(id, data, ApiUrl.batchUrl);

      if (response != null) {
        if (response.toString() == "BATCH UPDATED") {
          SnackBarService.showsSuccessSnackbar("BATCH UPDATED", "");
        } else {
          SnackBarService.showsSuccessSnackbar(response.toString(), "error");
        }
        return ApiResult.success(null);
      } else {
        final errorMessage = response?.toString() ?? "Update Batch failed.";
        SnackBarService.showErrorSnackbar(errorMessage);
        return ApiResult.failure(
          ApiFailure(type: ApiFailureType.parsing, message: errorMessage),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> deleteBatch(int id) async {
    try {
      final response = await _apiService.deleteApi(id, ApiUrl.batchUrl);

      if (response != null) {
        if (response.toString() == "BATCH DELETED") {
          SnackBarService.showsSuccessSnackbar("BATCH DELETED", "");
        } else {
          SnackBarService.showsSuccessSnackbar(response.toString(), "error");
        }
        return ApiResult.success(null);
      } else {
        final errorMessage = response?.toString() ?? "Delete Batch failed.";
        SnackBarService.showErrorSnackbar(errorMessage);
        return ApiResult.failure(
          ApiFailure(type: ApiFailureType.parsing, message: errorMessage),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }
}
