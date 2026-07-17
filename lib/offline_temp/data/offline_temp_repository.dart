import 'package:cts/offline_temp/data/offline_temp_database.dart';
import 'package:cts/offline_temp/models/offline_batch.dart';
import 'package:cts/offline_temp/models/offline_commuter.dart';
import 'package:cts/offline_temp/models/offline_commuter_filter.dart';
import 'package:cts/offline_temp/models/offline_pop.dart';
import 'package:cts/offline_temp/models/offline_route.dart';
import 'package:sqflite/sqflite.dart';

class OfflineTempRepository {
  OfflineTempRepository({OfflineTempDatabase? database})
    : _database = database ?? OfflineTempDatabase.instance;

  final OfflineTempDatabase _database;

  static const _commuterSelect = '''
    SELECT
      c.*,
      b.name AS batch_name,
      p.name AS pop_name,
      r.name AS route_name
    FROM offline_commuters c
    INNER JOIN offline_batches b ON b.id = c.batch_id
    LEFT JOIN offline_pops p ON p.id = c.pop_id
    LEFT JOIN offline_routes r ON r.id = p.route_id
  ''';

  // --- Routes ---

  Future<List<OfflineRoute>> getRoutes() async {
    final rows = await _database.db.rawQuery('''
      SELECT r.*, COUNT(p.id) AS pop_count
      FROM offline_routes r
      LEFT JOIN offline_pops p ON p.route_id = r.id
      GROUP BY r.id
      ORDER BY r.name COLLATE NOCASE ASC
    ''');
    return rows.map(OfflineRoute.fromMap).toList();
  }

  Future<int> insertRoute(String name) async {
    return _database.db.insert('offline_routes', {
      'name': name.trim(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> updateRoute(int id, String name) async {
    await _database.db.update(
      'offline_routes',
      {'name': name.trim()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteRoute(int id) async {
    await _database.db.delete(
      'offline_routes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- POPs ---

  Future<List<OfflinePop>> getAllPops() async {
    final rows = await _database.db.rawQuery('''
      SELECT p.*, r.name AS route_name, COUNT(c.id) AS commuter_count
      FROM offline_pops p
      INNER JOIN offline_routes r ON r.id = p.route_id
      LEFT JOIN offline_commuters c ON c.pop_id = p.id
      GROUP BY p.id
      ORDER BY r.name COLLATE NOCASE ASC, p.name COLLATE NOCASE ASC
    ''');
    return rows.map(OfflinePop.fromMap).toList();
  }

  Future<List<OfflinePop>> getPopsByRoute(int routeId) async {
    final rows = await _database.db.rawQuery(
      '''
      SELECT p.*, r.name AS route_name, COUNT(c.id) AS commuter_count
      FROM offline_pops p
      INNER JOIN offline_routes r ON r.id = p.route_id
      LEFT JOIN offline_commuters c ON c.pop_id = p.id
      WHERE p.route_id = ?
      GROUP BY p.id
      ORDER BY p.name COLLATE NOCASE ASC
      ''',
      [routeId],
    );
    return rows.map(OfflinePop.fromMap).toList();
  }

  Future<int> insertPop({required int routeId, required String name}) async {
    return _database.db.insert('offline_pops', {
      'route_id': routeId,
      'name': name.trim(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> updatePop(int id, String name) async {
    await _database.db.update(
      'offline_pops',
      {'name': name.trim()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletePop(int id) async {
    await _database.db.delete(
      'offline_pops',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Batches ---

  Future<List<OfflineBatch>> getBatches() async {
    final rows = await _database.db.rawQuery('''
      SELECT b.*, COUNT(c.id) AS commuter_count
      FROM offline_batches b
      LEFT JOIN offline_commuters c ON c.batch_id = b.id
      GROUP BY b.id
      ORDER BY b.created_at DESC
    ''');
    return rows.map(OfflineBatch.fromMap).toList();
  }

  Future<OfflineBatch?> getBatchById(int id) async {
    final rows = await _database.db.rawQuery(
      '''
      SELECT b.*, COUNT(c.id) AS commuter_count
      FROM offline_batches b
      LEFT JOIN offline_commuters c ON c.batch_id = b.id
      WHERE b.id = ?
      GROUP BY b.id
      ''',
      [id],
    );
    if (rows.isEmpty) return null;
    return OfflineBatch.fromMap(rows.first);
  }

  Future<int> insertBatch(String name) async {
    return _database.db.insert('offline_batches', {
      'name': name.trim(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> updateBatch(int id, String name) async {
    await _database.db.update(
      'offline_batches',
      {'name': name.trim()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteBatch(int id) async {
    await _database.db.delete(
      'offline_batches',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Commuters ---

  Future<List<OfflineCommuter>> getCommutersByBatch(int batchId) async {
    final rows = await _database.db.rawQuery(
      '''
      $_commuterSelect
      WHERE c.batch_id = ?
      ORDER BY c.name COLLATE NOCASE ASC
      ''',
      [batchId],
    );
    return rows.map(OfflineCommuter.fromMap).toList();
  }

  Future<List<OfflineCommuter>> getAllCommuters({
    OfflineCommuterFilter filter = OfflineCommuterFilter.empty,
  }) async {
    final where = <String>[];
    final args = <Object?>[];

    if (filter.batchId != null) {
      where.add('c.batch_id = ?');
      args.add(filter.batchId);
    }
    if (filter.routeId != null) {
      where.add('p.route_id = ?');
      args.add(filter.routeId);
    }
    if (filter.popId != null) {
      where.add('c.pop_id = ?');
      args.add(filter.popId);
    }
    if (filter.cab != null && filter.cab!.isNotEmpty) {
      where.add('LOWER(c.cab) = LOWER(?)');
      args.add(filter.cab);
    }
    if (filter.isComing != null) {
      where.add('c.is_coming = ?');
      args.add(filter.isComing! ? 1 : 0);
    }
    if (filter.hasPop == true) {
      where.add('c.pop_id IS NOT NULL');
    } else if (filter.hasPop == false) {
      where.add('c.pop_id IS NULL');
    }
    if (filter.hasMobile == true) {
      where.add("TRIM(c.mobile) != ''");
    } else if (filter.hasMobile == false) {
      where.add("(c.mobile IS NULL OR TRIM(c.mobile) = '')");
    }
    if (filter.searchQuery.isNotEmpty) {
      where.add('''
        (
          LOWER(c.name) LIKE LOWER(?) OR
          CAST(c.id AS TEXT) LIKE ? OR
          LOWER(c.mobile) LIKE LOWER(?)
        )
      ''');
      final q = '%${filter.searchQuery.trim()}%';
      args.addAll([q, q, q]);
    }

    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final rows = await _database.db.rawQuery(
      '''
      $_commuterSelect
      $whereClause
      ORDER BY b.name COLLATE NOCASE ASC, c.name COLLATE NOCASE ASC
      ''',
      args,
    );

    return rows.map(OfflineCommuter.fromMap).toList();
  }

  Future<List<String>> getDistinctCabs({int? batchId}) async {
    final where = <String>["TRIM(cab) != ''"];
    final args = <Object?>[];

    if (batchId != null) {
      where.add('batch_id = ?');
      args.add(batchId);
    }

    final rows = await _database.db.rawQuery('''
      SELECT DISTINCT cab AS value
      FROM offline_commuters
      WHERE ${where.join(' AND ')}
      ORDER BY value COLLATE NOCASE ASC
    ''', args);
    return rows
        .map((row) => (row['value'] as String?)?.trim() ?? '')
        .where((value) => value.isNotEmpty)
        .toList();
  }

  Future<int> insertCommuter(OfflineCommuter commuter) async {
    return _database.db.insert(
      'offline_commuters',
      commuter.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCommuter(OfflineCommuter commuter) async {
    if (commuter.id == null) return;
    await _database.db.update(
      'offline_commuters',
      commuter.toMap(),
      where: 'id = ?',
      whereArgs: [commuter.id],
    );
  }

  Future<void> deleteCommuter(int id) async {
    await _database.db.delete(
      'offline_commuters',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleIsComing(int id, bool isComing) async {
    await _database.db.update(
      'offline_commuters',
      {'is_coming': isComing ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isMobileUsedInBatch(
    int batchId,
    String mobile, {
    int? excludeCommuterId,
  }) async {
    final trimmed = mobile.trim();
    if (trimmed.isEmpty) return false;

    final where = <String>['batch_id = ?', 'mobile = ?'];
    final args = <Object?>[batchId, trimmed];

    if (excludeCommuterId != null) {
      where.add('id != ?');
      args.add(excludeCommuterId);
    }

    final rows = await _database.db.query(
      'offline_commuters',
      columns: ['id'],
      where: where.join(' AND '),
      whereArgs: args,
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<bool> routeNameExists(String name, {int? excludeRouteId}) async {
    final where = <String>['LOWER(name) = LOWER(?)'];
    final args = <Object?>[name.trim()];

    if (excludeRouteId != null) {
      where.add('id != ?');
      args.add(excludeRouteId);
    }

    final rows = await _database.db.query(
      'offline_routes',
      columns: ['id'],
      where: where.join(' AND '),
      whereArgs: args,
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<bool> batchNameExists(String name, {int? excludeBatchId}) async {
    final where = <String>['LOWER(name) = LOWER(?)'];
    final args = <Object?>[name.trim()];

    if (excludeBatchId != null) {
      where.add('id != ?');
      args.add(excludeBatchId);
    }

    final rows = await _database.db.query(
      'offline_batches',
      columns: ['id'],
      where: where.join(' AND '),
      whereArgs: args,
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<bool> popNameExistsOnRoute(
    int routeId,
    String name, {
    int? excludePopId,
  }) async {
    final where = <String>['route_id = ?', 'LOWER(name) = LOWER(?)'];
    final args = <Object?>[routeId, name.trim()];

    if (excludePopId != null) {
      where.add('id != ?');
      args.add(excludePopId);
    }

    final rows = await _database.db.query(
      'offline_pops',
      columns: ['id'],
      where: where.join(' AND '),
      whereArgs: args,
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<bool> hasAnyData() async {
    final result = await _database.db.rawQuery('''
      SELECT
        (SELECT COUNT(*) FROM offline_routes) +
        (SELECT COUNT(*) FROM offline_batches) +
        (SELECT COUNT(*) FROM offline_commuters) AS total
    ''');
    return (result.first['total'] as int? ?? 0) > 0;
  }

  Future<void> clearAllData() async {
    final db = _database.db;
    await db.transaction((txn) async {
      await txn.delete('offline_commuters');
      await txn.delete('offline_pops');
      await txn.delete('offline_batches');
      await txn.delete('offline_routes');
    });
  }
}
