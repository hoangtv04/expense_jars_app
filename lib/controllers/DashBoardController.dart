import 'package:flutter_application_jars/repositories/TransactionRepository.dart';

import '../db/app_database.dart';

class DashboardController {

  final AppDatabase db = AppDatabase.instance;
  final TransactionRepository transactionRepo = TransactionRepository();

  Future<Map<String, double>> getSummary(int userId) async {

    final income = await db.getTotalIncome(userId);
    final expense = await db.getTotalExpense(userId);
    final balance = await db.getCurrentBalance(userId);

    return {
      'income': income,
      'expense': expense,
      'balance': balance,
    };
  }
}
