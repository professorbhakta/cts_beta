import 'package:cts/core/network/api_exceptions_handler.dart';
import 'package:cts/core/network/api_list.dart';
import 'package:cts/core/network/api_result.dart';
import 'package:cts/core/network/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/features/commuters/domain/repositories/commuter_repository.dart';
import 'package:cts/features/commuters/domain/models/commuter_model.dart';

class CommuterRepositoryImpl implements CommuterRepository {
  CommuterRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  @override
  Future<ApiResult<List<CommuterModel>>> getCommuters() async {
    try {
      final adminCode = AppManager.instance.getString(ManagerKey.adminCode);
      final response = await _apiService.getApi(
        "${ApiUrl.adminCommuterUrl}$adminCode",
      );

      if (response is List<dynamic>) {
        final commuters = response
            .map(
              (json) => CommuterModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
        return ApiResult.success(commuters);
      } else {
        return ApiResult.failure(
          ApiExceptionHandler.handle('Invalid response format'),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<List<CommuterModel>>> getCommutersByBatch(
    String batchId,
  ) async {
    try {
      final response = await _apiService.getApi(
        "${ApiUrl.adminBatchUrl}$batchId",
      );
      if (response is List<dynamic>) {
        final commuters = response
            .map(
              (json) => CommuterModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
        return ApiResult.success(commuters);
      } else {
        return ApiResult.failure(
          ApiExceptionHandler.handle('Invalid response format'),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<CommuterModel>> getCommuterProfile() async {
    try {
      final userId = AppManager.instance.getString(ManagerKey.userId);
      final response = await _apiService.getApi(
        "${ApiUrl.commuterUrl}/$userId",
      );
      final commuter = CommuterModel.fromJson(response);
      return ApiResult.success(commuter);
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> updateIsComing(bool isComing) async {
    try {
      final userIdString = AppManager.instance.getString(ManagerKey.userId);
      final userId = int.tryParse(userIdString);

      if (userId == null) {
        return ApiResult.failure(
          ApiExceptionHandler.handle('Invalid user ID format.'),
        );
      }

      final data = {'isComing': isComing};

      await _apiService.patchApi(userId, data, ApiUrl.commuterUrl);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> updateCommuterIsComing(
    int userId,
    bool isComing,
  ) async {
    try {
      final data = {'isComing': isComing};

      final response = await _apiService.patchApi(
        userId,
        data,
        ApiUrl.commuterUrl,
      );

      if (response != null && response.toString().isNotEmpty) {
        return ApiResult.success(null);
      }
      return ApiResult.failure(
        const ApiFailure(
          type: ApiFailureType.parsing,
          message: 'Failed to update commuter status.',
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> createCommuter(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.postApi(data, ApiUrl.cndUserUrl);
      if (response is Map<String, dynamic>) {
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.parsing,
            message: response?.toString() ?? "Create Commuter failed.",
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> updateCommuter(
    int userId,
    Map<String, dynamic> userData,
    Map<String, dynamic> commuterData,
  ) async {
    try {
      final commuterUserResponse = await _apiService.patchApi(
        userId,
        userData,
        ApiUrl.userUrl,
      );
      final commuterUpdate = await _apiService.patchApi(
        userId,
        commuterData,
        ApiUrl.commuterUrl,
      );

      if (commuterUserResponse != null && commuterUpdate != null) {
        return ApiResult.success(null);
      }
      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.parsing,
          message:
              commuterUserResponse?.toString() ?? "Update Commuter failed.",
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> deleteCommuter(int userId) async {
    try {
      final response = await _apiService.deleteApi(userId, ApiUrl.userUrl);
      if (response != null && response.toString().isNotEmpty) {
        return ApiResult.success(null);
      }
      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.parsing,
          message: response?.toString() ?? "Delete Commuter failed.",
        ),
      );
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }
}

