import '../db/app_database.dart';
import '../models/Jar.dart';
import '../models/Reponse/TransactionWithCategory.dart';
import '../models/Transaction.dart';

class TransactionRepository {
  Future<int> insertTransaction(Transaction jar) async {
    final db = await AppDatabase.instance.database;
    return await db.insert("transactions", jar.toMap());
  }

  Future<int> deleteTransaction(Transaction transaction) async {
    final db = await AppDatabase.instance.database;
    return await db.insert("transactions", transaction.toMap());
  }

  Future<List<Transaction>> getAllTransactionByJarId(int jar_id) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'transactions',
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

  Future<List<TransactionWithCategory>> getAllTransactionAndCategoryName(
    int jarId,
  ) async {
    final db = await AppDatabase.instance.database;

    print('===== REPO START =====');
    print('jarId = $jarId');

    final result = await db.rawQuery(
      '''
    SELECT 
      t.*,
      c.name AS category_name
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

    print('REPO result count = ${result.length}');
    for (final row in result) {
      print(row);
    }

    print('===== REPO END =====');

    return result.map((e) => TransactionWithCategory.fromMap(e)).toList();
  }
  // belong to Demons

  Future<int> insertTransactions(Transaction transaction) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> deleteTransactions(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.update(
      'transactions',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
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
    final maps = await db.query('transactions');
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
}
