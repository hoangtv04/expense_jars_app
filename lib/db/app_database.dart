import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/Jar.dart';

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

    final jarId = await db.insert('jars', {
      'user_id': userId,
      'nameJar': 'Ví chính',
      'name': JarType.cash.name,
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

    // Subcategories for Ăn uống
    await db.insert('categories', {
      'user_id': userId,
      'parent_id': foodCategoryId,
      'name': 'Ăn vặt',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': foodCategoryId,
      'name': 'Ăn tối',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': foodCategoryId,
      'name': 'Ăn trưa',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': foodCategoryId,
      'name': 'Ăn sáng',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': foodCategoryId,
      'name': 'Cafe',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': foodCategoryId,
      'name': 'Ăn tiệm',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': foodCategoryId,
      'name': 'Đi chợ/siêu thị',
      'type': 'expense',
    });

    final serviceId = await db.insert('categories', {
      'user_id': userId,
      'name': 'Dịch vụ sinh hoạt',
      'type': 'expense',
    });

    // Subcategories for Dịch vụ sinh hoạt
    await db.insert('categories', {
      'user_id': userId,
      'parent_id': serviceId,
      'name': 'Thuê người giúp việc',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': serviceId,
      'name': 'Điện thoại cố định',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': serviceId,
      'name': 'Truyền hình',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': serviceId,
      'name': 'Gas',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': serviceId,
      'name': 'Điện thoại di động',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': serviceId,
      'name': 'Internet',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': serviceId,
      'name': 'Nước',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': serviceId,
      'name': 'Điện',
      'type': 'expense',
    });

    final travelId = await db.insert('categories', {
      'user_id': userId,
      'name': 'Đi lại',
      'type': 'expense',
    });

    // Subcategories for Đi lại
    await db.insert('categories', {
      'user_id': userId,
      'parent_id': travelId,
      'name': 'Taxi/thuê xe',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': travelId,
      'name': 'Rửa xe',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': travelId,
      'name': 'Gửi xe',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'parent_id': travelId,
      'name': 'Sửa chữa, bảo dưỡng xe',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'name': 'Con cái',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'name': 'Trang phục',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'name': 'Hiếu hỉ',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'name': 'Sức khỏe',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'name': 'Nhà cửa',
      'type': 'expense',
    });

    await db.insert('categories', {
      'user_id': userId,
      'name': 'Hưởng thụ',
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
    await db.insert('jar_logs', {'jar_id': jarId, 'change_amount': 12000000.0});

    await db.insert('jar_logs', {'jar_id': jarId, 'change_amount': -50000.0});

    print('🌱 Seed data inserted');
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    final db = await openDatabase(path, version: 1, onCreate: _createDB);

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
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
    nameJar TEXT NOT NULL,
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
      'CREATE INDEX idx_transactions_user ON transactions(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_date ON transactions(date)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_category ON transactions(category_id)',
    );
    await db.execute(
      'CREATE INDEX idx_categories_parent ON categories(parent_id)',
    );
    await _seedData(db);
    print('Database created successfully');
  }

  Future<Map<String, dynamic>?> loginRaw(String email, String password) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<int> registerRaw(String email, String password) async {
    final db = await database;

    return await db.insert('users', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<bool> isEmailExists(String email) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<void> resetUsersTable() async {
    final db = await database;
    await db.delete('users');
    await db.rawDelete("DELETE FROM sqlite_sequence WHERE name = 'users'");
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'id ASC');
  }

  Future<void> updatePasswordByEmail(String email, String newPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<double> getTotalIncome(int userId) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT SUM(t.amount) as total
    FROM transactions t
    JOIN categories c ON t.category_id = c.id
    WHERE t.user_id = ?
      AND c.type = 'income'
      AND t.status = 'completed'
      AND t.is_deleted = 0
  ''',
      [userId],
    );

    final value = result.first['total'];
    return value == null ? 0.0 : (value as num).toDouble();
  }

  Future<double> getTotalExpense(int userId) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT SUM(t.amount) as total
    FROM transactions t
    JOIN categories c ON t.category_id = c.id
    WHERE t.user_id = ?
      AND c.type = 'expense'
      AND t.status = 'completed'
      AND t.is_deleted = 0
  ''',
      [userId],
    );

    final value = result.first['total'];
    return value == null ? 0.0 : (value as num).toDouble();
  }

  Future<double> getCurrentBalance(int userId) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT SUM(balance) as total
    FROM jars
    WHERE user_id = ?
      AND is_deleted = 0
  ''',
      [userId],
    );

    final value = result.first['total'];
    return value == null ? 0.0 : (value as num).toDouble();
  }
}
