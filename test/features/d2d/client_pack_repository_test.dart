import 'package:cts/api/api_list.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/api/client_pack_error_messages.dart';
import 'package:cts/features/d2d/models/odometer_models.dart';
import 'package:cts/features/d2d/repositories/d2d_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApiService implements BaseApiServices {
  dynamic getResponse;
  dynamic postResponse;
  dynamic postMultipartResponse;
  Object? postMultipartError;
  String? lastGetUrl;
  String? lastPostUrl;
  String? lastMultipartUrl;
  dynamic lastPostBody;

  @override
  Future<dynamic> deleteApi(int id, String url) => throw UnimplementedError();

  @override
  Future<dynamic> getApi(String url) async {
    lastGetUrl = url;
    return getResponse;
  }

  @override
  Future<dynamic> patchApi(int id, dynamic data, String url) =>
      throw UnimplementedError();

  @override
  Future<dynamic> patchUrl(String url, dynamic data) =>
      throw UnimplementedError();

  @override
  Future<dynamic> postApi(dynamic data, String url) async {
    lastPostUrl = url;
    lastPostBody = data;
    return postResponse;
  }

  @override
  Future<dynamic> postMultipart(dynamic data, String url) async {
    lastMultipartUrl = url;
    if (postMultipartError != null) throw postMultipartError!;
    return postMultipartResponse;
  }
}

void main() {
  group('ClientPackErrorMessages', () {
    test('maps known codes', () {
      expect(
        ClientPackErrorMessages.messageFor('km_required'),
        contains('odometer KM'),
      );
      expect(
        ClientPackErrorMessages.messageFor('expired_token'),
        contains('expired'),
      );
    });

    test('falls back for unknown codes', () {
      expect(
        ClientPackErrorMessages.messageFor('weird', fallback: 'Custom'),
        'Custom',
      );
    });

    test('helpers for UI branching', () {
      expect(ClientPackErrorMessages.shouldRefreshQr('expired_token'), isTrue);
      expect(ClientPackErrorMessages.needsActiveTrip('no_live_state'), isTrue);
      expect(ClientPackErrorMessages.isAuthFailure('forbidden'), isTrue);
    });
  });

  group('OdometerSnapshot', () {
    test('parses morning/return blocks', () {
      final snap = OdometerSnapshot.fromJson({
        'status': 'ok',
        'batch_id': 1,
        'trip_date': '2026-08-25',
        'd2d_id': 9,
        'morning': {
          'start_km': 25678,
          'end_km': 25702,
          'distance_km': 24,
          'complete': true,
        },
        'return': {'complete': false},
        'gap_km': null,
        'complete': false,
      });
      expect(snap.batchId, '1');
      expect(snap.morning.startKm, 25678);
      expect(snap.morning.distanceKm, 24);
      expect(snap.morning.complete, isTrue);
      expect(snap.returnLeg.complete, isFalse);
    });
  });

  group('D2dRepositoryImpl client pack', () {
    late _FakeApiService api;
    late D2dRepositoryImpl repo;

    setUp(() {
      api = _FakeApiService();
      repo = D2dRepositoryImpl(apiService: api);
    });

    test('submitOdometerStart parses ok + rejects empty batch client-side', () async {
      final empty = await repo.submitOdometerStart(
        batchId: '',
        leg: OdometerLeg.morning,
        km: 100,
      );
      expect(empty.isFailure, isTrue);
      expect(empty.failure?.code, 'batch_id_required');

      api.postMultipartResponse = {
        'status': 'ok',
        'batch_id': 1,
        'trip_date': '2026-08-25',
        'd2d_id': 2,
        'morning': {'start_km': 100, 'complete': false},
        'return': {'complete': false},
        'complete': false,
      };
      final ok = await repo.submitOdometerStart(
        batchId: '1',
        leg: OdometerLeg.morning,
        km: 100,
      );
      expect(ok.isSuccess, isTrue);
      expect(api.lastMultipartUrl, ApiUrl.odometerStart);
      expect(ok.data!.morning.startKm, 100);
    });

    test('boardingScan maps error status+code', () async {
      api.postResponse = {
        'status': 'error',
        'code': 'expired_token',
        'message': 'QR token expired.',
      };
      final result = await repo.boardingScan('tok');
      expect(result.isFailure, isTrue);
      expect(result.failure?.code, 'expired_token');
      expect(result.failure?.message, contains('expired'));
    });

    test('getBoardingQr success', () async {
      api.getResponse = {
        'status': 'ok',
        'token': 'abc',
        'qr_payload': 'abc',
        'expires_in': 900,
        'batch_id': '1',
        'd2d_id': 3,
        'trip_date': '2026-08-25',
      };
      final result = await repo.getBoardingQr('1');
      expect(result.isSuccess, isTrue);
      expect(result.data!.token, 'abc');
      expect(api.lastGetUrl, ApiUrl.boardingQr('1'));
    });

    test('boardingScan empty token fails locally', () async {
      final result = await repo.boardingScan('  ');
      expect(result.isFailure, isTrue);
      expect(result.failure?.code, 'invalid_token');
    });
  });
}
