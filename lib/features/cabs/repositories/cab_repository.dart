import 'package:cts/api/api_result.dart';
import 'package:cts/models/cab_model.dart';

abstract class CabRepository {
  Future<ApiResult<List<CabModel>>> getCabs();
  Future<ApiResult<void>> createCab(Map<String, dynamic> data);

  // START INSERTION HERE
  Future<ApiResult<void>> updateCab(int id, Map<String, dynamic> data);
  Future<ApiResult<void>> deleteCab(int id);
  // END INSERTION HERE
}

