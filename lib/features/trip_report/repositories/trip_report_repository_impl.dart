import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_response_contract.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/features/trip_report/models/trip_report_models.dart';
import 'package:cts/features/trip_report/repositories/trip_report_repository.dart';

class TripReportRepositoryImpl implements TripReportRepository {
  TripReportRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  /// Builds GET query for daily report (exposed for unit tests).
  static String buildReportUrl({
    required String date,
    required String adminCode,
  }) {
    final d = Uri.encodeQueryComponent(date.trim());
    final a = Uri.encodeQueryComponent(adminCode.trim());
    return '${ApiUrl.tripReportUrl}?date=$d&admin_code=$a';
  }

  /// Builds PATCH/POST body for edit_end_km (exposed for unit tests).
  static Map<String, dynamic> buildEditBody({
    required String batchId,
    required TripReportLegKind leg,
    required int endKm,
    String? date,
  }) {
    final body = <String, dynamic>{
      'batch_id': batchId,
      'leg': leg.apiValue,
      'end_km': endKm,
    };
    final d = date?.trim();
    if (d != null && d.isNotEmpty) {
      body['date'] = d;
    }
    return body;
  }

  String _sessionAdminCode() =>
      AppManager.instance.getString(ManagerKey.adminCode);

  @override
  Future<ApiResult<TripReportResponse>> fetchReport({
    required String date,
    String? adminCode,
  }) async {
    final code = (adminCode ?? _sessionAdminCode()).trim();
    if (date.trim().isEmpty) {
      return ApiResult.failure(
        const ApiFailure(
          type: ApiFailureType.invalidRequest,
          message: 'date is required',
          code: 'date_required',
        ),
      );
    }
    if (code.isEmpty) {
      return ApiResult.failure(
        const ApiFailure(
          type: ApiFailureType.invalidRequest,
          message: 'admin_code is required',
          code: 'admin_code_required',
        ),
      );
    }
    try {
      final url = buildReportUrl(date: date, adminCode: code);
      final response = await _apiService.getApi(url);
      if (response is! Map) {
        return ApiResult.failure(
          const ApiFailure(
            type: ApiFailureType.parsing,
            message: 'Unexpected trip report response',
          ),
        );
      }
      final map = Map<String, dynamic>.from(response);
      final contract = ApiResponseContract.parse(
        map,
        failureMessage: 'Failed to load trip report',
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
      return ApiResult.success(TripReportResponse.fromJson(map));
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<TripReportEditResult>> editEndKm({
    required String batchId,
    required TripReportLegKind leg,
    required int endKm,
    String? date,
  }) async {
    if (batchId.trim().isEmpty) {
      return ApiResult.failure(
        const ApiFailure(
          type: ApiFailureType.invalidRequest,
          message: 'batch_id is required',
          code: 'batch_id_required',
        ),
      );
    }
    if (endKm < 0) {
      return ApiResult.failure(
        const ApiFailure(
          type: ApiFailureType.invalidRequest,
          message: 'end_km must be >= 0',
          code: 'invalid_end_km',
        ),
      );
    }
    try {
      final body = buildEditBody(
        batchId: batchId,
        leg: leg,
        endKm: endKm,
        date: date,
      );
      // Contract: PATCH or POST — prefer PATCH.
      final response =
          await _apiService.patchUrl(ApiUrl.tripReportEditEndKmUrl, body);
      if (response is! Map) {
        return ApiResult.failure(
          const ApiFailure(
            type: ApiFailureType.parsing,
            message: 'Unexpected edit_end_km response',
          ),
        );
      }
      final map = Map<String, dynamic>.from(response);
      final contract = ApiResponseContract.parse(
        map,
        failureMessage: 'Failed to edit end_km',
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
      return ApiResult.success(TripReportEditResult.fromJson(map));
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }
}
