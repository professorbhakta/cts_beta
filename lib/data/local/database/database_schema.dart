/// SQL schema and version for the local SQLite database.
class DatabaseSchema {
  DatabaseSchema._();

  static const String databaseName = 'cts_offline.db';
  static const int version = 1;

  static const String cacheTable = 'entity_cache';
  static const String syncQueueTable = 'sync_queue';

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

  static const List<String> creationScripts = [
    createCacheTable,
    createCacheIndexes,
    createSyncQueueTable,
    createSyncQueueIndex,
  ];
}
