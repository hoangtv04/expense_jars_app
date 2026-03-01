import 'package:flutter_application_jars/repositories/JarRepository.dart';

import '../models/Jar.dart';
import '../models/Reponse/TransactionWithCategory.dart';
import '../models/Transaction.dart';
import '../repositories/TransactionRepository.dart';

class TransactionController {
  final TransactionRepository _repo = TransactionRepository();
  final JarRepository _jarRepo = JarRepository();

  Future<List<Transaction>> getAll() async {
    return await _repo.getAllTransactions();
  }

  Future<void> delete(int id) async {
    await _repo.deleteTransactions(id);
  }

  Future<void> add(Transaction transaction) async {
    if (transaction.amount <= 0) {
      throw Exception("Amount không hợp lệ");
    }
    final jar = await _jarRepo.getJarById(transaction.jarId);
    if (jar == null) {
      throw Exception("Hũ không tồn tại");
    }
    if (transaction.amount > jar.balance) {
      throw Exception("Số tiền vượt quá số dư của hũ");
    }
    await _repo.insertTransactions(transaction);
  }

  Future<List<Transaction>> getTransactionListById(int id) async {
    final list = await _repo.getAllTransactionByJarId(id);
    print('Jar count: ${list.length}');
    return list;
  }

  Future<List<TransactionWithCategory>> getTransactionWithCategory(
    int jarId,
  ) async {
    print('===== TransactionController =====');
    print('jarId nhận được: $jarId');

    final list = await _repo.getAllTransactionAndCategoryName(jarId);

    print('KẾT QUẢ TỪ REPO');
    print('Số lượng record: ${list.length}');

    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      print(
        '[$i] '
        'id=${item.id}, '
        'categoryId=${item.categoryId}, '
        'categoryName=${item.categoryName}, '
        'amount=${item.amount}',
      );
    }

    print('===== END TransactionController =====');

    return list;
  }

  Future<List<Map<String, dynamic>>> getDailyReport(int userId) {
    return _repo.getDailyReport(userId);
  }

  Future<List<Map<String, dynamic>>> getWeeklyReport(int userId) {
    return _repo.getWeeklyReport(userId);
  }

  Future<List<Map<String, dynamic>>> getMonthlyReport(int userId) {
    return _repo.getMonthlyReport(userId);
  }

  Future<List<Map<String, dynamic>>> getQuarterReport(int userId) {
    return _repo.getQuarterReport(userId);
  }

  Future<List<Map<String, dynamic>>> getYearlyReport(int userId) {
    return _repo.getYearlyReport(userId);
  }
}
