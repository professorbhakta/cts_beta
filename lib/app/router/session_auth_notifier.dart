import 'package:cts/domain/repositories/session_repository.dart';
import 'package:flutter/foundation.dart';

/// Listens for session changes so [GoRouter] can re-run redirects.
class SessionAuthNotifier extends ChangeNotifier {
  SessionAuthNotifier(this._sessionRepository);

  final SessionRepository _sessionRepository;

  bool _loggedIn = false;
  String? _userType;
  bool _ready = false;

  bool get loggedIn => _loggedIn;
  String? get userType => _userType;
  bool get ready => _ready;

  Future<void> refresh() async {
    _loggedIn = await _sessionRepository.isLoggedIn();
    _userType = await _sessionRepository.getUserType();
    _ready = true;
    notifyListeners();
  }
}
