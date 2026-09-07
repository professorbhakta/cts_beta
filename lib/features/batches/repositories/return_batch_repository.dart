import 'package:cts/api/api_result.dart';
import 'package:cts/features/batches/models/return_available_model.dart';
import 'package:cts/features/batches/models/return_batch_status_model.dart';
import 'package:cts/features/batches/models/return_intent_model.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';

abstract class ReturnBatchRepository {
  Future<ApiResult<ReturnBatchStatusModel>> getReturnBatchStatus(String batchId);

  Future<ApiResult<ReturnAvailableResult>> getAvailableCommuters(String batchId);

  Future<ApiResult<ReturnBatchConfirmedResult>> getConfirmedCommuters(
    String batchId,
  );

  Future<ApiResult<String>> addCommuterToConfirmList(
    String userId,
    String batchId,
  );

  Future<ApiResult<String>> removeCommuterFromConfirmList(
    String userId,
    String batchId,
  );

  Future<ApiResult<void>> endReturnTrip(String batchId);

  Future<ApiResult<String>> joinReturnWaiting(String userId, String batchId);

  Future<ApiResult<ReturnIntentModel>> getReturnIntent();

  Future<ApiResult<ReturnIntentModel>> setReturnIntent(ReturnIntentModel intent);

  Future<ApiResult<List<ReturnIntentOptionModel>>> getReturnIntentOptions();
}

class ReturnBatchConfirmedResult {
  const ReturnBatchConfirmedResult({
    required this.commuters,
    required this.capacity,
    this.confirmedUserIds = const {},
  });

  final List<CommuterModel> commuters;
  final ReturnBatchCapacityModel capacity;
  final Set<String> confirmedUserIds;
}
