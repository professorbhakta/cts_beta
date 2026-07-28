import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/features/batches/repositories/return_batch_repository.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';

class ReturnBatchRepositoryImpl implements ReturnBatchRepository {
  ReturnBatchRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  @override
  Future<ApiResult<List<CommuterModel>>> getReturnCommuters(
    String batchId,
  ) async {
    try {
      final response = await _apiService.getApi(
        "${ApiUrl.returnBatchGetCommuter}/$batchId",
      );
      if (response is List<dynamic>) {
        final commuters = response
            .map(
              (json) => CommuterModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
        return ApiResult.success(commuters);
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
  Future<ApiResult<void>> addCommuterToConfirmList(
    String commuterId,
    String batchId,
  ) async {
    try {
      final data = {"commuter_id": commuterId, "batch_id": batchId};
      await _apiService.postApi(data, ApiUrl.returnBatchAddCommuter);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<List<CommuterModel>>> getConfirmedCommuters(
    String batchId,
  ) async {
    try {
      final response = await _apiService.getApi(
        "${ApiUrl.commuterUrl}/$batchId",
      );
      if (response is List<dynamic>) {
        final commuters = response
            .map(
              (json) => CommuterModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
        return ApiResult.success(commuters);
      } else {
        return ApiResult.failure(
          ApiExceptionHandler.handle('Invalid response format'),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }
}
