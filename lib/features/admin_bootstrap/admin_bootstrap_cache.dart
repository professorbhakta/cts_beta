import 'package:cts/data/local/dao/admin_bootstrap_dao.dart';
import 'package:cts/features/admin_bootstrap/models/admin_bootstrap_response.dart';

/// Process-wide luggage from `GET /user/admin-bootstrap/`.
///
/// Survives across repository instances; cleared on logout.
/// On mobile, [load] can rebuild from SQLite after a cold start.
class AdminBootstrapCache {
  AdminBootstrapCache._();

  static final AdminBootstrapCache instance = AdminBootstrapCache._();

  AdminBootstrapResponse? _payload;

  AdminBootstrapResponse? get payload => _payload;

  bool get hasData => _payload != null;

  void set(AdminBootstrapResponse payload) {
    _payload = payload;
  }

  void clear() {
    _payload = null;
  }

  /// Memory first; else SQLite full payload (no-op on web when DB is null).
  Future<AdminBootstrapResponse?> load({AdminBootstrapDao? dao}) async {
    if (_payload != null) return _payload;
    final fromDb = await (dao ?? AdminBootstrapDao()).readFullAsResponse();
    if (fromDb != null) {
      _payload = fromDb;
    }
    return _payload;
  }
}
