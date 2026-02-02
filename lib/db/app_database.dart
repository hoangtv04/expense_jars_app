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


  Future<void> _seedData(Database db) async {
    // ===== USER =====
    final userId = await db.insert('users', {
      'email': 'demo@gmail.com',
      'password': '123456',
    });

    // ===== JAR =====
    final jarId = await db.insert('jars', {
      'user_id': userId,
      'name': 'cash', // JarType.cash.name
      'balance': 1000000.0,
      'description': 'Ví chính',
      'is_deleted': 0,
      'created_at': DateTime.now().toIso8601String(),
    });

    // ===== CATEGORY =====
    final foodCategoryId = await db.insert('categories', {
      'user_id': userId,
      'name': 'Ăn uống',
      'type': 'expense',
    });

    final salaryCategoryId = await db.insert('categories', {
      'user_id': userId,
      'name': 'Lương',
      'type': 'income',
    });

    // ===== TRANSACTIONS =====
    await db.insert('transactions', {
      'user_id': userId,
      'jar_id': jarId,
      'category_id': salaryCategoryId,
      'amount': 12000000.0,
      'note': 'Lương tháng',
      'date': '2026-02-01',
      'status': 'completed',
    });

    await db.insert('transactions', {
      'user_id': userId,
      'jar_id': jarId,
      'category_id': foodCategoryId,
      'amount': 50000.0,
      'note': 'Ăn trưa',
      'date': '2026-02-01',
      'status': 'completed',
    });

    // ===== JAR LOG =====
    await db.insert('jar_logs', {
      'jar_id': jarId,
      'change_amount': 12000000.0,
    });

    await db.insert('jar_logs', {
      'jar_id': jarId,
      'change_amount': -50000.0,
    });

    print('🌱 Seed data inserted');
  }


  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );

    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
    );
    print('📦 TABLES IN DB: $tables');

    return db;
  }
  Future _createDB(Database db, int version) async {
    print(' Creating database...');

    await db.execute('''
  CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
  );
  ''');

    await db.execute('''
  CREATE TABLE jars (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    balance REAL DEFAULT 0,
    description TEXT,
    is_deleted INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  );
  ''');

    await db.execute('''
  CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    parent_id INTEGER,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
    limit_amount REAL,
    description TEXT,
    is_deleted INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE CASCADE
  );
  ''');

    await db.execute('''
  CREATE TABLE transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    jar_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    amount REAL NOT NULL,
    note TEXT,
    date TEXT NOT NULL,
    status TEXT DEFAULT 'completed'
      CHECK (status IN ('completed', 'pending', 'canceled')),
    is_deleted INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (jar_id) REFERENCES jars(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
  );
  ''');

    await db.execute('''
  CREATE TABLE jar_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    jar_id INTEGER NOT NULL,
    transaction_id INTEGER,
    change_amount REAL NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (jar_id) REFERENCES jars(id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE SET NULL
  );
  ''');

    await db.execute(
        'CREATE INDEX idx_transactions_user ON transactions(user_id)');
    await db.execute(
        'CREATE INDEX idx_transactions_date ON transactions(date)');
    await db.execute(
        'CREATE INDEX idx_transactions_category ON transactions(category_id)');
    await db.execute(
        'CREATE INDEX idx_categories_parent ON categories(parent_id)');
    await   _seedData(db);
    print('Database created successfully');
  }

}