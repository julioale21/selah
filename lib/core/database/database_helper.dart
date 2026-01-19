import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'selah.db';
  static const int _databaseVersion = 1;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Prayer Topics table
    await db.execute('''
      CREATE TABLE prayer_topics (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        icon_name TEXT,
        color_hex TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Prayer Sessions table
    await db.execute('''
      CREATE TABLE prayer_sessions (
        id TEXT PRIMARY KEY,
        started_at TEXT NOT NULL,
        ended_at TEXT,
        duration_seconds INTEGER,
        acts_completed TEXT,
        notes TEXT,
        topics_prayed TEXT
      )
    ''');

    // Daily Plans table
    await db.execute('''
      CREATE TABLE daily_plans (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL UNIQUE,
        topic_ids TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        session_id TEXT,
        FOREIGN KEY (session_id) REFERENCES prayer_sessions(id)
      )
    ''');

    // Journal Entries table
    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        topic_id TEXT,
        session_id TEXT,
        is_answered INTEGER DEFAULT 0,
        answered_at TEXT,
        answered_notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (topic_id) REFERENCES prayer_topics(id),
        FOREIGN KEY (session_id) REFERENCES prayer_sessions(id)
      )
    ''');

    // User Preferences table
    await db.execute('''
      CREATE TABLE user_preferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
