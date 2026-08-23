import 'package:cts/api/api_list.dart';
import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/features/commuters/providers/commuter_controller.dart';
import 'package:cts/features/commuters/repositories/commuter_repository.dart';
import 'package:cts/features/commuters/repositories/commuter_repository_impl.dart';
import 'package:cts/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService implements BaseApiServices {
  dynamic patchUrlResponse;
  String? lastPatchUrl;
  dynamic lastPatchBody;

  @override
  Future<dynamic> deleteApi(int id, String url) => throw UnimplementedError();

  @override
  Future<dynamic> getApi(String url) => throw UnimplementedError();

  @override
  Future<dynamic> patchApi(int id, dynamic data, String url) =>
      throw UnimplementedError();

  @override
  Future<dynamic> patchUrl(String url, dynamic data) async {
    lastPatchUrl = url;
    lastPatchBody = data;
    return patchUrlResponse;
  }

  @override
  Future<dynamic> postApi(dynamic data, String url) =>
      throw UnimplementedError();
}

class _FakeCommuterRepository implements CommuterRepository {
  ApiResult<int> markAllResult = ApiResult.success(2);
  int markAllCalls = 0;

  @override
  Future<ApiResult<int>> markAllComing() async {
    markAllCalls++;
    return markAllResult;
  }

  @override
  Future<ApiResult<List<CommuterModel>>> getCommuters() async {
    return ApiResult.success([
      CommuterModel(userId: UserModel(id: 1), isComing: false),
      CommuterModel(userId: UserModel(id: 2), isComing: false),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CommuterRepositoryImpl.markAllComing', () {
    late _FakeApiService api;
    late CommuterRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        ManagerKey.adminCode: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
      });
      await AppManager.initialize();
      api = _FakeApiService();
      repository = CommuterRepositoryImpl(apiService: api);
    });

    test('PATCHes admin isComing URL and returns updated count', () async {
      api.patchUrlResponse = {
        'status': 'ok',
        'isComing': true,
        'updated': 5,
      };

      final result = await repository.markAllComing();

      expect(
        api.lastPatchUrl,
        ApiUrl.adminCommuterIsComingUrl(
          'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
        ),
      );
      expect(api.lastPatchBody, {'isComing': true});
      expect(result.isSuccess, isTrue);
      expect(result.data, 5);
    });

    test('treats status:error as failure', () async {
      api.patchUrlResponse = {
        'status': 'error',
        'message': 'Only administrators can mark all commuters coming.',
      };

      final result = await repository.markAllComing();

      expect(result.isFailure, isTrue);
      expect(
        result.failure?.message,
        'Only administrators can mark all commuters coming.',
      );
    });
  });

  group('CommuterController.markAllComing', () {
    test('returns updated count and clears in-flight flag', () async {
      final repo = _FakeCommuterRepository();
      final controller = CommuterController(repo);

      final updated = await controller.markAllComing();

      expect(updated, 2);
      expect(repo.markAllCalls, 1);
      expect(controller.isMarkAllComingInFlight, isFalse);
    });

    test('returns null on failure and sets errorMessage', () async {
      final repo = _FakeCommuterRepository()
        ..markAllResult = ApiResult.failure(
          ApiFailure(
            type: ApiFailureType.invalidRequest,
            message: 'denied',
          ),
        );
      final controller = CommuterController(repo);

      final updated = await controller.markAllComing();

      expect(updated, isNull);
      expect(controller.errorMessage, 'denied');
    });

    test('sets all loaded list items isComing true on success', () async {
      final repo = _FakeCommuterRepository();
      final controller = CommuterController(repo);
      await controller.fetchCommuters();

      expect(controller.commuters.every((c) => c.isComing == false), isTrue);

      final updated = await controller.markAllComing();

      expect(updated, 2);
      expect(controller.commuters.every((c) => c.isComing == true), isTrue);
    });
  });
}
