

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

    final maps = await db.query(
      'transactions',
      where: 'is_deleted = ?',
      whereArgs: [0],
    );

    return maps.map((e) => Transaction.fromMap(e)).toList();
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