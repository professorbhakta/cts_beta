import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/data/repositories/authentication_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService implements BaseApiServices {
  _FakeApiService(this._handler);

  final Future<dynamic> Function(String url) _handler;

  @override
  Future<dynamic> deleteApi(int id, String url) => throw UnimplementedError();

  @override
  Future<dynamic> getApi(String url) => _handler(url);

  @override
  Future<dynamic> patchApi(int id, dynamic data, String url) =>
      throw UnimplementedError();

  @override
  Future<dynamic> postApi(dynamic data, String url) => throw UnimplementedError();
}

Future<void> _seedLoggedInDriverSession() async {
  SharedPreferences.setMockInitialValues({
    ManagerKey.isLogin: true,
    ManagerKey.userId: '42',
    ManagerKey.userType: 'DRIVER',
  });
  await AppManager.initialize();
  AppClass.userType = 2;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthenticationRepositoryImpl.refreshSessionFromServer', () {
    test('updates cached role when server role changed', () async {
      await _seedLoggedInDriverSession();

      final repository = AuthenticationRepositoryImpl(
        apiService: _FakeApiService((url) async {
          expect(url, 'user/42');
          return {'userType': 'ADMIN'};
        }),
      );

      final valid = await repository.refreshSessionFromServer();

      expect(valid, isTrue);
      expect(AppManager.instance.getString(ManagerKey.userType), 'ADMIN');
      expect(AppClass.userType, 3);
    });

    test('returns false on unauthorized response', () async {
      await _seedLoggedInDriverSession();

      final repository = AuthenticationRepositoryImpl(
        apiService: _FakeApiService((url) async {
          throw DioException(
            requestOptions: RequestOptions(path: url),
            response: Response(
              requestOptions: RequestOptions(path: url),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          );
        }),
      );

      final valid = await repository.refreshSessionFromServer();

      expect(valid, isFalse);
    });
  });

  group('AuthenticationRepositoryImpl.signUp', () {
    test('public signUp is disabled', () async {
      final repository = AuthenticationRepositoryImpl(
        apiService: _FakeApiService((url) async => null),
      );

      final result = await repository.signUp(
        username: 'Test',
        mobileNumber: '9999999999',
        password: 'secret',
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, ApiFailureType.invalidRequest);
    });
  });
}
