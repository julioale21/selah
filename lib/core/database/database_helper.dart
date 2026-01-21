import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = 'selah.db';
  static const int _databaseVersion = 6;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de categorías
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        name TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0,
        is_default INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabla de temas de oración
    // userId preparado para futura migración a auth
    await db.execute('''
      CREATE TABLE prayer_topics (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        category_id TEXT,
        icon_name TEXT NOT NULL,
        prayer_count INTEGER DEFAULT 0,
        answered_count INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        sort_order INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    // Tabla de sesiones de oración
    await db.execute('''
      CREATE TABLE prayer_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        started_at TEXT NOT NULL,
        ended_at TEXT,
        duration_seconds INTEGER DEFAULT 0,
        topics_prayed TEXT,
        notes TEXT,
        mood_before INTEGER,
        mood_after INTEGER
      )
    ''');

    // Tabla de entradas del diario
    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        session_id TEXT,
        topic_id TEXT,
        content TEXT NOT NULL,
        acts_step TEXT,
        type TEXT DEFAULT 'prayer',
        tags TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (session_id) REFERENCES prayer_sessions(id),
        FOREIGN KEY (topic_id) REFERENCES prayer_topics(id)
      )
    ''');

    // Tabla de oraciones respondidas
    await db.execute('''
      CREATE TABLE answered_prayers (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        topic_id TEXT,
        prayer_text TEXT NOT NULL,
        answer_text TEXT,
        prayed_at TEXT NOT NULL,
        answered_at TEXT,
        is_answered INTEGER DEFAULT 0,
        FOREIGN KEY (topic_id) REFERENCES prayer_topics(id)
      )
    ''');

    // Tabla de versículos
    await db.execute('''
      CREATE TABLE verses (
        id TEXT PRIMARY KEY,
        text_es TEXT NOT NULL,
        text_en TEXT,
        reference TEXT NOT NULL,
        book TEXT NOT NULL,
        chapter INTEGER NOT NULL,
        verse_start INTEGER NOT NULL,
        verse_end INTEGER,
        category TEXT NOT NULL,
        tags TEXT
      )
    ''');

    // Tabla de versículos favoritos (por usuario)
    await db.execute('''
      CREATE TABLE favorite_verses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        verse_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (verse_id) REFERENCES verses(id)
      )
    ''');

    // Tabla de versículos del día (historial)
    await db.execute('''
      CREATE TABLE daily_verses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        verse_id TEXT NOT NULL,
        shown_date TEXT NOT NULL,
        FOREIGN KEY (verse_id) REFERENCES verses(id)
      )
    ''');

    // Tabla del planificador
    await db.execute('''
      CREATE TABLE daily_plans (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        topic_ids TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        completed_at TEXT,
        session_id TEXT,
        notes TEXT,
        UNIQUE(user_id, date),
        FOREIGN KEY (session_id) REFERENCES prayer_sessions(id)
      )
    ''');

    // Tabla de configuraciones por usuario
    await db.execute('''
      CREATE TABLE settings (
        user_id TEXT NOT NULL,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        PRIMARY KEY (user_id, key)
      )
    ''');

    // Crear índices para mejorar performance
    await db.execute('CREATE INDEX idx_categories_user ON categories(user_id)');
    await db.execute('CREATE INDEX idx_topics_user ON prayer_topics(user_id)');
    await db.execute('CREATE INDEX idx_topics_category ON prayer_topics(user_id, category_id)');
    await db.execute('CREATE INDEX idx_sessions_user ON prayer_sessions(user_id)');
    await db.execute('CREATE INDEX idx_sessions_date ON prayer_sessions(user_id, started_at)');
    await db.execute('CREATE INDEX idx_journal_user ON journal_entries(user_id)');
    await db.execute('CREATE INDEX idx_verses_category ON verses(category)');
    await db.execute('CREATE INDEX idx_plans_user_date ON daily_plans(user_id, date)');
    await db.execute('CREATE INDEX idx_answered_user ON answered_prayers(user_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Crear tabla de categorías
      await db.execute('''
        CREATE TABLE categories (
          id TEXT PRIMARY KEY,
          user_id TEXT,
          name TEXT NOT NULL,
          icon_name TEXT NOT NULL,
          color_hex TEXT NOT NULL,
          sort_order INTEGER DEFAULT 0,
          is_default INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX idx_categories_user ON categories(user_id)');

      // Agregar category_id a prayer_topics (mantener category para migración)
      await db.execute('ALTER TABLE prayer_topics ADD COLUMN category_id TEXT REFERENCES categories(id)');
    }

    if (oldVersion < 3) {
      // Agregar session_id a daily_plans
      await db.execute('ALTER TABLE daily_plans ADD COLUMN session_id TEXT REFERENCES prayer_sessions(id)');
    }

    if (oldVersion < 4) {
      // Agregar campos type, tags, updated_at a journal_entries
      await db.execute("ALTER TABLE journal_entries ADD COLUMN type TEXT DEFAULT 'prayer'");
      await db.execute('ALTER TABLE journal_entries ADD COLUMN tags TEXT');
      await db.execute('ALTER TABLE journal_entries ADD COLUMN updated_at TEXT');
    }

    if (oldVersion < 5) {
      // Recrear tabla answered_prayers para permitir topic_id NULL
      await db.execute('''
        CREATE TABLE answered_prayers_new (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          topic_id TEXT,
          prayer_text TEXT NOT NULL,
          answer_text TEXT,
          prayed_at TEXT NOT NULL,
          answered_at TEXT,
          is_answered INTEGER DEFAULT 0,
          FOREIGN KEY (topic_id) REFERENCES prayer_topics(id)
        )
      ''');

      // Copiar datos existentes
      await db.execute('''
        INSERT INTO answered_prayers_new
        SELECT id, user_id, topic_id, prayer_text, answer_text, prayed_at, answered_at, is_answered
        FROM answered_prayers
      ''');

      // Eliminar tabla vieja y renombrar nueva
      await db.execute('DROP TABLE answered_prayers');
      await db.execute('ALTER TABLE answered_prayers_new RENAME TO answered_prayers');
    }

    if (oldVersion < 6) {
      // Agregar columna sort_order a prayer_topics
      await db.execute('ALTER TABLE prayer_topics ADD COLUMN sort_order INTEGER DEFAULT 0');
    }
  }

  // Métodos de utilidad

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> count(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return result.first['count'] as int;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete all data for a specific user (useful for logout/account deletion)
  Future<void> deleteUserData(String userId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('settings', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('daily_plans', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('daily_verses', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('favorite_verses', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('answered_prayers', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('journal_entries', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('prayer_sessions', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('prayer_topics', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('categories', where: 'user_id = ?', whereArgs: [userId]);
    });
  }
}
