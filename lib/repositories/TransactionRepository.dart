

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


  Future<int> deleteTransaction(Transaction transaction) async{
    final db = await AppDatabase.instance.database;
    return await db.insert("transactions", transaction.toMap());
  }

  Future<List<Transaction>> getAllTransactionByJarId(int jar_id) async {
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


  Future<List<TransactionWithCategory>> getAllTransactionAndCategoryName(int jarId) async {
    final db = await AppDatabase.instance.database;

    print('===== REPO START =====');
    print('jarId = $jarId');

    final result = await db.rawQuery(
      '''
    SELECT 
      t.*,
      c.name AS category_name,
      c.type AS category_type
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

  Future<int> deleteTransactions(int id) async {
    final db = await AppDatabase.instance.database;

    return await db.transaction((txn) async {

      // Lấy transaction cần xóa
      final result = await txn.query(
        'transactions',
        where: 'id = ? AND is_deleted = 0',
        whereArgs: [id],
      );

      if (result.isEmpty) return 0;

      final transaction = Transaction.fromMap(result.first);

      // Lấy jar tương ứng
      final jarResult = await txn.query(
        'jars',
        where: 'id = ?',
        whereArgs: [transaction.jarId],
      );

      double currentBalance = jarResult.first['balance'] as double;
      double newBalance = currentBalance;

      //  Rollback balance
      if (transaction.type == 'income') {
        newBalance -= transaction.amount;   // Xóa thu → trừ lại
      } else {
        newBalance += transaction.amount;   // Xóa chi → cộng lại
      }

      //  Update jar balance
      await txn.update(
        'jars',
        {'balance': newBalance},
        where: 'id = ?',
        whereArgs: [transaction.jarId],
      );

      // Soft delete transaction
      return await txn.update(
        'transactions',
        {'is_deleted': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<int> updateTransaction(Transaction updatedTransaction) async {
    final db = await AppDatabase.instance.database;

    return await db.transaction((txn) async {

      //  Lấy transaction cũ
      final oldResult = await txn.query(
        'transactions',
        where: 'id = ? AND is_deleted = 0',
        whereArgs: [updatedTransaction.id],
      );

      if (oldResult.isEmpty) return 0;

      final oldTransaction = Transaction.fromMap(oldResult.first);

      //  Lấy jar
      final jarResult = await txn.query(
        'jars',
        where: 'id = ?',
        whereArgs: [oldTransaction.jarId],
      );

      double currentBalance = jarResult.first['balance'] as double;
      double newBalance = currentBalance;

      //  Rollback transaction cũ
      if (oldTransaction.type == 'income') {
        newBalance -= oldTransaction.amount;
      } else {
        newBalance += oldTransaction.amount;
      }

      //  Apply transaction mới
      if (updatedTransaction.type == 'income') {
        newBalance += updatedTransaction.amount;
      } else {
        newBalance -= updatedTransaction.amount;
      }

      //  Update jar balance
      await txn.update(
        'jars',
        {'balance': newBalance},
        where: 'id = ?',
        whereArgs: [oldTransaction.jarId],
      );

      // 6️⃣ Update transaction
      return await txn.update(
        'transactions',
        updatedTransaction.toMap(),
        where: 'id = ?',
        whereArgs: [updatedTransaction.id],
      );
    });
  }

  Future<Transaction?> getTransactionById(int id) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    }
    return null;
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

  Future<Map<String, double>> getSummaryByUser(int userId) async {
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

  Future<List<Map<String, dynamic>>> getDailyReport(int userId) {
    return _db.getDailyReport(userId);
  }

  Future<List<Map<String, dynamic>>> getWeeklyReport(int userId) {
    return _db.getWeeklyReport(userId);
  }

  Future<List<Map<String, dynamic>>> getMonthlyReport(int userId) {
    return _db.getMonthlyReport(userId);
  }

  Future<List<Map<String, dynamic>>> getQuarterReport(int userId) {
    return _db.getQuarterReport(userId);
  }

  Future<List<Map<String, dynamic>>> getYearlyReport(int userId) {
    return _db.getYearlyReport(userId);
  }


  Future<double> getTotalIncome(int jarId) async {
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

  Future<double> getTotalExpense(int jarId) async {
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

}