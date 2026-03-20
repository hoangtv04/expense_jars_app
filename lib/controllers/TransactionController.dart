import 'package:flutter_application_jars/repositories/JarRepository.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_application_jars/services/session_services.dart';
import '../db/app_state.dart';
import '../models/Category.dart';
import '../models/Jar.dart';
import '../models/Reponse/TransactionWithCategory.dart';
import '../models/Transaction.dart';
import '../repositories/CategoryRepository.dart';
import '../repositories/TransactionRepository.dart';

class TransactionController {
  final TransactionRepository _repo = TransactionRepository();
  final CategoryRepository _cateRepo = CategoryRepository();
  final JarRepository _jarRepo = JarRepository();

  Future<List<Transaction>> getAll() async {
    return await _repo.getAllTransactions();
  }

  Future<void> delete(String id) async {
    await _repo.deleteTransactions(id);

    AppState.jarChanged.value++;
  }

  Future<void> update(Transaction updatedTransaction) async {
    await _repo.updateTransaction(updatedTransaction);
    AppState.jarChanged.value++;
  }

  Future<void> add(Transaction transaction) async {
    if (transaction.amount <= 0) {
      throw Exception("Amount không hợp lệ");
    }

    // 🔥 LẤY USER ID TỪ SESSION
    final userId = await SessionService.getUserId();
    if (userId == null) {
      throw Exception("User chưa login");
    }

    final jar = await _jarRepo.getJarById(transaction.jarId);
    if (jar == null) {
      throw Exception("Hũ không tồn tại");
    }

    if (transaction.amount > jar.balance) {
      throw Exception("Số tiền vượt quá số dư của hũ");
    }

    if (transaction.type == CategoryType.expense) {
      await _jarRepo.updateJar(jar.id!, jar.balance - transaction.amount);
    } else if (transaction.type == CategoryType.income) {
      await _jarRepo.updateJar(jar.id!, jar.balance + transaction.amount);
    }

    final newTransaction = Transaction(
      id: transaction.id ?? const Uuid().v4(),
      userId: userId, // 🔥 CHỈ DÙNG SESSION
      jarId: transaction.jarId,
      categoryId: transaction.categoryId,
      amount: transaction.amount,
      type: transaction.type,
      note: transaction.note,
      date: transaction.date,
      createdAt: transaction.createdAt,
      isDeleted: transaction.isDeleted,
    );

    await _repo.insertTransactions(newTransaction);
    AppState.jarChanged.value++;
  }

  Future<List<TransactionWithCategory>> getTransactionsWithCategory(
    String id,
  ) async {
    return await _cateRepo.getTransactionWithCategory(id);
  }

  Future<List<Transaction>> getTransactionListById(String id) async {
    final list = await _repo.getAllTransactionByJarId(id);
    print('Jar count: ${list.length}');
    return list;
  }

  Future<List<TransactionWithCategory>> getTransactionWithCategory(
    String jarId,
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

  Future<List<Map<String, dynamic>>> getDailyReport(
    String userId,
    int day,
    int month,
    int year,
  ) {
    return _repo.getDailyReport(userId, day, month, year);
  }

  Future<List<Map<String, dynamic>>> getWeeklyReport(
    String userId,
    int month,
    int year,
  ) {
    return _repo.getWeeklyReport(userId, month, year);
  }

  Future<List<Map<String, dynamic>>> getMonthlyReport(
    String userId,
    int month,
    int year,
  ) {
    return _repo.getMonthlyReport(userId, month, year);
  }

  Future<List<Map<String, dynamic>>> getQuarterReport(String userId) {
    return _repo.getQuarterReport(userId);
  }

  Future<List<Map<String, dynamic>>> getYearlyReport(String userId) {
    return _repo.getYearlyReport(userId);
  }

  Future<double> getTransactionsTotalIncome(String jarId) async {
    return _repo.getTotalIncome(jarId);
  }

  Future<double> getTransactionsTotalExpense(String jarId) async {
    return _repo.getTotalExpense(jarId);
  }
}
