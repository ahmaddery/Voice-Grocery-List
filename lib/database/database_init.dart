import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseInit {
  static const String _databaseName = 'voice_grocery_list.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String usersTable = 'users';

  // Users table columns
  static const String columnId = 'id';
  static const String columnUsername = 'username';
  static const String columnEmail = 'email';
  static const String columnPassword = 'password';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $usersTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUsername TEXT NOT NULL UNIQUE,
        $columnEmail TEXT NOT NULL UNIQUE,
        $columnPassword TEXT NOT NULL,
        $columnCreatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
        $columnUpdatedAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}