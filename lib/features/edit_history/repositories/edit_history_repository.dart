import 'package:cts/api/api_result.dart';
import 'package:cts/features/edit_history/models/edit_record_models.dart';

abstract class EditHistoryRepository {
  Future<ApiResult<EditRecordListResponse>> fetchRecords({
    String? date,
    int? userId,
    String? path,
    int limit = 100,
  });
}
