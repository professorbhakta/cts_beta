import 'package:cts/offline_temp/data/offline_temp_database.dart';
import 'package:sqflite/sqflite.dart';

/// One-time JSON seed for offline temp DB.
///
/// Shape:
/// ```json
/// {
///   "routes": [{"name": "Route A"}],
///   "pops": [{"route": "Route A", "name": "Main Gate"}],
///   "batches": [{"name": "Morning Batch"}],
///   "commuters": [{
///     "batch": "Morning Batch",
///     "pop": "Main Gate",
///     "route": "Route A",
///     "name": "John Doe",
///     "cab": "12",
///     "mobile": "9876543210",
///     "isComing": true
///   }]
/// }
/// ```
class OfflineSeedImporter {
  OfflineSeedImporter({OfflineTempDatabase? database})
    : _database = database ?? OfflineTempDatabase.instance;

  final OfflineTempDatabase _database;

  Future<OfflineSeedResult> import(Map<String, dynamic> data) async {
    final db = _database.db;
    final routes = _asMapList(data['routes']);
    final pops = _asMapList(data['pops']);
    final batches = _asMapList(data['batches']);
    final commuters = _asMapList(data['commuters']);

    return db.transaction((txn) async {
      final routeIds = <String, int>{};
      final popIds = <String, int>{};
      final batchIds = <String, int>{};
      var routesInserted = 0;
      var popsInserted = 0;
      var batchesInserted = 0;
      var commutersInserted = 0;

      for (final row in routes) {
        final name = _reqString(row, 'name');
        final id = await _upsertRoute(txn, name);
        routeIds[name.toLowerCase()] = id;
        routesInserted++;
      }

      for (final row in pops) {
        final routeName = _reqString(row, 'route');
        final popName = _reqString(row, 'name');
        final routeId = routeIds[routeName.toLowerCase()];
        if (routeId == null) {
          throw FormatException('POP "$popName" references unknown route "$routeName"');
        }
        final id = await _upsertPop(txn, routeId: routeId, name: popName);
        popIds['${routeName.toLowerCase()}::${popName.toLowerCase()}'] = id;
        popsInserted++;
      }

      for (final row in batches) {
        final name = _reqString(row, 'name');
        final id = await _upsertBatch(txn, name);
        batchIds[name.toLowerCase()] = id;
        batchesInserted++;
      }

      for (final row in commuters) {
        final batchName = _reqString(row, 'batch');
        final batchId = batchIds[batchName.toLowerCase()];
        if (batchId == null) {
          throw FormatException(
            'Commuter "${row['name']}" references unknown batch "$batchName"',
          );
        }

        int? popId;
        final popName = row['pop']?.toString().trim();
        final routeName = row['route']?.toString().trim();
        if (popName != null &&
            popName.isNotEmpty &&
            routeName != null &&
            routeName.isNotEmpty) {
          popId = popIds['${routeName.toLowerCase()}::${popName.toLowerCase()}'];
        }

        await txn.insert('offline_commuters', {
          'batch_id': batchId,
          'pop_id': popId,
          'name': _reqString(row, 'name'),
          'cab': row['cab']?.toString() ?? '',
          'mobile': row['mobile']?.toString() ?? '',
          'is_coming': _readBool(row['isComing'], defaultValue: true) ? 1 : 0,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
        commutersInserted++;
      }

      return OfflineSeedResult(
        routes: routesInserted,
        pops: popsInserted,
        batches: batchesInserted,
        commuters: commutersInserted,
      );
    });
  }

  Future<int> _upsertRoute(DatabaseExecutor txn, String name) async {
    final existing = await txn.query(
      'offline_routes',
      columns: ['id'],
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [name],
      limit: 1,
    );
    if (existing.isNotEmpty) return existing.first['id'] as int;

    return txn.insert('offline_routes', {
      'name': name,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<int> _upsertPop(
    DatabaseExecutor txn, {
    required int routeId,
    required String name,
  }) async {
    final existing = await txn.query(
      'offline_pops',
      columns: ['id'],
      where: 'route_id = ? AND LOWER(name) = LOWER(?)',
      whereArgs: [routeId, name],
      limit: 1,
    );
    if (existing.isNotEmpty) return existing.first['id'] as int;

    return txn.insert('offline_pops', {
      'route_id': routeId,
      'name': name,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<int> _upsertBatch(DatabaseExecutor txn, String name) async {
    final existing = await txn.query(
      'offline_batches',
      columns: ['id'],
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [name],
      limit: 1,
    );
    if (existing.isNotEmpty) return existing.first['id'] as int;

    return txn.insert('offline_batches', {
      'name': name,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  List<Map<String, dynamic>> _asMapList(Object? value) {
    if (value is! List) return const [];
    return value.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  String _reqString(Map<String, dynamic> row, String key) {
    final value = row[key]?.toString().trim() ?? '';
    if (value.isEmpty) {
      throw FormatException('Missing required field "$key" in seed row: $row');
    }
    return value;
  }

  bool _readBool(Object? value, {required bool defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value.toString().toLowerCase();
    if (text == 'true' || text == 'yes' || text == '1') return true;
    if (text == 'false' || text == 'no' || text == '0') return false;
    return defaultValue;
  }
}

class OfflineSeedResult {
  const OfflineSeedResult({
    required this.routes,
    required this.pops,
    required this.batches,
    required this.commuters,
  });

  final int routes;
  final int pops;
  final int batches;
  final int commuters;

  int get total => routes + pops + batches + commuters;
}
