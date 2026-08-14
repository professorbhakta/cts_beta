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

  String? _csrfToken;
  String? _sessionId;
  bool _hydrated = false;

  Future<void> setCsrfToken(String? token) =>
      _write(SessionKeys.csrfToken, token);

  Future<void> setSessionId(String? sessionId) =>
      _write(SessionKeys.sessionId, sessionId);

  Future<String?> getCsrfToken() async {
    await _hydrate();
    return _csrfToken;
  }

  Future<String?> getSessionId() async {
    await _hydrate();
    return _sessionId;
  }

  Future<void> clear() async {
    _csrfToken = null;
    _sessionId = null;
    _hydrated = true;
    await _storage.deleteAll(aOptions: _androidOptions, iOptions: _iosOptions);
  }

  Future<Map<String, String>> buildCookieHeader() async {
    await _hydrate();
    return <String, String>{
      'csrftoken': _csrfToken ?? '',
      'sessionid': _sessionId ?? '',
    };
  }

  Future<void> _hydrate() async {
    if (_hydrated) return;
    _csrfToken = await _storage.read(
      key: SessionKeys.csrfToken,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
    _sessionId = await _storage.read(
      key: SessionKeys.sessionId,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
    _hydrated = true;
  }

  Future<void> _write(String key, String? value) async {
    await _hydrate();
    final stored = (value == null || value.isEmpty) ? null : value;
    if (key == SessionKeys.csrfToken) {
      _csrfToken = stored;
    } else if (key == SessionKeys.sessionId) {
      _sessionId = stored;
    }
    if (stored == null) {
      await _storage.delete(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      return;
    }
    await _storage.write(
      key: key,
      value: stored,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }
}
