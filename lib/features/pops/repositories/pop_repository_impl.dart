import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/api/base_api_services.dart';
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

      if (response != null && response.toString() == 'PICK UP POINT CREATED') {
        return ApiResult.success(null);
      }

      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.server,
          message: response?.toString() ?? 'Create pick-up point failed.',
        ),
      );
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

      if (response != null && response.toString() == 'PICK UP POINT UPDATED') {
        return ApiResult.success(null);
      }

      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.server,
          message: response?.toString() ?? 'Update pick-up point failed.',
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> deletePop(int id) async {
    try {
      final response = await _apiService.deleteApi(id, ApiUrl.pickUpPointUrl);

      if (response != null &&
          response.toString().toUpperCase().contains('DELETED')) {
        return ApiResult.success(null);
      }

      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.server,
          message: response?.toString() ?? 'Delete pick-up point failed.',
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }
}
