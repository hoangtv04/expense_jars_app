import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

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
    final uuid = const Uuid();

    // Sử dụng ID cố định "aaa" cho user để đồng bộ với logic bạn đang làm
    const String userId = "aaa";

    // ===== USER =====
    // Chèn một bản ghi user với ID "aaa"
    await db.insert('users', {
      'id': userId,
      'email': 'demo@gmail.com',
      'password': '123456',
    });

    // ===== JAR =====
    final String jarId = uuid.v4(); // Tạo UUID cho hũ
    await db.insert('jars', {
      'id': jarId,
      'user_id': userId,
      'name': 'cash',
      'nameJar': 'Ví tiền mặt',
      'balance': 1000000.0,
      'description': 'Ví chính',
      'is_deleted': 0,
      'created_at': DateTime.now().toIso8601String(),
    });

    // ===== CATEGORY =====
    // 1. Ăn uống
    final String foodCategoryId = uuid.v4();
    await db.insert('categories', {
      'id': foodCategoryId,
      'icon_id': 2,
      'user_id': userId,
      'name': 'Ăn uống',
      'type': 'expense',
    });

    // Danh sách hạng mục con cho Ăn uống
    final List<Map<String, dynamic>> foodSubs = [
      {'name': 'Ăn vặt', 'icon': 3},
      {'name': 'Ăn tối', 'icon': 18},
      {'name': 'Ăn trưa', 'icon': 41},
      {'name': 'Ăn sáng', 'icon': 19},
      {'name': 'Cafe', 'icon': 6},
      {'name': 'Ăn tiệm', 'icon': 1},
      {'name': 'Đi chợ/siêu thị', 'icon': 36},
    ];

    for (var sub in foodSubs) {
      await db.insert('categories', {
        'id': uuid.v4(),
        'icon_id': sub['icon'],
        'user_id': userId,
        'parent_id': foodCategoryId, // UUID của cha
        'name': sub['name'],
        'type': 'expense',
      });
    }

    // 2. Dịch vụ sinh hoạt
    final String serviceId = uuid.v4();
    await db.insert('categories', {
      'id': serviceId,
      'icon_id': 40,
      'user_id': userId,
      'name': 'Dịch vụ sinh hoạt',
      'type': 'expense',
    });

    final List<Map<String, dynamic>> serviceSubs = [
      {'name': 'Thuê người giúp việc', 'icon': 16},
      {'name': 'Điện thoại cố định', 'icon': 30},
      {'name': 'Truyền hình', 'icon': 50},
      {'name': 'Gas', 'icon': 21},
      {'name': 'Điện thoại di động', 'icon': 46},
      {'name': 'Internet', 'icon': 53},
      {'name': 'Nước', 'icon': 52},
      {'name': 'Điện', 'icon': 15},
    ];

    for (var sub in serviceSubs) {
      await db.insert('categories', {
        'id': uuid.v4(),
        'icon_id': sub['icon'],
        'user_id': userId,
        'parent_id': serviceId,
        'name': sub['name'],
        'type': 'expense',
      });
    }

    // 3. Đi lại
    final String travelId = uuid.v4();
    await db.insert('categories', {
      'id': travelId,
      'icon_id': 56,
      'user_id': userId,
      'name': 'Đi lại',
      'type': 'expense',
    });

    final List<Map<String, dynamic>> travelSubs = [
      {'name': 'Taxi/thuê xe', 'icon': 49},
      {'name': 'Rửa xe', 'icon': 14},
      {'name': 'Gửi xe', 'icon': 38},
      {'name': 'Sửa chữa, bảo dưỡng xe', 'icon': 54},
    ];

    for (var sub in travelSubs) {
      await db.insert('categories', {
        'id': uuid.v4(),
        'icon_id': sub['icon'],
        'user_id': userId,
        'parent_id': travelId,
        'name': sub['name'],
        'type': 'expense',
      });
    }

    // 4. Các hạng mục chi tiêu khác (Không có con)
    final List<Map<String, dynamic>> otherExpenses = [
      {'name': 'Con cái', 'icon': 13},
      {'name': 'Trang phục', 'icon': 48},
      {'name': 'Hiếu hỉ', 'icon': 35},
      {'name': 'Sức khỏe', 'icon': 27},
      {'name': 'Nhà cửa', 'icon': 28},
      {'name': 'Hưởng thụ', 'icon': 11},
    ];

    for (var item in otherExpenses) {
      await db.insert('categories', {
        'id': uuid.v4(),
        'icon_id': item['icon'],
        'user_id': userId,
        'name': item['name'],
        'type': 'expense',
      });
    }

    // 5. Hạng mục thu nhập
    final String salaryCategoryId = uuid.v4();
    await db.insert('categories', {
      'id': salaryCategoryId,
      'icon_id': 33,
      'user_id': userId,
      'name': 'Lương',
      'type': 'income',
    });

    // ===== TRANSACTIONS =====
    await db.insert('transactions', {
      'id': uuid.v4(),
      'user_id': userId,
      'jar_id': jarId,
      'category_id': salaryCategoryId,
      'amount': 12000000.0,
      'note': 'Lương tháng',
      'date': '2026-02-01',
      'status': 'completed',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('transactions', {
      'id': uuid.v4(),
      'user_id': userId,
      'jar_id': jarId,
      'category_id': foodCategoryId,
      'amount': 50000.0,
      'note': 'Ăn trưa',
      'date': '2026-02-01',
      'status': 'completed',
      'created_at': DateTime.now().toIso8601String(),
    });

    // ===== JAR LOG =====
    await db.insert('jar_logs', {
      'id': uuid.v4(),
      'jar_id': jarId,
      'change_amount': 12000000.0,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('jar_logs', {
      'id': uuid.v4(),
      'jar_id': jarId,
      'change_amount': -50000.0,
      'created_at': DateTime.now().toIso8601String(),
    });

    print('🌱 Seed data inserted with UUIDs and UserID: "aaa"');
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

    // 1. Bảng users (Dùng UUID từ Supabase Auth)
    await db.execute('''
  CREATE TABLE users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE,
    password TEXT,
    full_name TEXT,
    phone TEXT,
    birth TEXT,
    gender TEXT,
    created_at TEXT
  )
''');

    // 2. Bảng jars
    await db.execute('''
  CREATE TABLE jars (
    id TEXT PRIMARY KEY, 
    user_id TEXT NOT NULL,
    name TEXT NOT NULL,
    nameJar TEXT NOT NULL,
    balance REAL DEFAULT 0,
    description TEXT,
    is_deleted INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  );
  ''');

    // 3. Bảng categories
    await db.execute('''
  CREATE TABLE categories (
    id TEXT PRIMARY KEY, -- Đổi sang TEXT để đồng bộ
    icon_id INTEGER,
    user_id TEXT NOT NULL,
    parent_id TEXT,
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

    // 4. Bảng transactions
    await db.execute('''
  CREATE TABLE transactions (
    id TEXT PRIMARY KEY, 
    user_id TEXT NOT NULL,
    jar_id TEXT NOT NULL,
    category_id TEXT NOT NULL,
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

    // 5. Bảng jar_logs
    await db.execute('''
  CREATE TABLE jar_logs (
    id TEXT PRIMARY KEY, 
    jar_id TEXT NOT NULL,
    transaction_id TEXT,
    change_amount REAL NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (jar_id) REFERENCES jars(id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE SET NULL
  );
  ''');

    // 6. Bảng spending_limits
    await db.execute('''
  CREATE TABLE spending_limits (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    name TEXT NOT NULL,
    amount REAL NOT NULL,
    categories TEXT, 
    accounts TEXT, 
    repeat_frequency TEXT DEFAULT 'Hàng tháng' CHECK (repeat_frequency IN ('Không lặp lại', 'Hàng ngày', 'Hàng tuần', 'Hàng tháng', 'Hàng quý', 'Hàng năm')),
    start_date TEXT NOT NULL,
    end_date TEXT, 
    carry_forward INTEGER DEFAULT 0,
    is_deleted INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  );
  ''');

    // 7. Bảng savings
    await db.execute('''
  CREATE TABLE savings (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        jar_id TEXT,
        name TEXT NOT NULL,
        principal REAL NOT NULL,
        interest_rate REAL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        status TEXT DEFAULT 'active' CHECK (status IN ('active','closed')),
        note TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (jar_id) REFERENCES jars(id) ON DELETE SET NULL
    );
  ''');

    // 8. Bảng saving_logs
    await db.execute('''
  CREATE TABLE saving_logs (
  id TEXT PRIMARY KEY,
  saving_id TEXT NOT NULL,
  transaction_id TEXT,
  change_amount REAL NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('deposit','withdraw','interest','close')),
  note TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (saving_id) REFERENCES savings(id) ON DELETE CASCADE,
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
      columns: ['id', 'email', 'password'], // 🔥 BẮT BUỘC có id
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<void> registerRaw(String email, String password) async {
    final db = await database;

    final id = const Uuid().v4();

    await db.insert('users', {'id': id, 'email': email, 'password': password});
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

  Future<double> getTotalIncome(String userId) async {
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

  Future<double> getTotalExpense(String userId) async {
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

  Future<double> getCurrentBalance(String userId) async {
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

  Future<List<Map<String, dynamic>>> getDailyReport(
    String userId,
    int day,
    int month,
    int year,
  ) async {
    final db = await database;

    return await db.rawQuery(
      '''
    SELECT 
      strftime('%Y-%m-%d', t.date) as period,
      SUM(CASE WHEN c.type = 'income' THEN t.amount ELSE 0 END) as total_income,
      SUM(CASE WHEN c.type = 'expense' THEN t.amount ELSE 0 END) as total_expense
    FROM transactions t
    JOIN categories c ON t.category_id = c.id
    WHERE t.user_id = ?
      AND t.status = 'completed'
      AND t.is_deleted = 0
      AND strftime('%d', t.date) = ?
      AND strftime('%m', t.date) = ?
      AND strftime('%Y', t.date) = ?
    GROUP BY strftime('%Y-%m-%d', t.date)
  ''',
      [
        userId,
        day.toString().padLeft(2, '0'),
        month.toString().padLeft(2, '0'),
        year.toString(),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> getWeeklyReport(
    String userId,
    int month,
    int year,
  ) async {
    final db = await database;

    return await db.rawQuery(
      '''
    SELECT 
      ((CAST(strftime('%d', t.date) AS INTEGER)-1) / 7 + 1) as week,

      SUM(CASE WHEN c.type = 'income' THEN t.amount ELSE 0 END) as total_income,

      SUM(CASE WHEN c.type = 'expense' THEN t.amount ELSE 0 END) as total_expense

    FROM transactions t
    JOIN categories c ON t.category_id = c.id

    WHERE t.user_id = ?
      AND t.status = 'completed'
      AND t.is_deleted = 0
      AND strftime('%m', t.date) = ?
      AND strftime('%Y', t.date) = ?

    GROUP BY week
    ORDER BY week
  ''',
      [userId, month.toString().padLeft(2, '0'), year.toString()],
    );
  }

  Future<List<Map<String, dynamic>>> getMonthlyReport(
    String userId,
    int month,
    int year,
  ) async {
    final db = await database;

    return await db.rawQuery(
      '''
    SELECT 
      strftime('%Y-%m', date) as period,
      SUM(CASE WHEN c.type = 'income' THEN t.amount ELSE 0 END) as total_income,
      SUM(CASE WHEN c.type = 'expense' THEN t.amount ELSE 0 END) as total_expense
    FROM transactions t
    JOIN categories c ON t.category_id = c.id
    WHERE t.user_id = ?
      AND t.status = 'completed'
      AND t.is_deleted = 0
      AND strftime('%m', date) = ?
      AND strftime('%Y', date) = ?
    GROUP BY period
    ORDER BY period
  ''',
      [userId, month.toString().padLeft(2, '0'), year.toString()],
    );
  }

  Future<List<Map<String, dynamic>>> getQuarterReport(String userId) async {
    final db = await database;

    return await db.rawQuery(
      '''
    SELECT 
      strftime('%Y', date) || '-Q' || 
      ((cast(strftime('%m', date) as integer) - 1) / 3 + 1) as period,
      SUM(CASE WHEN c.type = 'income' THEN t.amount ELSE 0 END) as total_income,
      SUM(CASE WHEN c.type = 'expense' THEN t.amount ELSE 0 END) as total_expense
    FROM transactions t
    JOIN categories c ON t.category_id = c.id
    WHERE t.user_id = ?
      AND t.status = 'completed'
      AND t.is_deleted = 0
    GROUP BY period
    ORDER BY period
  ''',
      [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getYearlyReport(String userId) async {
    final db = await database;

    return await db.rawQuery(
      '''
    SELECT 
      strftime('%Y', date) as period,
      SUM(CASE WHEN c.type = 'income' THEN t.amount ELSE 0 END) as total_income,
      SUM(CASE WHEN c.type = 'expense' THEN t.amount ELSE 0 END) as total_expense
    FROM transactions t
    JOIN categories c ON t.category_id = c.id
    WHERE t.user_id = ?
      AND t.status = 'completed'
      AND t.is_deleted = 0
    GROUP BY period
    ORDER BY period
  ''',
      [userId],
    );
  }
}
