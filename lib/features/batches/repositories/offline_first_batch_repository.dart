import 'package:cts/api/api_result.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/api/connectivity_service.dart';
import 'package:cts/core/sync/sync_manager.dart';
import 'package:cts/data/local/cache/cache_service.dart';
import 'package:cts/data/local/dao/sync_queue_dao.dart';
import 'package:cts/data/local/database/app_database.dart';
import 'package:cts/data/local/entity_type.dart';
import 'package:cts/data/local/models/sync_queue_record.dart';
import 'package:cts/features/batches/repositories/batch_repository_impl.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/repositories/batch_repository.dart';

/// Offline-first batch repository.
///
/// - Reads from SQLite when offline
/// - Writes to API when online, caches successful responses
/// - Queues create/update/delete when offline for later sync
class OfflineFirstBatchRepository implements BatchRepository {
  OfflineFirstBatchRepository({
    required this._remote,
    CacheService? cacheService,
    SyncQueueDao? syncQueueDao,
    ConnectivityService? connectivityService,
  }) : _cache = cacheService ?? CacheService(),
       _syncQueue = syncQueueDao ?? AppDatabase.instance.syncQueueDao,
       _connectivity = connectivityService ?? ConnectivityService();

  final BatchRepositoryImpl _remote;
  final CacheService _cache;
  final SyncQueueDao _syncQueue;
  final ConnectivityService _connectivity;
  SyncManager? _syncManager;

  String get _adminCode => AppManager.instance.getString(ManagerKey.adminCode);

  Future<void> _notifyQueueChanged() async {
    await _syncManager?.refreshCounts();
  }

  @override
  Future<ApiResult<List<BatchModel>>> getBatches() async {
    if (await _connectivity.isOnline) {
      final result = await _remote.getBatches();
      if (result.isSuccess && result.data != null) {
        await _cache.replaceAll(
          entityType: EntityType.batch,
          adminCode: _adminCode,
          rawItems: result.data!.map((batch) => batch.toJson()).toList(),
        );
      }
      return result;
    }

    final cached = await _cache.readAll(
      entityType: EntityType.batch,
      adminCode: _adminCode,
      fromJson: BatchModel.fromJson,
    );

    if (cached.isNotEmpty) {
      return ApiResult.success(cached);
    }

    return ApiResult.failure(
      const ApiFailure(
        type: ApiFailureType.network,
        message:
            'You are offline and no cached batches are available. Connect once to load data.',
      ),
    );
  }

  @override
  Future<ApiResult<void>> createBatch(Map<String, dynamic> data) async {
    if (await _connectivity.isOnline) {
      final result = await _remote.createBatch(data);
      if (result.isSuccess) {
        await getBatches();
      }
      return result;
    }

    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final offlineItem = {
      ...data,
      'id': tempId,
      'adminCode': _adminCode,
      '_offline': true,
    };

    await _cache.upsert(
      entityType: EntityType.batch,
      adminCode: _adminCode,
      rawItem: offlineItem,
    );

    await _syncQueue.enqueue(
      SyncQueueRecord(
        entityType: EntityType.batch,
        entityId: tempId,
        action: SyncAction.create,
        payload: data,
        createdAt: DateTime.now(),
      ),
    );
    await _notifyQueueChanged();

    return ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> updateBatch(int id, Map<String, dynamic> data) async {
    if (await _connectivity.isOnline) {
      final result = await _remote.updateBatch(id, data);
      if (result.isSuccess) {
        await getBatches();
      }
      return result;
    }

    final cached = await _cache.readAll(
      entityType: EntityType.batch,
      adminCode: _adminCode,
      fromJson: BatchModel.fromJson,
    );

    BatchModel? existing;
    for (final batch in cached) {
      if (batch.id == id) {
        existing = batch;
        break;
      }
    }
    if (existing != null) {
      await _cache.upsert(
        entityType: EntityType.batch,
        adminCode: _adminCode,
        rawItem: {
          ...existing.toJson(),
          ...data,
          'id': id,
          '_offline': true,
        },
      );
    }

    await _syncQueue.enqueue(
      SyncQueueRecord(
        entityType: EntityType.batch,
        entityId: id,
        action: SyncAction.update,
        payload: {'id': id, ...data},
        createdAt: DateTime.now(),
      ),
    );
    await _notifyQueueChanged();

    return ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> deleteBatch(int id) async {
    if (await _connectivity.isOnline) {
      final result = await _remote.deleteBatch(id);
      if (result.isSuccess) {
        await _cache.deleteById(
          entityType: EntityType.batch,
          adminCode: _adminCode,
          entityId: id,
        );
      }
      return result;
    }

    await _cache.deleteById(
      entityType: EntityType.batch,
      adminCode: _adminCode,
      entityId: id,
    );

    await _syncQueue.enqueue(
      SyncQueueRecord(
        entityType: EntityType.batch,
        entityId: id,
        action: SyncAction.delete,
        payload: {'id': id},
        createdAt: DateTime.now(),
      ),
    );
    await _notifyQueueChanged();

    return ApiResult.success(null);
  }

  /// Registers sync handlers with [SyncManager]. Call once during app startup.
  void registerSyncHandlers(SyncManager syncManager) {
    _syncManager = syncManager;
    syncManager.registerHandler(EntityType.batch, (record) async {
      switch (record.action) {
        case SyncAction.create:
          return _remote.createBatch(record.payload);
        case SyncAction.update:
          final id = record.entityId ?? record.payload['id'] as int?;
          if (id == null) {
            return ApiResult.failure(
              const ApiFailure(
                type: ApiFailureType.parsing,
                message: 'Missing batch id for offline update sync.',
              ),
            );
          }
          final payload = Map<String, dynamic>.from(record.payload)
            ..remove('id');
          return _remote.updateBatch(id, payload);
        case SyncAction.delete:
          final id = record.entityId ?? record.payload['id'] as int?;
          if (id == null) {
            return ApiResult.failure(
              const ApiFailure(
                type: ApiFailureType.parsing,
                message: 'Missing batch id for offline delete sync.',
              ),
            );
          }
          return _remote.deleteBatch(id);
      }
    });
  }
}
