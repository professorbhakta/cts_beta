import 'package:cts/data/local/dao/cache_dao.dart';
import 'package:cts/data/local/dao/sync_queue_dao.dart';
import 'package:cts/data/local/database/database_schema.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Singleton SQLite database for offline cache and sync queue.
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
        // Add migration steps here when schema version increases.
      },
    );
  }

  Database get _db {
    final database = _database;
    if (database == null) {
      throw StateError('Database is not open. Call AppDatabase.initialize().');
    }
    return database;
  }

  CacheDao get cacheDao => CacheDao(_db);

  SyncQueueDao get syncQueueDao => SyncQueueDao(_db);

  /// Clears all local data. Useful on logout.
  Future<void> clearAll() async {
    final db = _db;
    await db.delete(DatabaseSchema.cacheTable);
    await db.delete(DatabaseSchema.syncQueueTable);
  }

  /// Closes the database. Mainly for tests.
  static Future<void> close() async {
    await _database?.close();
    _database = null;
    _instance = null;
  }
}
