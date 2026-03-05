import 'package:flutter_application_jars/repositories/TransactionRepository.dart';

import '../db/app_database.dart';

class DashboardController {
  final AppDatabase _db = AppDatabase.instance;
  final TransactionRepository _transactionRepo = TransactionRepository();
  Future<Map<String, double>> getSummary(int userId) async {
    final data = await _transactionRepo.getSummaryByUser(userId);

    final income = data['income'] ?? 0;
    final expense = data['expense'] ?? 0;

    return {'income': income, 'expense': expense, 'balance': income - expense};
  }
}
