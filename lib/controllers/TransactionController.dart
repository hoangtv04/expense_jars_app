



import 'package:flutter_application_jars/repositories/JarRepository.dart';
import 'package:uuid/uuid.dart';

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

  Future<Transaction> delete(Transaction transaction) async {
    final jar = await _jarRepo.getJarById(transaction.jarId);
    if(jar == null) {
      throw Exception("Hũ không tồn tại");
    }
    if(transaction.type == CategoryType.expense) {
      await _jarRepo.updateJar(jar.id!, jar.balance + transaction.amount);
    } else if(transaction.type == CategoryType.income) {
      await _jarRepo.updateJar(jar.id!, jar.balance - transaction.amount);
    }
    await _repo.deleteTransactions(transaction);
    AppState.jarChanged.value++;

    return transaction;
  }

  Future<void> update(Transaction updated) async {
    final old = await _repo.getById(updated.id!);
    if (old == null) throw Exception("Transaction không tồn tại");

    final jar = await _jarRepo.getJarById(old.jarId);
    if (jar == null) throw Exception("Jar không tồn tại");

    double balance = jar.balance;

    ///  1. Rollback transaction cũ
    if (old.type == CategoryType.income) {
      balance -= old.amount;
    } else {
      balance += old.amount;
    }

    ///  2. Validate nếu là expense
    if (updated.type == CategoryType.expense &&
        updated.amount > balance) {
      throw Exception("Số dư không đủ");
    }

    /// 3. Apply transaction mới
    if (updated.type == CategoryType.income) {
      balance += updated.amount;
    } else {
      balance -= updated.amount;
    }

    ///  4. Update jar
    await _jarRepo.updateJar(jar.id!, balance);

    ///  5. Update transaction
    await _repo.updateTransaction(updated);
  }

  Future<void> add(Transaction transaction) async {
    if (transaction.amount <= 0) {
      throw Exception("Amount không hợp lệ");
    }
    final jar = await _jarRepo.getJarById(transaction.jarId);
    if(jar == null) {
      throw Exception("Hũ không tồn tại");
    }
    if(transaction.type == CategoryType.expense && transaction.amount > jar.balance) {
      throw Exception("Số tiền vượt quá số dư của hũ");
    }
    if(transaction.type == CategoryType.expense) {
      await _jarRepo.updateJar(jar.id!, jar.balance - transaction.amount);
    } else if(transaction.type == CategoryType.income) {
      await _jarRepo.updateJar(jar.id!, jar.balance + transaction.amount);
    }

    final newTransaction = Transaction(
      id: transaction.id ?? const Uuid().v4(),
      userId: transaction.userId,
      jarId: transaction.jarId,
      categoryId: transaction.categoryId,
      amount: transaction.amount,
      type: transaction.type,
      note: transaction.note,
      date: transaction.date,
      createdAt: transaction.createdAt,
      isDeleted: transaction.isDeleted,
      isRecurring: transaction.isRecurring,
      recurringType: transaction.recurringType,
      nextRunDate: transaction.nextRunDate,
    );

    await _repo.insertTransactions(newTransaction);
    AppState.jarChanged.value++;
  }


  Future<List<TransactionWithCategory>> getTransactionsWithCategory(String id) async {


    return await _cateRepo.getTransactionWithCategory(id);


  }



    Future<List<Transaction>> getTransactionListById(String id) async {
    final list = await _repo.getAllTransactionByJarId(id);
    print('Jar count: ${list.length}');
    return list;
  }



  Future<List<TransactionWithCategory>> getTransactionWithCategory(String jarId) async {
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
              'amount=${item.amount}'
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

  Future<List<Transaction>> runRecurringTransactions() async {
    final list = await _repo.getRecurringDueTransactions();

    List<Transaction> newTransactions = [];

    for (var old in list) {

      // 1. tạo transaction mới
      final newTransaction = old.copyWith(
        id: null,
        date: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
      );

      await add(newTransaction);

      newTransactions.add(newTransaction); //  lưu lại để trả về

      // 2. tính ngày tiếp theo
      DateTime nextDate = DateTime.parse(old.nextRunDate!);

      switch (old.recurringType) {
        case "daily":
          nextDate = nextDate.add(const Duration(days: 1));
          break;
        case "weekly":
          nextDate = nextDate.add(const Duration(days: 7));
          break;
        case "monthly":
          nextDate = DateTime(
            nextDate.year,
            nextDate.month + 1,
            nextDate.day,
          );
          break;
      }

      // 3. update next_run_date
      await _repo.updateNextRunDate(
        old.id!,
        nextDate.toIso8601String(),
      );
    }

    return newTransactions;
  }

}
