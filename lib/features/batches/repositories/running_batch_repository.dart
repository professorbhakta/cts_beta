import 'package:cts/api/api_result.dart';
import 'package:cts/features/batches/models/batch_model.dart';

/// Snapshot of live morning DTODLOG rows. Not used for evening return trips.
abstract class RunningBatchRepository {
  Future<ApiResult<List<RunningBatches>>> fetchRunningBatches();
}
