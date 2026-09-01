import 'package:cts/api/api_exceptions_handler.dart';
import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_response_contract.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/api/client_pack_error_messages.dart';
import 'package:cts/features/d2d/models/boarding_models.dart';
import 'package:cts/features/d2d/models/odometer_models.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';
import 'package:dio/dio.dart';

class D2dRepositoryImpl implements D2dRepository {
  D2dRepositoryImpl({required this._apiService});

  final BaseApiServices _apiService;

  @override
  Future<ApiResult<D2dTripStatus>> getLogStatus(String batchId) async {
    try {
      final response = await _apiService.getApi(
        '${ApiUrl.d2dLogStatus}$batchId',
      );

      if (response is! Map) {
        return ApiResult.success(D2dTripStatus.none);
      }

      final map = Map<String, dynamic>.from(response);
      final status = map['status']?.toString();
      final isActive = map['is_active'] == true;

      if (status == 'ended' || !isActive) {
        return ApiResult.success(D2dTripStatus.ended);
      }
      return ApiResult.success(D2dTripStatus.active);
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<OdometerSnapshot>> submitOdometerStart({
    required String batchId,
    required OdometerLeg leg,
    required int km,
    String? photoPath,
  }) {
    return _postOdometer(
      url: ApiUrl.odometerStart,
      batchId: batchId,
      leg: leg,
      km: km,
      photoPath: photoPath,
    );
  }

  @override
  Future<ApiResult<OdometerSnapshot>> submitOdometerEnd({
    required String batchId,
    required OdometerLeg leg,
    required int km,
    String? photoPath,
  }) {
    return _postOdometer(
      url: ApiUrl.odometerEnd,
      batchId: batchId,
      leg: leg,
      km: km,
      photoPath: photoPath,
    );
  }

  Future<ApiResult<OdometerSnapshot>> _postOdometer({
    required String url,
    required String batchId,
    required OdometerLeg leg,
    required int km,
    String? photoPath,
  }) async {
    if (batchId.trim().isEmpty) {
      return _codedFailure('batch_id_required');
    }
    if (km < 0) {
      return _codedFailure('invalid_km');
    }
    try {
      final map = <String, dynamic>{
        'batch_id': batchId,
        'leg': leg.apiValue,
        'km': km.toString(),
      };
      final path = photoPath?.trim();
      if (path != null && path.isNotEmpty) {
        map['photo'] = await MultipartFile.fromFile(
          path,
          filename: path.split(RegExp(r'[\\/]')).last,
        );
      }
      final form = FormData.fromMap(map);
      final response = await _apiService.postMultipart(form, url);
      return _parseOdometerSnapshot(response);
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<OdometerSnapshot>> getOdometer(
    String batchId, {
    String? date,
  }) async {
    try {
      final q = (date != null && date.isNotEmpty) ? '?date=$date' : '';
      final response = await _apiService.getApi(
        '${ApiUrl.odometerBatch(batchId)}$q',
      );
      return _parseOdometerSnapshot(response);
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<OdometerOrgList>> getOdometerOrg(
    String adminCode, {
    String? date,
  }) async {
    try {
      final q = (date != null && date.isNotEmpty) ? '?date=$date' : '';
      final response = await _apiService.getApi(
        '${ApiUrl.odometerOrg(adminCode)}$q',
      );
      if (response is! Map) {
        return ApiResult.failure(
          const ApiFailure(
            type: ApiFailureType.parsing,
            message: 'Unexpected odometer org response.',
          ),
        );
      }
      final map = Map<String, dynamic>.from(response);
      final contract = ApiResponseContract.parse(map);
      if (contract.isFailure) {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.invalidRequest,
            code: contract.code,
            message: ClientPackErrorMessages.messageFor(
              contract.code,
              fallback: contract.message,
            ),
          ),
        );
      }
      return ApiResult.success(OdometerOrgList.fromJson(map));
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<BoardingQrPayload>> getBoardingQr(String batchId) async {
    try {
      final response = await _apiService.getApi(ApiUrl.boardingQr(batchId));
      if (response is! Map) {
        return ApiResult.failure(
          const ApiFailure(
            type: ApiFailureType.parsing,
            message: 'Unexpected boarding QR response.',
          ),
        );
      }
      final map = Map<String, dynamic>.from(response);
      final contract = ApiResponseContract.parse(map);
      if (contract.isFailure) {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.invalidRequest,
            code: contract.code,
            message: ClientPackErrorMessages.messageFor(
              contract.code,
              fallback: contract.message,
            ),
          ),
        );
      }
      final payload = BoardingQrPayload.fromJson(map);
      if (payload.token.isEmpty) {
        return ApiResult.failure(
          const ApiFailure(
            type: ApiFailureType.parsing,
            code: 'invalid_token',
            message: 'QR token missing from server.',
          ),
        );
      }
      return ApiResult.success(payload);
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<BoardingScanResult>> boardingScan(
    String token, {
    String action = 'board',
  }) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) {
      return _codedFailure('invalid_token');
    }
    final normalizedAction = action.trim().toLowerCase();
    if (normalizedAction.isEmpty) {
      return _codedFailure('invalid_action');
    }
    try {
      final response = await _apiService.postApi(
        {'token': trimmed, 'action': normalizedAction},
        ApiUrl.boardingScan,
      );
      if (response is! Map) {
        return ApiResult.failure(
          const ApiFailure(
            type: ApiFailureType.parsing,
            message: 'Unexpected boarding scan response.',
          ),
        );
      }
      final map = Map<String, dynamic>.from(response);
      final contract = ApiResponseContract.parse(map);
      if (contract.isFailure) {
        return ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.invalidRequest,
            code: contract.code,
            message: ClientPackErrorMessages.messageFor(
              contract.code,
              fallback: contract.message,
            ),
          ),
        );
      }
      return ApiResult.success(BoardingScanResult.fromJson(map));
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<void>> boardingUnboard({
    required String batchId,
    required int userId,
  }) async {
    if (batchId.trim().isEmpty || userId <= 0) {
      return _codedFailure('missing_fields');
    }
    try {
      final response = await _apiService.postApi(
        {'batch_id': batchId, 'user_id': userId},
        ApiUrl.boardingUnboard,
      );
      if (response is Map) {
        final contract = ApiResponseContract.parse(
          Map<String, dynamic>.from(response),
        );
        if (contract.isFailure) {
          return ApiResult.failure(
            ApiFailure(
              type: ApiFailureType.invalidRequest,
              code: contract.code,
              message: ClientPackErrorMessages.messageFor(
                contract.code,
                fallback: contract.message,
              ),
            ),
          );
        }
      }
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ApiExceptionHandler.handle(e));
    }
  }

  ApiResult<OdometerSnapshot> _parseOdometerSnapshot(dynamic response) {
    if (response is! Map) {
      return ApiResult.failure(
        const ApiFailure(
          type: ApiFailureType.parsing,
          message: 'Unexpected odometer response.',
        ),
      );
    }
    final map = Map<String, dynamic>.from(response);
    final contract = ApiResponseContract.parse(map);
    if (contract.isFailure) {
      return ApiResult.failure(
        ApiFailure(
          type: ApiFailureType.invalidRequest,
          code: contract.code,
          message: ClientPackErrorMessages.messageFor(
            contract.code,
            fallback: contract.message,
          ),
        ),
      );
    }
    return ApiResult.success(OdometerSnapshot.fromJson(map));
  }

  ApiResult<T> _codedFailure<T>(String code) {
    return ApiResult.failure(
      ApiFailure(
        type: ApiFailureType.invalidRequest,
        code: code,
        message: ClientPackErrorMessages.messageFor(code),
      ),
    );
  }
}
