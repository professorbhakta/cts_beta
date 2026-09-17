import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/features/admin_bootstrap/admin_bootstrap_list_source.dart';
import 'package:cts/features/admin_bootstrap/mappers/admin_bootstrap_list_mapper.dart';
import 'package:cts/features/cabs/repositories/cab_repository.dart';
import 'package:cts/models/cab_model.dart';

class CabRepositoryImpl implements CabRepository {
  CabRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  @override
  Future<ApiResult<List<CabModel>>> getCabs() async {
    final luggage = await AdminBootstrapListSource.ensureLuggage();
    if (luggage != null) {
      return ApiResult.success(AdminBootstrapListMapper.cabs(luggage));
    }
    return ApiResult.failure(AdminBootstrapListSource.catalogUnavailableFailure());
  }

  @override
  Future<ApiResult<void>> createCab(Map<String, dynamic> data) async {
    final adminCode = AppManager.instance.getString(ManagerKey.adminCode);
    final requestData = {...data, 'adminCode': adminCode};

    try {
      final response = await _apiService.postApi(requestData, ApiUrl.cabUrl);

      if (response != null && response.toString() == 'CAB CREATED') {
        AdminBootstrapListSource.refreshInBackground();
        return ApiResult.success(null);
      }

      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.server,
          message: response?.toString() ?? 'Create cab failed.',
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

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

      if (response != null && response.toString() == 'CAB UPDATED') {
        AdminBootstrapListSource.refreshInBackground();
        return ApiResult.success(null);
      }

      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.server,
          message: response?.toString() ?? 'Update cab failed.',
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> deleteCab(int id) async {
    try {
      final response = await _apiService.deleteApi(id, ApiUrl.cabUrl);

      if (response != null &&
          response.toString().toUpperCase().contains('DELETED')) {
        AdminBootstrapListSource.refreshInBackground();
        return ApiResult.success(null);
      }

      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.server,
          message: response?.toString() ?? 'Delete cab failed.',
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }
}
