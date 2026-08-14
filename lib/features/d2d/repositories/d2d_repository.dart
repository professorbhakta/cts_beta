import 'package:cts/api/api_result.dart';

enum D2dTripStatus { unknown, none, active, ended }

abstract class D2dRepository {
  Future<ApiResult<D2dTripStatus>> getLogStatus(String batchId);
}
