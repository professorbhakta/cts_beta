import 'dart:async';

import 'package:cts/api/api_result.dart';
import 'package:cts/data/local/dao/admin_bootstrap_dao.dart';
import 'package:cts/features/admin_bootstrap/admin_bootstrap_cache.dart';
import 'package:cts/features/admin_bootstrap/models/admin_bootstrap_response.dart';
import 'package:cts/features/admin_bootstrap/repositories/admin_bootstrap_repository.dart';

/// Catalog luggage access for list repos / admin home.
///
/// Source of truth: [AdminBootstrapCache] (+ SQLite on mobile).
/// Old per-resource admin list GETs are not used when this path is healthy.
class AdminBootstrapListSource {
  const AdminBootstrapListSource._();

  static AdminBootstrapRepository? _repository;
  static Future<AdminBootstrapResponse?>? _inFlightSync;

  /// Wire the shared repository once at app bootstrap.
  static void bind(AdminBootstrapRepository repository) {
    _repository = repository;
  }

  static Future<AdminBootstrapResponse?> luggage() {
    return AdminBootstrapCache.instance.load();
  }

  /// Memory/SQLite first; if empty, soft-sync `GET /user/admin-bootstrap/`.
  static Future<AdminBootstrapResponse?> ensureLuggage() async {
    final existing = await luggage();
    if (existing != null) return existing;
    return _resync();
  }

  /// Force network bootstrap (admin pull-to-refresh).
  static Future<AdminBootstrapResponse?> refreshLuggage() {
    return _resync();
  }

  /// Drop memory + SQLite so the next [ensureLuggage] re-syncs from network.
  static Future<void> invalidateLocal() async {
    AdminBootstrapCache.instance.clear();
    await AdminBootstrapDao().clearAll();
  }

  /// Clear then immediately re-fetch luggage (explicit full reset).
  static Future<AdminBootstrapResponse?> invalidateAndResync() async {
    await invalidateLocal();
    return _resync();
  }

  /// After catalog CRUD: refill in the background without blocking the mutation.
  ///
  /// Keeps stale luggage until the new payload arrives (stale-while-revalidate).
  /// Concurrent calls coalesce into one in-flight sync.
  static void refreshInBackground() {
    unawaited(_resync());
  }

  static Future<AdminBootstrapResponse?> _resync() {
    final existing = _inFlightSync;
    if (existing != null) return existing;

    final future = _doResync();
    _inFlightSync = future;
    future.whenComplete(() {
      if (identical(_inFlightSync, future)) {
        _inFlightSync = null;
      }
    });
    return future;
  }

  static Future<AdminBootstrapResponse?> _doResync() async {
    final repo = _repository;
    if (repo == null) return null;
    final result = await repo.sync();
    if (result.isSuccess) return result.data;
    return null;
  }

  static ApiFailure catalogUnavailableFailure() {
    return const ApiFailure(
      type: ApiFailureType.network,
      message:
          'Catalog sync unavailable. Pull to refresh or sign in again.',
    );
  }
}
