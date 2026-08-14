import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';

class D2dRepositoryImpl implements D2dRepository {
  D2dRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  @override
  Future<ApiResult<D2dTripStatus>> getLogStatus(String batchId) async {
    try {
      final response = await _apiService.getApi(
        '${ApiUrl.d2dLogStatus}$batchId',
      );

      if (response is! Map) {
        return ApiResult.success(D2dTripStatus.none);
      }

      final map = Map<String, dynamic>.from(response);
      final status = map['status']?.toString();
      final isActive = map['is_active'] == true;

      if (status == 'ended' || !isActive) {
        return ApiResult.success(D2dTripStatus.ended);
      }
      return ApiResult.success(D2dTripStatus.active);
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }
}
