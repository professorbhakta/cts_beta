import 'package:cts/api/base_api_services.dart';
import 'package:cts/features/batches/repositories/batch_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApiService implements BaseApiServices {
  _FakeApiService(this.responses);

  final Map<String, dynamic> responses;

  @override
  Future<dynamic> deleteApi(int id, String url) async =>
      responses['delete:$id'] ?? responses['delete'];

  @override
  Future<dynamic> getApi(String url) async => responses['get'] ?? [];

  @override
  Future<dynamic> patchApi(int id, dynamic data, String url) async =>
      responses['patch'] ?? responses['patch:$id'];

  @override
  Future<dynamic> postApi(dynamic data, String url) async => responses['post'];
}

void main() {
  group('BatchRepositoryImpl', () {
    test('createBatch returns success without UI side effects', () async {
      final repo = BatchRepositoryImpl(
        apiService: _FakeApiService({'post': 'BATCH CREATED'}),
      );

      final result = await repo.createBatch({'batchName': 'Morning'});

      expect(result.isSuccess, isTrue);
    });

    test('createBatch treats unexpected body as failure', () async {
      final repo = BatchRepositoryImpl(
        apiService: _FakeApiService({'post': 'DUPLICATE NAME'}),
      );

      final result = await repo.createBatch({'batchName': 'Morning'});

      expect(result.isSuccess, isFalse);
      expect(result.failure?.message, 'DUPLICATE NAME');
    });

    test('deleteBatch accepts DELETED response', () async {
      final repo = BatchRepositoryImpl(
        apiService: _FakeApiService({'delete:4': 'BATCH DELETED'}),
      );

      final result = await repo.deleteBatch(4);

      expect(result.isSuccess, isTrue);
    });
  });
}
