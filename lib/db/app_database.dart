import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  // khai bao
  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    
CREATE TABLE member (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  role TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE wallet (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  type TEXT CHECK(type IN ('shared','personal')) NOT NULL,
  balance REAL DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);



CREATE TABLE category (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  type TEXT CHECK(type IN ('income','expense')) NOT NULL,
  icon TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,

  member_id INTEGER NOT NULL,
  wallet_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,

  amount REAL NOT NULL,
  type TEXT CHECK(type IN ('income','expense')) NOT NULL,
  note TEXT,
  date TEXT NOT NULL,

  source TEXT DEFAULT 'manual',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (member_id) REFERENCES member(id),
  FOREIGN KEY (wallet_id) REFERENCES wallet(id),
  FOREIGN KEY (category_id) REFERENCES category(id)
);


    ''');
  }
}
