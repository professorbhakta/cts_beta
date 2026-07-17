import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionKeys {
  static const csrfToken = 'csrfToken';
  static const sessionId = 'sessionId';
}

class SessionManager {
  SessionManager._internal();

  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const AndroidOptions _androidOptions = AndroidOptions();

  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  Future<void> setCsrfToken(String? token) =>
      _write(SessionKeys.csrfToken, token);

  Future<void> setSessionId(String? sessionId) =>
      _write(SessionKeys.sessionId, sessionId);

  Future<String?> getCsrfToken() => _storage.read(
    key: SessionKeys.csrfToken,
    aOptions: _androidOptions,
    iOptions: _iosOptions,
  );

  Future<String?> getSessionId() => _storage.read(
    key: SessionKeys.sessionId,
    aOptions: _androidOptions,
    iOptions: _iosOptions,
  );

  Future<void> clear() =>
      _storage.deleteAll(aOptions: _androidOptions, iOptions: _iosOptions);

  Future<Map<String, String>> buildCookieHeader() async {
    final csrfToken = await getCsrfToken() ?? '';
    final sessionId = await getSessionId() ?? '';

    return <String, String>{
      'csrftoken': csrfToken,
      'sessionid':
          sessionId, // Fixed: use lowercase 'sessionid' to match server expectation
    };
  }

  Future<void> _write(String key, String? value) async {
    if (value == null || value.isEmpty) {
      await _storage.delete(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      return;
    }
    await _storage.write(
      key: key,
      value: value,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }
}
