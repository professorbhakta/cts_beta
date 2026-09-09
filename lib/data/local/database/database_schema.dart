/// SQL schema and version for the local SQLite database.
class DatabaseSchema {
  DatabaseSchema._();

  static const String databaseName = 'cts_offline.db';

  /// v1: cache + sync_queue. v2: admin-bootstrap entity tables.
  static const int version = 2;

  static const String cacheTable = 'entity_cache';
  static const String syncQueueTable = 'sync_queue';

  static const String organizationTable = 'organization';
  static const String routeTable = 'route';
  static const String pickUpPointTable = 'pick_up_point';
  static const String batchTable = 'batch';
  static const String cabTable = 'cab';
  static const String driverTable = 'driver';
  static const String commuterTable = 'commuter';
  static const String bootstrapMetaTable = 'bootstrap_meta';

  static const String createCacheTable = '''
    CREATE TABLE $cacheTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      entity_type TEXT NOT NULL,
      entity_id INTEGER NOT NULL,
      admin_code TEXT NOT NULL,
      json_data TEXT NOT NULL,
      updated_at INTEGER NOT NULL,
      UNIQUE(entity_type, entity_id, admin_code)
    )
  ''';

  static const String createCacheIndexes = '''
    CREATE INDEX idx_cache_entity_admin
    ON $cacheTable (entity_type, admin_code);
  ''';

  static const String createSyncQueueTable = '''
    CREATE TABLE $syncQueueTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      entity_type TEXT NOT NULL,
      entity_id INTEGER,
      action TEXT NOT NULL,
      payload TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      retry_count INTEGER NOT NULL DEFAULT 0,
      last_error TEXT
    )
  ''';

  static const String createSyncQueueIndex = '''
    CREATE INDEX idx_sync_queue_created
    ON $syncQueueTable (created_at ASC);
  ''';

  // --- Admin bootstrap tables (snake_case; camelCase mapped on sync) ---

  static const String createOrganizationTable = '''
    CREATE TABLE $organizationTable (
      id TEXT PRIMARY KEY,
      org_name TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT,
      updated_at TEXT
    )
  ''';

  static const String createRouteTable = '''
    CREATE TABLE $routeTable (
      id INTEGER PRIMARY KEY,
      route_name TEXT,
      route_code TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      admin_code TEXT
    )
  ''';

  static const String createPickUpPointTable = '''
    CREATE TABLE $pickUpPointTable (
      id INTEGER PRIMARY KEY,
      pick_up_point_name TEXT,
      route_id INTEGER,
      lat REAL,
      longitude REAL,
      in_line INTEGER,
      area TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      admin_code TEXT
    )
  ''';

  static const String createBatchTable = '''
    CREATE TABLE $batchTable (
      id TEXT PRIMARY KEY,
      batch_name TEXT,
      batch_time TEXT,
      end_time TEXT,
      start_date TEXT,
      end_date TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      admin_code TEXT
    )
  ''';

  static const String createCabTable = '''
    CREATE TABLE $cabTable (
      id INTEGER PRIMARY KEY,
      reg_number TEXT,
      capacity INTEGER,
      route_id INTEGER,
      ac_type TEXT,
      tracking_vehicle_id TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      admin_code TEXT
    )
  ''';

  static const String createDriverTable = '''
    CREATE TABLE $driverTable (
      driver_id INTEGER PRIMARY KEY,
      user_id INTEGER,
      username TEXT,
      mobile_number TEXT,
      batch_id TEXT,
      cab_id INTEGER,
      is_active INTEGER NOT NULL DEFAULT 1,
      admin_code TEXT
    )
  ''';

  static const String createCommuterTable = '''
    CREATE TABLE $commuterTable (
      commuter_id INTEGER PRIMARY KEY,
      user_id INTEGER,
      username TEXT,
      mobile_number TEXT,
      user_type TEXT,
      batch_id TEXT,
      pop_id INTEGER,
      cab_id INTEGER,
      is_coming INTEGER NOT NULL DEFAULT 0,
      has_paid INTEGER,
      is_active INTEGER NOT NULL DEFAULT 1,
      admin_code TEXT
    )
  ''';

  static const String createBootstrapMetaTable = '''
    CREATE TABLE $bootstrapMetaTable (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      status TEXT,
      generated_at TEXT,
      admin_code TEXT,
      trip_date TEXT,
      active_morning_batch_ids TEXT,
      active_return_batch_ids TEXT,
      enum_user_type TEXT,
      enum_ac_type TEXT,
      updated_at INTEGER
    )
  ''';

  static const List<String> bootstrapTableScripts = [
    createOrganizationTable,
    createRouteTable,
    createPickUpPointTable,
    createBatchTable,
    createCabTable,
    createDriverTable,
    createCommuterTable,
    createBootstrapMetaTable,
  ];

  static const List<String> creationScripts = [
    createCacheTable,
    createCacheIndexes,
    createSyncQueueTable,
    createSyncQueueIndex,
    ...bootstrapTableScripts,
  ];

  static const List<String> bootstrapEntityTables = [
    organizationTable,
    routeTable,
    pickUpPointTable,
    batchTable,
    cabTable,
    driverTable,
    commuterTable,
    bootstrapMetaTable,
  ];
}
