import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_response_contract.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/features/batches/models/return_available_model.dart';
import 'package:cts/features/batches/models/return_batch_status_model.dart';
import 'package:cts/features/batches/models/return_intent_model.dart';
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

  @override
  Future<ApiResult<ReturnIntentModel>> getReturnIntent() async {
    try {
      final response = await _apiService.getApi(ApiUrl.returnBatchIntent);
      if (response is! Map) {
        return ApiResult.failure(
          ApiExceptionHandler.handle('Invalid return intent response'),
        );
      }
      final map = Map<String, dynamic>.from(response);
      final contract = ApiResponseContract.parse(
        map,
        failureMessage: 'Could not load return intent',
      );
      if (contract.isFailure) {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.invalidRequest,
            message: contract.message,
          ),
        );
      }
      return ApiResult.success(ReturnIntentModel.fromJson(map));
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ReturnIntentModel>> setReturnIntent(
    ReturnIntentModel intent,
  ) async {
    try {
      final response = await _apiService.postApi(
        intent.toPostBody(),
        ApiUrl.returnBatchIntent,
      );
      if (response is! Map) {
        return ApiResult.failure(
          ApiExceptionHandler.handle('Invalid return intent save response'),
        );
      }
      final map = Map<String, dynamic>.from(response);
      final contract = ApiResponseContract.parse(
        map,
        failureMessage: 'Could not save return intent',
      );
      if (contract.isFailure) {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.invalidRequest,
            message: contract.message,
          ),
        );
      }
      return ApiResult.success(ReturnIntentModel.fromJson(map));
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<List<ReturnIntentOptionModel>>>
      getReturnIntentOptions() async {
    try {
      final response =
          await _apiService.getApi(ApiUrl.returnBatchIntentOptions);
      if (response is! Map) {
        return ApiResult.failure(
          ApiExceptionHandler.handle('Invalid return intent options response'),
        );
      }
      final map = Map<String, dynamic>.from(response);
      final status = map['status']?.toString().toLowerCase();
      if (status == 'error' || status == 'fail' || status == 'failed') {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.invalidRequest,
            message: map['message']?.toString() ??
                'Could not load earlier return options',
          ),
        );
      }
      final raw = map['options'];
      if (raw is! List) {
        return ApiResult.success(const []);
      }
      final options = <ReturnIntentOptionModel>[];
      for (final item in raw) {
        if (item is! Map) continue;
        final option = ReturnIntentOptionModel.fromJson(
          Map<String, dynamic>.from(item),
        );
        if (option.id.isNotEmpty) options.add(option);
      }
      return ApiResult.success(options);
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
