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

    // 1. TẠO USER ID CHUẨN UUID (Thay vì "aaa")
    final String userId = uuid.v4();

    // Chèn một bản ghi user
    await db.insert('users', {
      'id': userId,
      'email': 'duc.cuong@gmail.com',
      'password': 'password123',
    });

    // 2. ===== JAR =====
    final String jarId = uuid.v4();
    await db.insert('jars', {
      'id': jarId,
      'user_id': userId,
      'name': 'cash',
      'nameJar': 'Ví tiền mặt',
      'balance': 1000000.0,
      'description': 'Ví chính',
      'is_synced': 0, // Nhớ để 0 để nó bắt đầu sync lên Supabase
      'is_deleted': 0,
      'created_at': DateTime.now().toIso8601String(),
    });

    // 3. ===== CATEGORIES =====
    // --- Nhóm Ăn uống ---
    final String foodCategoryId = uuid.v4();
    await db.insert('categories', {
      'id': foodCategoryId,
      'icon_id': 2,
      'user_id': userId,
      'name': 'Ăn uống',
      'type': 'expense',
      'is_synced': 0,
    });

    final List<Map<String, dynamic>> foodSubs = [
      {'name': 'Ăn vặt', 'icon': 3},
      {'name': 'Ăn tối', 'icon': 18},
      {'name': 'Ăn trưa', 'icon': 41},
    ];

    for (var sub in foodSubs) {
      await db.insert('categories', {
        'id': uuid.v4(),
        'icon_id': sub['icon'],
        'user_id': userId,
        'parent_id': foodCategoryId,
        'name': sub['name'],
        'type': 'expense',
        'is_synced': 0,
      });
    }

    // --- Nhóm Thu nhập ---
    final String salaryCategoryId = uuid.v4();
    await db.insert('categories', {
      'id': salaryCategoryId,
      'icon_id': 33,
      'user_id': userId,
      'name': 'Lương',
      'type': 'income',
      'is_synced': 0,
    });

    // 4. ===== TRANSACTIONS =====
    final String transId = uuid.v4();
    await db.insert('transactions', {
      'id': transId,
      'user_id': userId,
      'jar_id': jarId,
      'category_id': salaryCategoryId,
      'amount': 12000000.0,
      'note': 'Lương tháng 3',
      'date': '2026-03-21',
      'status': 'completed',
      'is_synced': 0,
      'created_at': DateTime.now().toIso8601String(),
    });

    // 5. ===== JAR LOG =====
    await db.insert('jar_logs', {
      'id': uuid.v4(),
      'jar_id': jarId,
      'transaction_id': transId,
      'change_amount': 12000000.0,
      'is_synced': 0,
      'created_at': DateTime.now().toIso8601String(),
    });

    print('✅ Đã khởi tạo dữ liệu mẫu với UUID chuẩn: $userId');
  }


  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    final db = await openDatabase(path, version: 1, onCreate: _createDB);

    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
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
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
  );
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
    is_synced INTEGER DEFAULT 0,
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
    is_synced INTEGER DEFAULT 0,
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
      is_synced INTEGER DEFAULT 0,
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
    is_synced INTEGER DEFAULT 0,
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
    is_synced INTEGER DEFAULT 0,
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
        is_synced INTEGER DEFAULT 0,
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
  is_synced INTEGER DEFAULT 0,
  FOREIGN KEY (saving_id) REFERENCES savings(id) ON DELETE CASCADE,
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
      [
        userId,
        month.toString().padLeft(2, '0'),
        year.toString(),
      ],
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

  Future<List<Map<String, dynamic>>> getQuarterReport(
    String userId,
    int month,
    int year,
  ) async {
    final db = await database;
    int startMonth = ((month - 1) ~/ 3) * 3 + 1;
    int endMonth = startMonth + 2;
    return await db.rawQuery(
      '''
  SELECT 
    'Q' || CAST((? - 1) / 3 + 1 AS INTEGER) || '-' || ? as period,
    COALESCE(SUM(CASE WHEN c.type = 'income' THEN t.amount ELSE 0 END), 0) as total_income,
    COALESCE(SUM(CASE WHEN c.type = 'expense' THEN t.amount ELSE 0 END), 0) as total_expense
  FROM transactions t
  JOIN categories c ON t.category_id = c.id
  WHERE t.user_id = ?
    AND t.is_deleted = 0
    AND strftime('%Y', t.date) = ?
    AND CAST(strftime('%m', t.date) AS INTEGER) BETWEEN ? AND ?
  ''',
      [month, year.toString(), userId, year.toString(), startMonth, endMonth],
    );
  }

  Future<Map<String, dynamic>> getYearlyTotal(String userId, int year) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT
      COALESCE(SUM(CASE WHEN c.type = 'income' THEN t.amount ELSE 0 END), 0) AS total_income,
      COALESCE(SUM(CASE WHEN c.type = 'expense' THEN t.amount ELSE 0 END), 0) AS total_expense
    FROM transactions t
    JOIN categories c ON t.category_id = c.id
    WHERE t.user_id = ?
      AND t.status = 'completed'
      AND t.is_deleted = 0
      AND strftime('%Y', t.date) = ?
    ''',
      [userId, year.toString()],
    );

    // 1. Kiểm tra nếu có dữ liệu
    if (result.isNotEmpty && result.first['total_income'] != null) {
      final row = result.first;
      return {
        'total_income': (row['total_income'] as num).toDouble(),
        'total_expense': (row['total_expense'] as num).toDouble(),
      };
    }


    return {
      'total_income': 0.0,
      'total_expense': 0.0,
    };
  }
  /// 1. Lấy danh sách các bản ghi "bẩn" (chưa đồng bộ)
  Future<List<Map<String, dynamic>>> getUnsyncedRecords(String tableName) async {
    final db = await instance.database;

    // Chỉ lấy những dòng có is_synced = 0 và KHÔNG bị xóa vĩnh viễn
    return await db.query(
      tableName,
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }

  /// 2. Cập nhật trạng thái sau khi đã đẩy lên Cloud thành công
  Future<int> updateSyncStatus(String tableName, String id, int status) async {
    final db = await instance.database;

    return await db.update(
      tableName,
      {'is_synced': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 3. (Tùy chọn) Hàm xóa các bản ghi đã được đánh dấu is_deleted và đã sync xong
  /// Giúp dọn dẹp bộ nhớ máy điện thoại
  Future<void> cleanUpSyncedDeletedRecords(String tableName) async {
    final db = await instance.database;
    await db.delete(
      tableName,
      where: 'is_deleted = ? AND is_synced = ?',
      whereArgs: [1, 1],
    );
  }
}