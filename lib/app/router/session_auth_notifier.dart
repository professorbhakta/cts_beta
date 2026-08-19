import 'package:cts/domain/repositories/authentication_repository.dart';
import 'package:cts/domain/repositories/session_repository.dart';
import 'package:flutter/foundation.dart';

/// Listens for session changes so [GoRouter] can re-run redirects.
class SessionAuthNotifier extends ChangeNotifier {
  SessionAuthNotifier(this._sessionRepository);

  final SessionRepository _sessionRepository;
  AuthenticationRepository? _authRepository;

  bool _loggedIn = false;
  String? _userType;
  bool _ready = false;

  bool get loggedIn => _loggedIn;
  String? get userType => _userType;
  bool get ready => _ready;

  void bindAuthRepository(AuthenticationRepository repository) {
    _authRepository = repository;
  }

  /// When [validateWithServer] is true and a session exists, reconciles
  /// cached role with the backend before updating redirect state.
  Future<void> refresh({bool validateWithServer = false}) async {
    if (validateWithServer && _authRepository != null) {
      final hasLocalSession = await _sessionRepository.isLoggedIn();
      if (hasLocalSession) {
        final valid = await _authRepository!.refreshSessionFromServer();
        if (!valid) {
          _loggedIn = false;
          _userType = null;
          _ready = true;
          notifyListeners();
          return;
        }
      }
    }

    _loggedIn = await _sessionRepository.isLoggedIn();
    _userType = await _sessionRepository.getUserType();
    _ready = true;
    notifyListeners();
  }
}
