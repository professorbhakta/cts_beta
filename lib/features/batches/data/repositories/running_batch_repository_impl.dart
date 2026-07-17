import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/features/batches/domain/models/batch_model.dart';
import 'package:cts/features/batches/domain/repositories/running_batch_repository.dart';

class RunningBatchRepositoryImpl implements RunningBatchRepository {
  RunningBatchRepositoryImpl({required this._apiServices});

  final BaseApiServices _apiServices;

  @override
  Future<ApiResult<List<RunningBatches>>> fetchRunningBatches() async {
    try {
      final adminCode = AppManager.instance.getString(ManagerKey.adminCode);
      final url = "${ApiUrl.dtotLogUrl}/$adminCode";
      final response = await _apiServices.getApi(url);

      final batches = _parseRunningBatchList(response);
      return ApiResult.success(batches);
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Stream<ApiResult<List<RunningBatches>>> watchRunningBatches({
    Duration interval = const Duration(seconds: 20),
  }) async* {
    while (true) {
      yield await fetchRunningBatches();
      await Future.delayed(interval);
    }
  }

  List<RunningBatches> _parseRunningBatchList(dynamic data) {
    if (data is List) {
      return data
          .map(
            (json) => RunningBatches.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList();
    }
    return [];
  }
}
