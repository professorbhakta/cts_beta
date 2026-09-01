import 'package:cts/api/api_result.dart';
import 'package:cts/features/d2d/models/boarding_models.dart';
import 'package:cts/features/d2d/models/odometer_models.dart';

enum D2dTripStatus { unknown, none, active, ended }

abstract class D2dRepository {
  Future<ApiResult<D2dTripStatus>> getLogStatus(String batchId);

  // --- Odometer ---
  Future<ApiResult<OdometerSnapshot>> submitOdometerStart({
    required String batchId,
    required OdometerLeg leg,
    required int km,
    String? photoPath,
  });

  Future<ApiResult<OdometerSnapshot>> submitOdometerEnd({
    required String batchId,
    required OdometerLeg leg,
    required int km,
    String? photoPath,
  });

  Future<ApiResult<OdometerSnapshot>> getOdometer(
    String batchId, {
    String? date,
  });

  Future<ApiResult<OdometerOrgList>> getOdometerOrg(
    String adminCode, {
    String? date,
  });

  // --- Boarding QR ---
  Future<ApiResult<BoardingQrPayload>> getBoardingQr(String batchId);

  Future<ApiResult<BoardingScanResult>> boardingScan(
    String token, {
    String action = 'board',
  });

  Future<ApiResult<void>> boardingUnboard({
    required String batchId,
    required int userId,
  });
}
