import 'package:cts/api/api_result.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/session_manager.dart';
import 'package:cts/data/repositories/authentication_repository_impl.dart';
import 'package:cts/features/auth/models/login_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService implements BaseApiServices {
  _FakeApiService({
    Future<dynamic> Function(String url)? getHandler,
    Future<dynamic> Function(dynamic data, String url)? postHandler,
  })  : _getHandler = getHandler,
        _postHandler = postHandler;

  final Future<dynamic> Function(String url)? _getHandler;
  final Future<dynamic> Function(dynamic data, String url)? _postHandler;

  @override
  Future<dynamic> deleteApi(int id, String url) => throw UnimplementedError();

  @override
  Future<dynamic> getApi(String url) {
    final handler = _getHandler;
    if (handler == null) throw UnimplementedError();
    return handler(url);
  }

  @override
  Future<dynamic> patchApi(int id, dynamic data, String url) =>
      throw UnimplementedError();

  @override
  Future<dynamic> postApi(dynamic data, String url) {
    final handler = _postHandler;
    if (handler == null) throw UnimplementedError();
    return handler(data, url);
  }

  @override
  Future<dynamic> postMultipart(dynamic data, String url) =>
      throw UnimplementedError();

  @override
  Future<dynamic> patchUrl(String url, dynamic data) =>
      throw UnimplementedError();
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

Map<String, dynamic> _loginEnvelope({
  String userType = 'COMMUTER',
  List<dynamic>? organizations,
  List<dynamic>? supervisorOrgs,
  dynamic profile,
  dynamic adminCode,
}) {
  return {
    'access': 'access-token-abc',
    'refresh': 'refresh-token-xyz',
    'user': {
      'id': 7,
      'username': 'alice',
      'mobileNumber': '9876543210',
      'email': 'alice@example.com',
      'userType': userType,
      'hasPaid': true,
      'deviceId': 'dev-1',
    },
    'adminCode': adminCode,
    'organizations': organizations ?? [],
    'supervisorOrgs': supervisorOrgs ?? [],
    'profile': profile,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  group('LoginResponse.fromJson', () {
    test('parses camelCase envelope and tolerates empty stubs', () {
      final parsed = LoginResponse.fromJson(_loginEnvelope(profile: null));

      expect(parsed.access, 'access-token-abc');
      expect(parsed.refresh, 'refresh-token-xyz');
      expect(parsed.user.id, '7');
      expect(parsed.user.userType, 'COMMUTER');
      expect(parsed.organizations, isEmpty);
      expect(parsed.supervisorOrgs, isEmpty);
      expect(parsed.profile, isNull);
    });

    test('rejects missing access token', () {
      final raw = _loginEnvelope()..remove('access');
      expect(() => LoginResponse.fromJson(raw), throwsFormatException);
    });
  });

  group('AuthenticationRepositoryImpl.login', () {
    setUp(() async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      await AppManager.initialize();
      await SessionManager().clear();
    });

    test('stores JWT tokens and user fields without secondary fetches', () async {
      final repository = AuthenticationRepositoryImpl(
        apiService: _FakeApiService(
          postHandler: (data, url) async {
            expect(url, 'user/login');
            expect(data['mobileNumber'], '9876543210');
            expect(data['password'], 'secret');
            // No snake_case wire keys.
            expect(data.containsKey('mobile_number'), isFalse);
            return _loginEnvelope(
              userType: 'ADMIN',
              adminCode: 'AC-1',
              organizations: const [],
              supervisorOrgs: const [],
              profile: null,
            );
          },
          getHandler: (url) async {
            fail('Phase A login must not fetch profile tables ($url)');
          },
        ),
      );

      final result = await repository.login(
        mobileNumber: '9876543210',
        password: 'secret',
      );

      expect(result.isSuccess, isTrue);
      expect(result.data, 'ADMIN');
      expect(await SessionManager().getAccessToken(), 'access-token-abc');
      expect(await SessionManager().getRefreshToken(), 'refresh-token-xyz');
      expect(AppManager.instance.getBool(ManagerKey.isLogin), isTrue);
      expect(AppManager.instance.getString(ManagerKey.userType), 'ADMIN');
      expect(AppManager.instance.getString(ManagerKey.userId), '7');
      expect(AppManager.instance.getString(ManagerKey.userName), 'alice');
      expect(AppManager.instance.getString(ManagerKey.adminCode), 'AC-1');
      expect(AppClass.userType, 3);
    });

    test('SUPERVISOR login succeeds with empty org arrays', () async {
      final repository = AuthenticationRepositoryImpl(
        apiService: _FakeApiService(
          postHandler: (data, url) async => _loginEnvelope(
            userType: 'SUPERVISOR',
            organizations: const [],
            supervisorOrgs: const [],
          ),
        ),
      );

      final result = await repository.login(
        mobileNumber: '9876543210',
        password: 'secret',
      );

      expect(result.isSuccess, isTrue);
      expect(result.data, 'SUPERVISOR');
      expect(AppClass.userType, 4);
    });

    test('fails clearly on legacy {user_id,user_type} response', () async {
      final repository = AuthenticationRepositoryImpl(
        apiService: _FakeApiService(
          postHandler: (data, url) async => {
            'user_id': 1,
            'user_type': 'ADMIN',
          },
        ),
      );

      final result = await repository.login(
        mobileNumber: '9876543210',
        password: 'secret',
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, ApiFailureType.parsing);
    });
  });

  group('AuthenticationRepositoryImpl.refreshSessionFromServer', () {
    test('updates cached role when server role changed', () async {
      await _seedLoggedInDriverSession();

      final repository = AuthenticationRepositoryImpl(
        apiService: _FakeApiService(
          getHandler: (url) async {
            expect(url, 'user/42');
            return {'userType': 'ADMIN'};
          },
        ),
      );

      final valid = await repository.refreshSessionFromServer();

      expect(valid, isTrue);
      expect(AppManager.instance.getString(ManagerKey.userType), 'ADMIN');
      expect(AppClass.userType, 3);
    });

    test('returns false on unauthorized response', () async {
      await _seedLoggedInDriverSession();

      final repository = AuthenticationRepositoryImpl(
        apiService: _FakeApiService(
          getHandler: (url) async {
            throw DioException(
              requestOptions: RequestOptions(path: url),
              response: Response(
                requestOptions: RequestOptions(path: url),
                statusCode: 401,
              ),
              type: DioExceptionType.badResponse,
            );
          },
        ),
      );

      final valid = await repository.refreshSessionFromServer();

      expect(valid, isFalse);
    });
  });

  group('AuthenticationRepositoryImpl.signUp', () {
    test('public signUp is disabled', () async {
      final repository = AuthenticationRepositoryImpl(
        apiService: _FakeApiService(
          getHandler: (url) async => null,
        ),
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
