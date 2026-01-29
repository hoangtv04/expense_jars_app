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
    -- ==============================
-- PERSONAL FINANCE DATABASE V3
-- Hỗ trợ danh mục lớn / danh mục con
-- ==============================

-- ========= USERS =========
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,                 -- email đăng nhập
  password TEXT NOT NULL,                     -- mật khẩu (hash ở tầng app)
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- ========= JARS =========
-- Hũ tiền (nơi chứa tiền)
CREATE TABLE jars (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,                   -- thuộc user nào
  name TEXT NOT NULL,                         -- tên hũ
  balance REAL DEFAULT 0,                     -- số dư hiện tại (chỉ để hiển thị nhanh)
  description TEXT,
  is_deleted INTEGER DEFAULT 0,                -- xoá mềm
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE CASCADE
);

-- ========= CATEGORIES =========
-- Danh mục (có thể là danh mục lớn hoặc danh mục con)
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,                   -- thuộc user nào
  parent_id INTEGER,                          -- NULL = danh mục lớn
                                              -- NOT NULL = danh mục con
  name TEXT NOT NULL,                         -- tên danh mục
  type TEXT NOT NULL                          -- income | expense
    CHECK (type IN ('income', 'expense')),
  limit_amount REAL,                          -- hạn mức chi tiêu (áp dụng cho expense)
  description TEXT,
  is_deleted INTEGER DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE CASCADE,

  FOREIGN KEY (parent_id)
    REFERENCES categories(id)
    ON DELETE CASCADE
);

-- ========= TRANSACTIONS =========
-- Giao dịch chi / thu
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,                   -- user thực hiện
  jar_id INTEGER NOT NULL,                    -- hũ tiền
  category_id INTEGER NOT NULL,               -- danh mục CON
  amount REAL NOT NULL,                       -- + thu / - chi
  note TEXT,
  date TEXT NOT NULL,                         -- YYYY-MM-DD
  status TEXT DEFAULT 'completed'
    CHECK (status IN ('completed', 'pending', 'canceled')),
  is_deleted INTEGER DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE CASCADE,
  FOREIGN KEY (jar_id)
    REFERENCES jars(id)
    ON DELETE CASCADE,
  FOREIGN KEY (category_id)
    REFERENCES categories(id)
    ON DELETE CASCADE
);

-- ========= JAR LOGS =========
-- Lịch sử thay đổi số dư hũ tiền
CREATE TABLE jar_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  jar_id INTEGER NOT NULL,
  transaction_id INTEGER,
  change_amount REAL NOT NULL,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (jar_id)
    REFERENCES jars(id)
    ON DELETE CASCADE,
  FOREIGN KEY (transaction_id)
    REFERENCES transactions(id)
    ON DELETE SET NULL
);

-- ========= INDEX =========
CREATE INDEX idx_transactions_user
  ON transactions(user_id);

CREATE INDEX idx_transactions_date
  ON transactions(date);

CREATE INDEX idx_transactions_category
  ON transactions(category_id);

CREATE INDEX idx_categories_parent
  ON categories(parent_id);

    
    ''');
  }
}