import 'package:sqflite/sqflite.dart' as sqflite;
import '../db/app_database.dart';
import '../models/Category.dart';
import '../models/Jar.dart';
import '../models/Reponse/TransactionWithCategory.dart';
import '../models/Transaction.dart';

class TransactionRepository {
  final AppDatabase _db = AppDatabase.instance;

  // ==========================================
  // 1. CÁC HÀM THÊM / SỬA / XÓA (CÓ SYNC)
  // ==========================================

  /// Thêm giao dịch mới và đánh dấu chưa đồng bộ
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await _db.database;
    final map = transaction.toMap();
    map['is_synced'] = 0; // Luôn reset về 0 khi tạo mới
    return await db.insert("transactions", map);
  }

  /// Xóa mềm giao dịch và báo cho Server cần xóa bản ghi này
  Future<int> deleteTransactions(Transaction transaction) async {
    final db = await _db.database;
    return await db.update(
      'transactions',
      {
        'is_deleted': 1,
        'is_synced': 0, // Server sẽ dựa vào cái này để cập nhật trạng thái xóa trên Cloud
      },
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Cập nhật nội dung giao dịch và reset trạng thái đồng bộ
  Future<int> updateTransaction(Transaction transaction) async {
    final db = await _db.database;
    final map = transaction.toMap();
    map['is_synced'] = 0; // Sửa đổi dữ liệu là phải sync lại

    return await db.update(
      'transactions',
      map,
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Cập nhật ngày chạy tiếp theo cho giao dịch định kỳ
  Future<void> updateNextRunDate(String id, String nextDate) async {
    final db = await _db.database;
    await db.update(
      'transactions',
      {
        'next_run_date': nextDate,
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // 2. CÁC HÀM TRONG TRANSACTION (SỬ DỤNG TRONG GỬI/RÚT TIẾT KIỆM)
  // ==========================================

  /// Chèn giao dịch trong một Transaction của DB (đảm bảo tính toàn vẹn)
  Future<void> insertInTxn(sqflite.Transaction txn, Transaction transaction) async {
    final map = transaction.toMap();
    map['is_synced'] = 0;

    await txn.insert(
      'transactions',
      map,
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );

    // 🔥 Cập nhật số dư Hũ và reset luôn cột sync của Hũ đó ngay trong txn
    await _updateJarBalanceInTxn(txn, transaction);
  }

  /// Hàm phụ: Tự động tính toán lại số dư hũ khi có giao dịch phát sinh
  Future<void> _updateJarBalanceInTxn(sqflite.Transaction txn, Transaction t) async {
    final List<Map<String, dynamic>> jarRes = await txn.query(
        'jars',
        where: 'id = ?',
        whereArgs: [t.jarId]
    );

    if (jarRes.isNotEmpty) {
      double currentBalance = (jarRes.first['balance'] as num).toDouble();
      double newBalance;

      if (t.type == CategoryType.expense) {
        newBalance = currentBalance - t.amount;
      } else {
        newBalance = currentBalance + t.amount;
      }

      await txn.update(
        'jars',
        {
          'balance': newBalance,
          'is_synced': 0, // Số dư hũ đổi -> Hũ đó cần được sync lại
        },
        where: 'id = ?',
        whereArgs: [t.jarId],
      );
    }
  }

  // ==========================================
  // 3. CÁC HÀM TRUY VẤN (QUERY) - GIỮ NGUYÊN
  // ==========================================

  Future<List<Transaction>> getAllTransactionByJarId(String jarId) async {
    final db = await _db.database;
    final maps = await db.query('transactions', where: 'jar_id = ?', whereArgs: [jarId]);
    return maps.map((e) => Transaction.fromMap(e)).toList();
  }

  Future<List<TransactionWithCategory>> getAllTransactionAndCategoryName(String jarId) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT t.*, c.name AS category_name, c.type AS type  
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id AND c.is_deleted = 0
      WHERE (t.is_deleted = 0 OR t.is_deleted IS NULL) AND t.jar_id = ?
      ORDER BY t.created_at DESC
    ''', [jarId]);
    return result.map((e) => TransactionWithCategory.fromMap(e)).toList();
  }

  Future<List<TransactionWithCategory>> getAllTransactionForTest() async {
    final db = await _db.database;

    final result = await db.rawQuery('''
  SELECT 
    t.*, 
    c.name AS category_name, 
    c.type AS category_type,
    j.nameJar AS jar_name -- Sửa từ name_jar thành nameJar cho khớp với bảng jars
  FROM transactions t
  LEFT JOIN categories c ON t.category_id = c.id
  LEFT JOIN jars j ON t.jar_id = j.id
  WHERE (t.is_deleted = 0 OR t.is_deleted IS NULL)
  ORDER BY t.date DESC
''');

    return result.map((e) => TransactionWithCategory.fromMap(e)).toList();
  }
  Future<Transaction?> getById(String id) async {
    final db = await _db.database;
    final result = await db.query('transactions', where: 'id = ? AND is_deleted = 0', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Transaction.fromMap(result.first);
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await _db.database;
    final maps = await db.query('transactions', where: 'is_deleted = ?', whereArgs: [0]);
    return maps.map((e) => Transaction.fromMap(e)).toList();
  }

  Future<double> getTotalIncome(String jarId) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT SUM(t.amount) as total FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.jar_id = ? AND t.is_deleted = 0 AND c.type = ?
    ''', [jarId, CategoryType.income.name]);
    final total = result.first['total'];
    return total == null ? 0.0 : (total as num).toDouble();
  }

  Future<double> getTotalExpense(String jarId) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT SUM(t.amount) as total FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.jar_id = ? AND t.is_deleted = 0 AND c.type = ?
    ''', [jarId, CategoryType.expense.name]);
    final total = result.first['total'];
    return total == null ? 0.0 : (total as num).toDouble();
  }

  Future<List<Transaction>> getRecurringDueTransactions() async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query('transactions', where: 'is_recurring = 1 AND next_run_date <= ?', whereArgs: [now]);
    return maps.map((e) => Transaction.fromMap(e)).toList();
  }

  // CÁC HÀM BÁO CÁO (REPORTS)
  Future<List<Map<String, dynamic>>> getDailyReport(String userId, int d, int m, int y) => _db.getDailyReport(userId, d, m, y);
  Future<List<Map<String, dynamic>>> getWeeklyReport(String userId, int m, int y) => _db.getWeeklyReport(userId, m, y);
  Future<List<Map<String, dynamic>>> getMonthlyReport(String userId, int m, int y) => _db.getMonthlyReport(userId, m, y);
  Future<List<Map<String, dynamic>>> getQuarterReport(String userId, int m, int y) => _db.getQuarterReport(userId, m, y);
  Future<Map<String, dynamic>> getYearlyReport(String userId, int y) => _db.getYearlyTotal(userId, y);
}