import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/features/admin_bootstrap/admin_bootstrap_list_source.dart';
import 'package:cts/features/admin_bootstrap/mappers/admin_bootstrap_list_mapper.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/repositories/batch_repository.dart';

class BatchRepositoryImpl implements BatchRepository {
  BatchRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  @override
  Future<ApiResult<List<BatchModel>>> getBatches() async {
    final luggage = await AdminBootstrapListSource.ensureLuggage();
    if (luggage != null) {
      return ApiResult.success(AdminBootstrapListMapper.batches(luggage));
    }
    return ApiResult.failure(AdminBootstrapListSource.catalogUnavailableFailure());
  }

  @override
  Future<ApiResult<void>> createBatch(Map<String, dynamic> data) async {
    try {
      final adminCode = AppManager.instance.getString(ManagerKey.adminCode);
      final requestData = {...data, 'adminCode': adminCode};
      final response = await _apiService.postApi(requestData, ApiUrl.batchUrl);

      if (response != null && response.toString() == 'BATCH CREATED') {
        AdminBootstrapListSource.refreshInBackground();
        return ApiResult.success(null);
      }

      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.server,
          message: response?.toString() ?? 'Create batch failed.',
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> updateBatch(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.patchApi(id, data, ApiUrl.batchUrl);

      if (response != null && response.toString() == 'BATCH UPDATED') {
        AdminBootstrapListSource.refreshInBackground();
        return ApiResult.success(null);
      }

      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.server,
          message: response?.toString() ?? 'Update batch failed.',
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> deleteBatch(int id) async {
    try {
      final response = await _apiService.deleteApi(id, ApiUrl.batchUrl);

      if (response != null &&
          response.toString().toUpperCase().contains('DELETED')) {
        AdminBootstrapListSource.refreshInBackground();
        return ApiResult.success(null);
      }

      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.server,
          message: response?.toString() ?? 'Delete batch failed.',
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }
}
