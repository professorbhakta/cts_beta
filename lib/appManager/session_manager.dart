import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionKeys {
  static const accessToken = 'accessToken';
  static const refreshToken = 'refreshToken';

  /// Legacy cookie keys — cleared on hydrate/clear so old installs migrate.
  static const csrfToken = 'csrfToken';
  static const sessionId = 'sessionId';
}

/// Secure storage for JWT access + refresh tokens (Flutter JWT auth).
class SessionManager {
  SessionManager._internal();

  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const AndroidOptions _androidOptions = AndroidOptions();

  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  String? _accessToken;
  String? _refreshToken;
  bool _hydrated = false;

  Future<void> setAccessToken(String? token) =>
      _write(SessionKeys.accessToken, token);

  Future<void> setRefreshToken(String? token) =>
      _write(SessionKeys.refreshToken, token);

  Future<void> setTokens({
    required String access,
    required String refresh,
  }) async {
    await setAccessToken(access);
    await setRefreshToken(refresh);
  }

  Future<String?> getAccessToken() async {
    await _hydrate();
    return _accessToken;
  }

  Future<String?> getRefreshToken() async {
    await _hydrate();
    return _refreshToken;
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _hydrated = true;
    await _storage.deleteAll(aOptions: _androidOptions, iOptions: _iosOptions);
  }

  Future<void> _hydrate() async {
    if (_hydrated) return;
    _accessToken = await _storage.read(
      key: SessionKeys.accessToken,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
    _refreshToken = await _storage.read(
      key: SessionKeys.refreshToken,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
    // Drop legacy session cookies if present (one-time migration).
    await _storage.delete(
      key: SessionKeys.csrfToken,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
    await _storage.delete(
      key: SessionKeys.sessionId,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
    _hydrated = true;
  }

  Future<void> _write(String key, String? value) async {
    await _hydrate();
    final stored = (value == null || value.isEmpty) ? null : value;
    if (key == SessionKeys.accessToken) {
      _accessToken = stored;
    } else if (key == SessionKeys.refreshToken) {
      _refreshToken = stored;
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
