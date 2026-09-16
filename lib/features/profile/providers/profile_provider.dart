import 'package:cts/appManager/app_class.dart';
import 'package:flutter/foundation.dart';

class ProfileProvider with ChangeNotifier {
  String _name = '—';
  String _mobile = '—';
  String _roleLabel = 'User';
  String _batchName = '—';
  String _batchTime = '—';
  String _cabNumber = '—';
  bool _showAssignment = false;
  /// Org admin mobile from session when login profile provided it; else empty.
  String? _adminMobile;

  String get name => _name;
  String get mobile => _mobile;
  String get roleLabel => _roleLabel;
  String get batchName => _batchName;
  String get batchTime => _batchTime;
  String get cabNumber => _cabNumber;
  bool get showAssignment => _showAssignment;

  /// Digits-only admin contact when known; `null` if session has none.
  String? get adminMobile {
    final value = _adminMobile?.trim();
    if (value == null || value.isEmpty || value == '0') return null;
    return value;
  }

  void load() {
    final manager = AppManager.instance;
    final userName = manager.getString(ManagerKey.userName);
    final storedName = manager.getString(ManagerKey.name);
    _name = _display(
      userName.isNotEmpty && userName != '0' ? userName : storedName,
    );
    _mobile = _display(manager.getString(ManagerKey.mobile));
    _roleLabel = SessionRole.roleLabel;
    _showAssignment = SessionRole.isDriver || SessionRole.isCommuterLike;
    _batchName = _display(manager.getString(ManagerKey.batchName));
    _batchTime = _display(manager.getString(ManagerKey.batchTime));
    _cabNumber = _display(manager.getString(ManagerKey.cabNumb));
    final storedAdmin = manager.getString(ManagerKey.adminMobile);
    _adminMobile = (storedAdmin.isEmpty || storedAdmin == '0')
        ? null
        : storedAdmin;
    notifyListeners();
  }

  void reset() {
    _name = '—';
    _mobile = '—';
    _roleLabel = 'User';
    _batchName = '—';
    _batchTime = '—';
    _cabNumber = '—';
    _showAssignment = false;
    _adminMobile = null;
    notifyListeners();
  }

  String _display(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == '0') return '—';
    return trimmed;
  }
}
