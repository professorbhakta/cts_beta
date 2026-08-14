import 'package:cts/domain/repositories/session_repository.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/session_manager.dart';

class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl();

  @override
  Future<bool> isLoggedIn() async {
    final flagged = AppManager.instance.getBool(ManagerKey.isLogin);
    if (!flagged) return false;
    final sessionId = await SessionManager().getSessionId();
    return sessionId != null && sessionId.isNotEmpty;
  }

  @override
  Future<String?> getUserType() async {
    // Use the singleton instance directly
    final userType = AppManager.instance.getString(ManagerKey.userType);
    return userType.isEmpty ? null : userType;
  }
}

