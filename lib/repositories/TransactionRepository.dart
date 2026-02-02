
import 'package:flutter_application_expense/db/app_database.dart';
import 'package:flutter_application_expense/models/Transaction.dart';

import '../models/Jar.dart';

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

}