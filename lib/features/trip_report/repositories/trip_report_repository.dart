import 'package:cts/api/api_result.dart';
import 'package:cts/features/trip_report/models/trip_report_models.dart';
import 'package:cts/features/trip_report/models/trip_report_month_models.dart';

abstract class TripReportRepository {
  Future<ApiResult<TripReportResponse>> fetchReport({
    required String date,
    String? adminCode,
  });

  Future<ApiResult<TripReportMonthResponse>> fetchMonth({
    required int year,
    required int month,
    String? adminCode,
  });

  Future<ApiResult<TripReportEditResult>> editEndKm({
    required String batchId,
    required TripReportLegKind leg,
    required int endKm,
    String? date,
  });
}
