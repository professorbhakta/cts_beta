import 'package:cts/data/local/database/database_schema.dart';
import 'package:cts/data/local/models/sync_queue_record.dart';
import 'package:sqflite/sqflite.dart';

class SyncQueueDao {
  SyncQueueDao(this._db);

  final Database _db;

  Future<int> enqueue(SyncQueueRecord record) async {
    return _db.insert(
      DatabaseSchema.syncQueueTable,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SyncQueueRecord>> getPending({
    int limit = 50,
    int maxRetries = 5,
  }) async {
    final rows = await _db.query(
      DatabaseSchema.syncQueueTable,
      where: 'retry_count < ?',
      whereArgs: [maxRetries],
      orderBy: 'created_at ASC',
      limit: limit,
    );

    return rows.map(SyncQueueRecord.fromMap).toList();
  }

  Future<void> deleteById(int id) async {
    await _db.delete(
      DatabaseSchema.syncQueueTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markFailed({
    required int id,
    required String error,
    required int retryCount,
  }) async {
    await _db.update(
      DatabaseSchema.syncQueueTable,
      {
        'retry_count': retryCount,
        'last_error': error,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> pendingCount({int maxRetries = 5}) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseSchema.syncQueueTable} '
      'WHERE retry_count < ?',
      [maxRetries],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> failedCount({int maxRetries = 5}) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseSchema.syncQueueTable} '
      'WHERE retry_count >= ?',
      [maxRetries],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
