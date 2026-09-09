import 'package:cts/data/local/dao/admin_bootstrap_dao.dart';
import 'package:cts/data/local/dao/cache_dao.dart';
import 'package:cts/data/local/dao/sync_queue_dao.dart';
import 'package:cts/data/local/database/database_schema.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Singleton SQLite database for offline cache, sync queue, and admin bootstrap.
class AppDatabase {
  AppDatabase._();

  static AppDatabase? _instance;
  static Database? _database;

  static AppDatabase get instance {
    final db = _instance;
    if (db == null) {
      throw StateError(
        'AppDatabase.initialize() must be called before accessing the database.',
      );
    }
    return db;
  }

  static Future<void> initialize() async {
    if (_instance != null) return;
    _instance = AppDatabase._();
    await _instance!._open();
  }

  Future<void> _open() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, DatabaseSchema.databaseName);

    _database = await openDatabase(
      path,
      version: DatabaseSchema.version,
      onCreate: (db, version) async {
        for (final script in DatabaseSchema.creationScripts) {
          await db.execute(script);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          for (final script in DatabaseSchema.bootstrapTableScripts) {
            await db.execute(script);
          }
        }
        if (oldVersion < 3) {
          // New junction tables (IF NOT EXISTS via try — CREATE TABLE is fine).
          await db.execute(DatabaseSchema.createSubAdminOrganizationTable);
          await db.execute(DatabaseSchema.createSupervisorTable);
          for (final script in DatabaseSchema.v3AlterScripts) {
            try {
              await db.execute(script);
            } on DatabaseException catch (e) {
              // Column already present on fresh v3 installs / re-runs.
              if (!e.toString().contains('duplicate column')) rethrow;
            }
          }
        }
      },
    );
  }

  Database get database {
    final db = _database;
    if (db == null) {
      throw StateError('Database is not open. Call AppDatabase.initialize().');
    }
    return db;
  }

  Database get _db => database;

  CacheDao get cacheDao => CacheDao(_db);

  SyncQueueDao get syncQueueDao => SyncQueueDao(_db);

  AdminBootstrapDao get adminBootstrapDao => AdminBootstrapDao(_db);

  /// Clears cache, sync queue, and bootstrap entity tables. Useful on logout.
  Future<void> clearAll() async {
    final db = _db;
    await db.delete(DatabaseSchema.cacheTable);
    await db.delete(DatabaseSchema.syncQueueTable);
    for (final table in DatabaseSchema.bootstrapEntityTables) {
      await db.delete(table);
    }
  }

  /// Closes the database. Mainly for tests.
  static Future<void> close() async {
    await _database?.close();
    _database = null;
    _instance = null;
  }
}
