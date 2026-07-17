import 'package:cts/domain/repositories/session_repository.dart';
import 'package:cts/appManager/app_class.dart';

class SessionRepositoryImpl implements SessionRepository {
  // No longer needs its own instance of AppManager
  SessionRepositoryImpl();

  @override
  Future<bool> isLoggedIn() async {
    // Use the singleton instance directly
    return AppManager.instance.getBool(ManagerKey.isLogin);
  }

  @override
  Future<String?> getUserType() async {
    // Use the singleton instance directly
    final userType = AppManager.instance.getString(ManagerKey.userType);
    return userType.isEmpty ? null : userType;
  }
}

