

import '../db/app_database.dart';
import '../models/Jar.dart';
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

  Future<List<Transaction>> getAllTransactionById(int id) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query('transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.map((e) => Transaction.fromMap(e)).toList();
  }
  Future<List<Transaction>> getAllTransaction() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query('transactions');
    return maps.map((e) => Transaction.fromMap(e)).toList();
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

}