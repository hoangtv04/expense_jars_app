

import 'package:sqflite/sqflite.dart' as sqflite;
import '../db/app_database.dart';
import '../models/Category.dart';
import '../models/Jar.dart';
import '../models/Reponse/TransactionWithCategory.dart';
import '../models/Transaction.dart';

class TransactionRepository {

  Future<int> insertTransaction(Transaction jar) async{
    final db = await AppDatabase.instance.database;
    return await db.insert("transactions", jar.toMap());
  }


  // Future<int> deleteTransaction(Transaction transaction) async{
  //   final db = await AppDatabase.instance.database;
  //   return await db.insert("transactions", transaction.toMap());
  // }

  Future<List<Transaction>> getAllTransactionByJarId(String jar_id) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query('transactions',
      where: 'jar_id = ?',
      whereArgs: [jar_id],
    );
    return maps.map((e) => Transaction.fromMap(e)).toList();
  }
  Future<List<Transaction>> getAllTransaction() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query('transactions');
    return maps.map((e) => Transaction.fromMap(e)).toList();
  }


  Future<List<TransactionWithCategory>> getAllTransactionAndCategoryName(String jarId) async {
    final db = await AppDatabase.instance.database;

    print('===== REPO START =====');
    print('jarId = $jarId');

    final result = await db.rawQuery(
      '''
  SELECT 
  t.*,
  c.name AS category_name,
  c.type AS type  
FROM transactions t
LEFT JOIN categories c
  ON t.category_id = c.id
  AND c.is_deleted = 0
WHERE (t.is_deleted = 0 OR t.is_deleted IS NULL)
  AND t.jar_id = ?
ORDER BY t.created_at DESC
    ''',
      [jarId],
    );


    return result
        .map((e) => TransactionWithCategory.fromMap(e))
        .toList();
  }
  // belong to Demons

  Future<int> insertTransactions(Transaction transaction) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> deleteTransactions(Transaction transaction) async {
    final db = await AppDatabase.instance.database;
    return await db.update(
      'transactions',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await AppDatabase.instance.database;

    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }


  Future<Transaction?> getById(String id) async {
    final db = await AppDatabase.instance.database;

    final result = await db.query(
      'transactions',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;

    return Transaction.fromMap(result.first);
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await AppDatabase.instance.database;

    final maps = await db.query(
      'transactions',
      where: 'is_deleted = ?',
      whereArgs: [0],
    );

    return maps.map((e) => Transaction.fromMap(e)).toList();
  }

  Future<Map<String, double>> getSummaryByUser(String userId) async {
    final db = await AppDatabase.instance.database;

    final result = await db.rawQuery(
      '''
    SELECT 
      SUM(CASE WHEN c.type = 'income' THEN t.amount ELSE 0 END) as totalIncome,
      SUM(CASE WHEN c.type = 'expense' THEN t.amount ELSE 0 END) as totalExpense
    FROM transactions t
    JOIN categories c ON t.category_id = c.id
    WHERE t.user_id = ?
    AND t.is_deleted = 0
  ''',
      [userId],
    );

    final row = result.first;

    return {
      'income': (row['totalIncome'] as num?)?.toDouble() ?? 0,
      'expense': (row['totalExpense'] as num?)?.toDouble() ?? 0,
    };
  }

  final AppDatabase _db = AppDatabase.instance;

 Future<List<Map<String, dynamic>>> getDailyReport(
  String userId,
  int day,
  int month,
  int year,
) {
  return _db.getDailyReport(userId, day, month, year);
}

Future<List<Map<String, dynamic>>> getWeeklyReport(
    String userId,
  int month,
  int year,
) {
  return _db.getWeeklyReport(userId, month, year);
}

  Future<List<Map<String, dynamic>>> getMonthlyReport(
      String userId,
    int month,
    int year,
  ) {
    return _db.getMonthlyReport(userId, month, year);
  }

  Future<List<Map<String, dynamic>>> getQuarterReport(String userId, int month, int year) {
    return _db.getQuarterReport(userId, month, year);
  }

  Future<Map<String, dynamic>> getYearlyReport(String userId, int year) {
    return _db.getYearlyTotal(userId, year);
  }


  Future<double> getTotalIncome(String jarId) async {
    final db = await AppDatabase.instance.database;

    final result = await db.rawQuery('''
    SELECT SUM(t.amount) as total
    FROM transactions t
    JOIN categories c ON t.category_id = c.id
    WHERE t.jar_id = ?
      AND t.is_deleted = 0
      AND c.type = ?
  ''', [jarId, CategoryType.income.name]);

    final total = result.first['total'];

    return total == null ? 0.0 : (total as num).toDouble();
  }

  Future<double> getTotalExpense(String jarId) async {
    final db = await AppDatabase.instance.database;

    final result = await db.rawQuery('''
    SELECT SUM(t.amount) as total
    FROM transactions t
    JOIN categories c ON t.category_id = c.id
    WHERE t.jar_id = ?
      AND t.is_deleted = 0
      AND c.type = ?
  ''', [jarId, CategoryType.expense.name]);

    final total = result.first['total'];

    return total == null ? 0.0 : (total as num).toDouble();
  }


  Future<List<Transaction>> getRecurringDueTransactions() async {
    final db = await AppDatabase.instance.database;

    final now = DateTime.now().toIso8601String();

    final maps = await db.query(
      'transactions',
      where: 'is_recurring = 1 AND next_run_date <= ?',
      whereArgs: [now],
    );

    return maps.map((e) => Transaction.fromMap(e)).toList();
  }

  Future<void> updateNextRunDate(String id, String nextDate) async {
    final db = await AppDatabase.instance.database;

    await db.update(
      'transactions',
      {'next_run_date': nextDate},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertInTxn(sqflite.Transaction txn, Transaction transaction) async {
    await txn.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );

    // 🔥 QUAN TRỌNG: Cập nhật luôn số dư của Hũ ngay lập tức trong cùng txn
    // Bạn cần gọi logic cập nhật balance của hũ ở đây hoặc trong Controller
    await _updateJarBalance(txn, transaction);
  }

  Future<void> _updateJarBalance(sqflite.Transaction txn, Transaction t) async {
    // Lấy số dư hiện tại của hũ
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
        {'balance': newBalance},
        where: 'id = ?',
        whereArgs: [t.jarId],
      );
    }
  }


}