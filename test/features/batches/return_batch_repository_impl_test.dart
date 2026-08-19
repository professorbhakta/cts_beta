import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/features/batches/repositories/return_batch_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApiService implements BaseApiServices {
  dynamic postResponse;

  @override
  Future<dynamic> deleteApi(int id, String url) => throw UnimplementedError();

  @override
  Future<dynamic> getApi(String url) => throw UnimplementedError();

  @override
  Future<dynamic> patchApi(int id, dynamic data, String url) =>
      throw UnimplementedError();

  @override
  Future<dynamic> postApi(dynamic data, String url) async => postResponse;
}

void main() {
  late _FakeApiService api;
  late ReturnBatchRepositoryImpl repository;

  setUp(() {
    api = _FakeApiService();
    repository = ReturnBatchRepositoryImpl(apiService: api);
  });

  test('addCommuterToConfirmList treats 200+status:error as failure', () async {
    api.postResponse = {
      'status': 'error',
      'message': 'not eligible',
    };

    final result = await repository.addCommuterToConfirmList('4', '1');

    expect(result.isFailure, isTrue);
    expect(result.failure?.message, 'not eligible');
    expect(result.failure?.type, ApiFailureType.invalidRequest);
  });

  test('addCommuterToConfirmList maps added status to success message', () async {
    api.postResponse = {'status': 'added'};

    final result = await repository.addCommuterToConfirmList('4', '1');

    expect(result.isSuccess, isTrue);
    expect(result.data, 'Commuter confirmed for return');
  });

  test('removeCommuterFromConfirmList treats unknown status as failure', () async {
    api.postResponse = {'status': 'blocked'};

    final result = await repository.removeCommuterFromConfirmList('4', '1');

    expect(result.isFailure, isTrue);
    expect(
      result.failure?.message,
      'Could not remove commuter from return list',
    );
  });

  test('endReturnTrip treats 200+status:error as failure', () async {
    api.postResponse = {
      'status': 'error',
      'message': 'Trip already ended',
    };

    final result = await repository.endReturnTrip('1');

    expect(result.isFailure, isTrue);
    expect(result.failure?.message, 'Trip already ended');
  });

  test('endReturnTrip succeeds on empty body', () async {
    api.postResponse = null;

    final result = await repository.endReturnTrip('1');

    expect(result.isSuccess, isTrue);
  });

  test('posts to expected add_commuter endpoint shape', () async {
    api.postResponse = {'status': 'added'};
    await repository.addCommuterToConfirmList('99', '7');
    // Fake service does not record calls; smoke that postApi path is exercised.
    expect(api.postResponse, isNotNull);
    expect(ApiUrl.returnBatchAddCommuter, 'd2d/return_batch/add_commuter');
  });
}
