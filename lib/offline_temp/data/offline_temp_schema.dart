/// Shared SQL for offline temp database (v2).
class OfflineTempSchema {
  OfflineTempSchema._();

  static const int version = 2;

  static Future<void> createTables(dynamic db) async {
    await db.execute('''
      CREATE TABLE offline_routes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE COLLATE NOCASE,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE offline_pops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        route_id INTEGER NOT NULL,
        name TEXT NOT NULL COLLATE NOCASE,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (route_id) REFERENCES offline_routes(id) ON DELETE RESTRICT,
        UNIQUE(route_id, name)
      )
    ''');

    await db.execute('''
      CREATE TABLE offline_batches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE offline_commuters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        batch_id INTEGER NOT NULL,
        pop_id INTEGER,
        name TEXT NOT NULL,
        cab TEXT NOT NULL DEFAULT '',
        is_coming INTEGER NOT NULL DEFAULT 1,
        mobile TEXT NOT NULL DEFAULT '',
        created_at INTEGER NOT NULL,
        FOREIGN KEY (batch_id) REFERENCES offline_batches(id) ON DELETE CASCADE,
        FOREIGN KEY (pop_id) REFERENCES offline_pops(id) ON DELETE SET NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_offline_pops_route ON offline_pops(route_id)',
    );
    await db.execute(
      'CREATE INDEX idx_offline_commuters_batch ON offline_commuters(batch_id)',
    );
    await db.execute(
      'CREATE INDEX idx_offline_commuters_pop ON offline_commuters(pop_id)',
    );
  }

  static Future<void> dropAllTables(dynamic db) async {
    await db.execute('DROP TABLE IF EXISTS offline_commuters');
    await db.execute('DROP TABLE IF EXISTS offline_batches');
    await db.execute('DROP TABLE IF EXISTS offline_pops');
    await db.execute('DROP TABLE IF EXISTS offline_routes');
  }
}
