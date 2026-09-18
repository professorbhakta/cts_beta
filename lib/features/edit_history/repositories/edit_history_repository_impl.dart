import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_response_contract.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/features/edit_history/models/edit_record_models.dart';
import 'package:cts/features/edit_history/repositories/edit_history_repository.dart';

class EditHistoryRepositoryImpl implements EditHistoryRepository {
  EditHistoryRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  /// Builds GET query for System Admin history (exposed for unit tests).
  static String buildListUrl({
    String? date,
    int? userId,
    String? path,
    int limit = 100,
  }) {
    final params = <String, String>{};
    final d = date?.trim();
    if (d != null && d.isNotEmpty) {
      params['date'] = d;
    }
    if (userId != null) {
      params['user_id'] = userId.toString();
    }
    final p = path?.trim();
    if (p != null && p.isNotEmpty) {
      params['path'] = p;
    }
    final lim = limit.clamp(1, 500);
    params['limit'] = lim.toString();
    final qs = params.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');
    return '${ApiUrl.editRecordUrl}?$qs';
  }

  @override
  Future<ApiResult<EditRecordListResponse>> fetchRecords({
    String? date,
    int? userId,
    String? path,
    int limit = 100,
  }) async {
    try {
      final url = buildListUrl(
        date: date,
        userId: userId,
        path: path,
        limit: limit,
      );
      final response = await _apiService.getApi(url);
      if (response is! Map) {
        return ApiResult.failure(
          const ApiFailure(
            type: ApiFailureType.parsing,
            message: 'Unexpected edit history response',
          ),
        );
      }
      final map = Map<String, dynamic>.from(response);
      final contract = ApiResponseContract.parse(
        map,
        failureMessage: 'Failed to load edit history',
      );
      if (contract.isFailure) {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.invalidRequest,
            message: contract.message,
            code: contract.code,
          ),
        );
      }
      return ApiResult.success(EditRecordListResponse.fromJson(map));
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }
}
