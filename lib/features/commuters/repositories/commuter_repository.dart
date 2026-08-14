import 'package:cts/api/api_result.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/models/user_model.dart';

abstract class CommuterRepository {
  Future<ApiResult<UserModel>> getUser(int userId);

  Future<ApiResult<List<CommuterModel>>> getCommuters();

  Future<ApiResult<List<CommuterModel>>> getCommutersByBatch(String batchId);

  Future<ApiResult<CommuterModel>> getCommuterProfile();

  Future<ApiResult<void>> updateIsComing(bool isComing);

  Future<ApiResult<void>> updateCommuterIsComing(int userId, bool isComing);

  Future<ApiResult<void>> createCommuter(Map<String, dynamic> data);

  Future<ApiResult<void>> updateCommuter(int userId, Map<String, dynamic> userData, Map<String, dynamic> commuterData);

  Future<ApiResult<void>> deleteCommuter(int userId);

}

