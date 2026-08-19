import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_response_contract.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/features/batches/models/return_available_model.dart';
import 'package:cts/features/batches/models/return_batch_status_model.dart';
import 'package:cts/features/batches/repositories/return_batch_repository.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';

class ReturnBatchRepositoryImpl implements ReturnBatchRepository {
  ReturnBatchRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  @override
  Future<ApiResult<ReturnBatchStatusModel>> getReturnBatchStatus(
    String batchId,
  ) async {
    try {
      final response = await _apiService.getApi(
        '${ApiUrl.returnBatchStatus}$batchId',
      );
      if (response is! Map) {
        return ApiResult.failure(
          ApiExceptionHandler.handle('Invalid return batch status response'),
        );
      }
      return ApiResult.success(
        ReturnBatchStatusModel.fromJson(
          Map<String, dynamic>.from(response),
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ReturnAvailableResult>> getAvailableCommuters(
    String batchId,
  ) async {
    try {
      final response = await _apiService.getApi(
        '${ApiUrl.returnBatchView}$batchId',
      );
      if (response is! Map) {
        return ApiResult.failure(
          ApiExceptionHandler.handle('Invalid return batch view response'),
        );
      }
      return ApiResult.success(
        ReturnAvailableResult.fromJson(Map<String, dynamic>.from(response)),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ReturnBatchConfirmedResult>> getConfirmedCommuters(
    String batchId,
  ) async {
    try {
      final response = await _apiService.getApi(
        '${ApiUrl.returnBatchGetCommuter}$batchId',
      );
      if (response is! Map) {
        return ApiResult.failure(
          ApiExceptionHandler.handle('Invalid confirmed commuter response'),
        );
      }
      final map = Map<String, dynamic>.from(response);
      final listIds = map['commuter_list'];
      final confirmedUserIds = <String>{
        if (listIds is List)
          for (final id in listIds)
            if (id != null && id.toString().isNotEmpty) id.toString(),
      };
      return ApiResult.success(
        ReturnBatchConfirmedResult(
          commuters: _parseCommuterList(map, listKey: 'commuters'),
          capacity: ReturnBatchCapacityModel.fromConfirmedResponse(map),
          confirmedUserIds: confirmedUserIds,
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<String>> addCommuterToConfirmList(
    String userId,
    String batchId,
  ) async {
    try {
      final response = await _apiService.postApi(
        {'commuter_id': userId, 'batch_id': batchId},
        ApiUrl.returnBatchAddCommuter,
      );
      return ApiResponseContract.toStringResult(
        response,
        successMessage: 'Commuter confirmed',
        failureMessage: 'Could not confirm commuter for return',
        statusMessages: ApiResponseContract.returnBatchActionMessages,
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<String>> removeCommuterFromConfirmList(
    String userId,
    String batchId,
  ) async {
    try {
      final response = await _apiService.postApi(
        {'commuter_id': userId, 'batch_id': batchId},
        ApiUrl.returnBatchRemoveCommuter,
      );
      return ApiResponseContract.toStringResult(
        response,
        successMessage: 'Commuter removed',
        failureMessage: 'Could not remove commuter from return list',
        statusMessages: ApiResponseContract.returnBatchActionMessages,
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> endReturnTrip(String batchId) async {
    try {
      final response =
          await _apiService.postApi({}, '${ApiUrl.returnBatchEnd}$batchId');
      return ApiResponseContract.toVoidResult(
        response,
        failureMessage: 'Could not end return trip',
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  List<CommuterModel> _parseCommuterList(
    dynamic response, {
    required String listKey,
  }) {
    if (response is! Map) return const [];

    final list = response[listKey];
    if (list is! List) return const [];

    return list
        .map(
          (json) => CommuterModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

}
