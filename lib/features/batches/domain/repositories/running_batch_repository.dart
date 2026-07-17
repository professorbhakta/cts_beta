import 'package:cts/api/api_result.dart';
import 'package:cts/features/batches/domain/models/batch_model.dart';

/// Abstract interface for polling / streaming live running batches.
abstract class RunningBatchRepository {
  Future<ApiResult<List<RunningBatches>>> fetchRunningBatches();

  Stream<ApiResult<List<RunningBatches>>> watchRunningBatches({
    Duration interval = const Duration(seconds: 20),
  });
}
