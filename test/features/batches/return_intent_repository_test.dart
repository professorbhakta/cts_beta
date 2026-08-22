import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/features/batches/models/return_intent_model.dart';
import 'package:cts/features/batches/repositories/return_batch_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApiService implements BaseApiServices {
  dynamic getResponse;
  dynamic postResponse;
  String? lastGetUrl;
  String? lastPostUrl;
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
  Future<dynamic> postApi(dynamic data, String url) async {
    lastPostBody = data;
    lastPostUrl = url;
    return postResponse;
  }
}

void main() {
  late _FakeApiService api;
  late ReturnBatchRepositoryImpl repository;

  setUp(() {
    api = _FakeApiService();
    repository = ReturnBatchRepositoryImpl(apiService: api);
  });

  test('getReturnIntent parses ok payload', () async {
    api.getResponse = {
      'status': 'ok',
      'intent': 'skip',
      'target_batch_id': null,
      'user_id': '4',
      'trip_date': '22-08-2026',
    };

    final result = await repository.getReturnIntent();

    expect(api.lastGetUrl, ApiUrl.returnBatchIntent);
    expect(result.isSuccess, isTrue);
    expect(result.data?.intent, ReturnIntentKind.skip);
  });

  test('setReturnIntent posts body and parses response', () async {
    api.postResponse = {
      'status': 'ok',
      'intent': 'earlier',
      'target_batch_id': '9',
    };

    final result = await repository.setReturnIntent(
      const ReturnIntentModel(
        intent: ReturnIntentKind.earlier,
        targetBatchId: '9',
      ),
    );

    expect(api.lastPostUrl, ApiUrl.returnBatchIntent);
    expect(api.lastPostBody, {
      'intent': 'earlier',
      'target_batch_id': '9',
    });
    expect(result.isSuccess, isTrue);
    expect(result.data?.intent, ReturnIntentKind.earlier);
    expect(result.data?.targetBatchId, '9');
  });

  test('setReturnIntent treats status:error as failure', () async {
    api.postResponse = {
      'status': 'error',
      'message': 'already confirmed',
    };

    final result = await repository.setReturnIntent(
      const ReturnIntentModel(intent: ReturnIntentKind.skip),
    );

    expect(result.isFailure, isTrue);
    expect(result.failure?.message, 'already confirmed');
  });

  test('getReturnIntentOptions parses list', () async {
    api.getResponse = {
      'status': 'ok',
      'options': [
        {'id': '2', 'batchName': 'Early', 'end_time': '15:00'},
      ],
    };

    final result = await repository.getReturnIntentOptions();

    expect(api.lastGetUrl, ApiUrl.returnBatchIntentOptions);
    expect(result.isSuccess, isTrue);
    expect(result.data, hasLength(1));
    expect(result.data!.first.label, 'Early (15:00)');
  });
}
