import 'package:cts/api/api_result.dart';
import 'package:cts/features/admin_bootstrap/models/admin_bootstrap_response.dart';

/// Fetches `GET /user/admin-bootstrap/` and keeps luggage for list UIs.
abstract class AdminBootstrapRepository {
  /// Network fetch + memory (+ SQLite on mobile). ADMIN / SUPER_ADMIN / SUPERVISOR.
  Future<ApiResult<AdminBootstrapResponse>> sync();

  /// Memory first, else SQLite full payload. Null if never synced.
  Future<AdminBootstrapResponse?> readLuggage();

  /// Meta-only snapshot (legacy); prefer [readLuggage] for list data.
  Future<AdminBootstrapResponse?> readCachedMeta();

  /// Wipe memory + bootstrap entity tables (logout / role change).
  Future<void> clearLocal();
}
