import 'package:cts/api/api_result.dart';
import 'package:cts/features/admin_bootstrap/models/admin_bootstrap_response.dart';

/// Fetches `GET /user/admin-bootstrap/` and persists into SQLite.
abstract class AdminBootstrapRepository {
  /// Network fetch + replace-all local tables. ADMIN / SUPERVISOR only.
  Future<ApiResult<AdminBootstrapResponse>> sync();

  /// Last successful payload from SQLite meta (may be null).
  Future<AdminBootstrapResponse?> readCachedMeta();

  /// Wipe bootstrap entity tables (logout / role change).
  Future<void> clearLocal();
}
