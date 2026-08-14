import 'dart:async';

import 'package:cts/api/api_result.dart';
import 'package:cts/api/connectivity_service.dart';
import 'package:cts/data/local/dao/sync_queue_dao.dart';
import 'package:cts/data/local/database/app_database.dart';
import 'package:cts/data/local/entity_type.dart';
import 'package:cts/data/local/models/sync_queue_record.dart';
import 'package:flutter/foundation.dart';

typedef SyncHandler = Future<ApiResult<void>> Function(SyncQueueRecord record);

/// Processes queued offline mutations when connectivity returns.
///
/// Extends [ChangeNotifier] so UI can listen to [pendingCount] / [failedCount].
class SyncManager with ChangeNotifier {
  SyncManager({
    SyncQueueDao? syncQueueDao,
    ConnectivityService? connectivityService,
    this.maxRetries = 5,
  }) : _syncQueueDao = syncQueueDao ?? AppDatabase.instance.syncQueueDao,
       _ownsConnectivity = connectivityService == null,
       _connectivity = connectivityService ?? ConnectivityService();

  final SyncQueueDao _syncQueueDao;
  final ConnectivityService _connectivity;
  final bool _ownsConnectivity;
  final int maxRetries;
  final Map<EntityType, SyncHandler> _handlers = {};
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;

  int _pendingCount = 0;
  int _failedCount = 0;

  int get pendingCount => _pendingCount;
  int get failedCount => _failedCount;
  bool get isSyncing => _isSyncing;
  bool get hasPendingWork => _pendingCount > 0;

  void registerHandler(EntityType entityType, SyncHandler handler) {
    _handlers[entityType] = handler;
  }

  Future<void> start() async {
    _connectivity.startListening();
    _connectivitySubscription ??=
        _connectivity.onOnlineStatusChanged.listen((isOnline) {
          if (isOnline) {
            unawaited(syncPending());
          }
        });

    await refreshCounts();
    if (await _connectivity.isOnline) {
      await syncPending();
    }
  }

  Future<void> refreshCounts() async {
    _pendingCount = await _syncQueueDao.pendingCount(maxRetries: maxRetries);
    _failedCount = await _syncQueueDao.failedCount(maxRetries: maxRetries);
    notifyListeners();
  }

  Future<void> syncPending() async {
    if (_isSyncing || !await _connectivity.isOnline) return;

    _isSyncing = true;
    notifyListeners();
    try {
      final pending = await _syncQueueDao.getPending(maxRetries: maxRetries);
      for (final record in pending) {
        final handler = _handlers[record.entityType];
        if (handler == null) {
          final id = record.id;
          if (id != null) {
            await _syncQueueDao.markFailed(
              id: id,
              error: 'No sync handler for ${record.entityType.storageKey}',
              retryCount: maxRetries,
            );
          }
          if (kDebugMode) {
            debugPrint(
              'SyncManager: No handler registered for '
              '${record.entityType.storageKey}; stopped retrying',
            );
          }
          continue;
        }

        final result = await handler(record);
        if (result.isSuccess) {
          await _syncQueueDao.deleteById(record.id!);
        } else {
          final nextRetry = record.retryCount + 1;
          await _syncQueueDao.markFailed(
            id: record.id!,
            error: result.failure?.message ?? 'Sync failed',
            retryCount: nextRetry,
          );
          if (kDebugMode && nextRetry >= maxRetries) {
            debugPrint(
              'SyncManager: Gave up on ${record.entityType.storageKey} '
              'id=${record.entityId} after $nextRetry retries',
            );
          }
        }
      }
    } finally {
      await refreshCounts();
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  @override
  void dispose() {
    unawaited(_disposeResources());
    super.dispose();
  }

  Future<void> _disposeResources() async {
    await stop();
    if (_ownsConnectivity) {
      await _connectivity.dispose();
    }
  }
}
