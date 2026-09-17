import 'package:cts/data/local/dao/admin_bootstrap_dao.dart';
import 'package:cts/data/local/dao/cache_dao.dart';
import 'package:cts/data/local/dao/sync_queue_dao.dart';
import 'package:cts/data/local/database/database_schema.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Singleton SQLite database for offline cache, sync queue, and admin bootstrap.
///
/// On web, SQLite is skipped — [initialize] still succeeds so the app can boot
/// and use REST/WebSocket. Local cache/sync DAOs become no-ops.
class AppDatabase {
  AppDatabase._();

  static AppDatabase? _instance;
  static Database? _database;

  /// False on web (no `sqflite` backend). Mobile keeps local DB.
  static bool get isSqliteSupported => !kIsWeb;

  static AppDatabase get instance {
    final db = _instance;
    if (db == null) {
      throw StateError(
        'AppDatabase.initialize() must be called before accessing the database.',
      );
    }
    return db;
  }

  /// Null when [initialize] has not run (unit tests / early boot). Prefer this
  /// for best-effort cache clears that must not fail API success paths.
  static AppDatabase? get instanceOrNull => _instance;

  /// Whether a real SQLite connection is open.
  bool get isOpen => _database != null;

  static Future<void> initialize() async {
    if (_instance != null) return;
    _instance = AppDatabase._();
    if (!isSqliteSupported) {
      if (kDebugMode) {
        debugPrint(
          'AppDatabase: skipping SQLite on web — use API (no local cache/sync).',
        );
      }
      return;
    }
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
          await db.execute(DatabaseSchema.createSubAdminOrganizationTable);
          await db.execute(DatabaseSchema.createSupervisorTable);
          for (final script in DatabaseSchema.v3AlterScripts) {
            try {
              await db.execute(script);
            } on DatabaseException catch (e) {
              if (!e.toString().contains('duplicate column')) rethrow;
            }
          }
        }
        if (oldVersion < 4) {
          for (final script in DatabaseSchema.v4AlterScripts) {
            try {
              await db.execute(script);
            } on DatabaseException catch (e) {
              if (!e.toString().contains('duplicate column')) rethrow;
            }
          }
        }
      },
    );
  }

  /// Open DB, or null when SQLite was skipped (web).
  Database? get databaseOrNull => _database;

  Database get database {
    final db = _database;
    if (db == null) {
      throw StateError(
        'Database is not open (SQLite unavailable on this platform). '
        'Call AppDatabase.initialize() on mobile, or use the API on web.',
      );
    }
    return db;
  }

  CacheDao get cacheDao =>
      _database == null ? CacheDao.noop() : CacheDao(_database!);

  SyncQueueDao get syncQueueDao =>
      _database == null ? SyncQueueDao.noop() : SyncQueueDao(_database!);

  AdminBootstrapDao get adminBootstrapDao => AdminBootstrapDao(_database);

  /// Clears cache, sync queue, and bootstrap entity tables. Useful on logout.
  /// No-op when SQLite was skipped (web).
  Future<void> clearAll() async {
    final db = _database;
    if (db == null) return;
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
