import 'package:cts/offline_temp/data/offline_temp_schema.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class OfflineTempDatabase {
  OfflineTempDatabase._();

  static OfflineTempDatabase? _instance;
  static Database? _database;

  static const String dbName = 'cts_offline_temp.db';

  static OfflineTempDatabase get instance {
    final db = _instance;
    if (db == null) {
      throw StateError(
        'OfflineTempDatabase.initialize() must be called before use.',
      );
    }
    return db;
  }

  static Future<void> initialize() async {
    if (_instance != null) return;
    _instance = OfflineTempDatabase._();
    await _instance!._open();
  }

  Future<void> _open() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, dbName);

    _database = await openDatabase(
      path,
      version: OfflineTempSchema.version,
      onCreate: (db, version) => OfflineTempSchema.createTables(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await OfflineTempSchema.dropAllTables(db);
          await OfflineTempSchema.createTables(db);
        }
      },
    );
  }

  Database get db {
    final database = _database;
    if (database == null) {
      throw StateError('Offline temp database is not open.');
    }
    return database;
  }
}
