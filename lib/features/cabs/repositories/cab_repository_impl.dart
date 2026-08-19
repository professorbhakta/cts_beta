import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/features/cabs/repositories/cab_repository.dart';
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

      if (response != null && response.toString() == 'CAB CREATED') {
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
