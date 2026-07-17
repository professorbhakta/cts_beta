import 'dart:convert';

import 'package:cts/data/local/database/database_schema.dart';
import 'package:cts/data/local/entity_type.dart';
import 'package:sqflite/sqflite.dart';

class CacheDao {
  CacheDao(this._db);

  final Database _db;

  Future<void> replaceAllForAdmin({
    required EntityType entityType,
    required String adminCode,
    required List<Map<String, dynamic>> items,
  }) async {
    await _db.transaction((txn) async {
      await txn.delete(
        DatabaseSchema.cacheTable,
        where: 'entity_type = ? AND admin_code = ?',
        whereArgs: [entityType.storageKey, adminCode],
      );

      final now = DateTime.now().millisecondsSinceEpoch;
      for (final item in items) {
        final entityId = _readEntityId(item);
        if (entityId == null) continue;

        await txn.insert(
          DatabaseSchema.cacheTable,
          {
            'entity_type': entityType.storageKey,
            'entity_id': entityId,
            'admin_code': adminCode,
            'json_data': jsonEncode(item),
            'updated_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> upsert({
    required EntityType entityType,
    required String adminCode,
    required Map<String, dynamic> item,
  }) async {
    final entityId = _readEntityId(item);
    if (entityId == null) return;

    await _db.insert(
      DatabaseSchema.cacheTable,
      {
        'entity_type': entityType.storageKey,
        'entity_id': entityId,
        'admin_code': adminCode,
        'json_data': jsonEncode(item),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteById({
    required EntityType entityType,
    required String adminCode,
    required int entityId,
  }) async {
    await _db.delete(
      DatabaseSchema.cacheTable,
      where: 'entity_type = ? AND admin_code = ? AND entity_id = ?',
      whereArgs: [entityType.storageKey, adminCode, entityId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllForAdmin({
    required EntityType entityType,
    required String adminCode,
  }) async {
    final rows = await _db.query(
      DatabaseSchema.cacheTable,
      where: 'entity_type = ? AND admin_code = ?',
      whereArgs: [entityType.storageKey, adminCode],
      orderBy: 'updated_at DESC',
    );

    return rows
        .map(
          (row) =>
              jsonDecode(row['json_data'] as String) as Map<String, dynamic>,
        )
        .toList();
  }

  int? _readEntityId(Map<String, dynamic> item) {
    final id = item['id'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }
}
