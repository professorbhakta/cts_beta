import 'package:cts/data/local/dao/cache_dao.dart';
import 'package:cts/data/local/database/app_database.dart';
import 'package:cts/data/local/entity_type.dart';

/// High-level read/write API for cached entity JSON.
class CacheService {
  CacheService({CacheDao? cacheDao})
    : _cacheDao = cacheDao ?? AppDatabase.instance.cacheDao;

  final CacheDao _cacheDao;

  Future<void> replaceAll({
    required EntityType entityType,
    required String adminCode,
    required List<Map<String, dynamic>> rawItems,
  }) {
    return _cacheDao.replaceAllForAdmin(
      entityType: entityType,
      adminCode: adminCode,
      items: rawItems,
    );
  }

  Future<void> upsert({
    required EntityType entityType,
    required String adminCode,
    required Map<String, dynamic> rawItem,
  }) {
    return _cacheDao.upsert(
      entityType: entityType,
      adminCode: adminCode,
      item: rawItem,
    );
  }

  Future<void> deleteById({
    required EntityType entityType,
    required String adminCode,
    required int entityId,
  }) {
    return _cacheDao.deleteById(
      entityType: entityType,
      adminCode: adminCode,
      entityId: entityId,
    );
  }

  Future<List<T>> readAll<T>({
    required EntityType entityType,
    required String adminCode,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    final rows = await _cacheDao.getAllForAdmin(
      entityType: entityType,
      adminCode: adminCode,
    );
    return rows.map(fromJson).toList();
  }
}
