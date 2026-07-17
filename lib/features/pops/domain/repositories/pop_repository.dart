import 'package:cts/core/network/api_result.dart';
import 'package:cts/models/pop_model.dart';

/// An abstract interface for handling Pick-Up Point (POP) related data.
abstract class PopRepository {
  /// Fetches a list of all POPs for the current admin.
  Future<ApiResult<List<PickUpPointModel>>> getPops();

  /// Creates a new POP.
  Future<ApiResult<void>> createPop(Map<String, dynamic> data);

  /// Updates an existing POP.
  Future<ApiResult<void>> updatePop(int id, Map<String, dynamic> data);

  /// Deletes a POP by its ID.
  Future<ApiResult<void>> deletePop(int id);
}

