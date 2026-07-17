import 'package:cts/api/api_result.dart';
import 'package:cts/features/commuters/domain/models/commuter_model.dart';

abstract class ReturnBatchRepository {
  Future<ApiResult<List<CommuterModel>>> getReturnCommuters(String batchId);
  Future<ApiResult<void>> addCommuterToConfirmList(
    String commuterId,
    String batchId,
  );
  Future<ApiResult<List<CommuterModel>>> getConfirmedCommuters(String batchId);
}
