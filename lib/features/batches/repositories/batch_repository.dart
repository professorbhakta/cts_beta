import 'package:cts/api/api_result.dart';
import 'package:cts/features/batches/models/batch_model.dart';

/// An abstract interface for handling batch-related data.
abstract class BatchRepository {
  /// Fetches a list of all batches for the current admin.
  Future<ApiResult<List<BatchModel>>> getBatches();

  /// Creates a new batch.
  Future<ApiResult<void>> createBatch(Map<String, dynamic> data);

  /// Updates an existing batch.
  Future<ApiResult<void>> updateBatch(int id, Map<String, dynamic> data);

  /// Deletes a batch by its ID.
  Future<ApiResult<void>> deleteBatch(int id);
}
