



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

  Future<void> delete(Transaction transaction) async {
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

  }
  Future<void> update(Transaction updated) async {
    // 1. Lấy dữ liệu cũ từ DB (bắt buộc để biết trạng thái trước đó)
    final old = await _repo.getById(updated.id!);
    if (old == null) throw Exception("Giao dịch không tồn tại");

    // 2. Lấy thông tin hũ cũ
    final oldJar = await _jarRepo.getJarById(old.jarId);
    if (oldJar == null) throw Exception("Hũ cũ không tồn tại");

    // --- BƯỚC A: ROLLBACK HŨ CŨ ---
    // Trả hũ cũ về trạng thái NHƯ CHƯA CÓ giao dịch này
    double rolledBackBalance = oldJar.balance;
    if (old.type == CategoryType.income) {
      print('thu');
      rolledBackBalance -= old.amount; // Nếu cũ là Thu, giờ trừ đi để trả lại
    } else {
      print('chi');
      rolledBackBalance += old.amount; // Nếu cũ là Chi, giờ cộng lại để trả lại
    }

    // --- BƯỚC B: XỬ LÝ HŨ MỚI ---
    if (old.jarId == updated.jarId) {
      // Trường hợp 1: Vẫn là hũ đó
      double finalBalance = rolledBackBalance;

      // Áp dụng logic mới dựa trên thông tin cập nhật
      if (updated.type == CategoryType.income) {
        finalBalance += updated.amount;
      } else {
        // Kiểm tra số dư trước khi chi
        if (updated.amount > finalBalance) throw Exception("Số dư hũ không đủ");
        finalBalance -= updated.amount;
      }

      // Cập nhật lại số dư cuối cùng cho hũ duy nhất
      await _jarRepo.updateJar(oldJar.id!, finalBalance);

    } else {
      // Trường hợp 2: Đã đổi sang hũ khác
      final newJar = await _jarRepo.getJarById(updated.jarId);
      if (newJar == null) throw Exception("Hũ mới không tồn tại");

      double newJarBalance = newJar.balance;

      // 1. Cập nhật hũ cũ (chỉ đơn giản là trả lại tiền)
      await _jarRepo.updateJar(oldJar.id!, rolledBackBalance);

      // 2. Cập nhật hũ mới (áp dụng giao dịch mới)
      if (updated.type == CategoryType.income) {
        newJarBalance += updated.amount;
      } else {
        if (updated.amount > newJarBalance) throw Exception("Số dư hũ mới không đủ");
        newJarBalance -= updated.amount;
      }
      await _jarRepo.updateJar(newJar.id!, newJarBalance);
    }

    // 4. Lưu giao dịch đã sửa vào DB
    await _repo.updateTransaction(updated);
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
    if(jar == null) {
      throw Exception("Hũ không tồn tại");
    }
    if(transaction.amount > jar.balance) {
      throw Exception("Số tiền vượt quá số dư của hũ");
    }
    if(transaction.type == CategoryType.expense) {
      await _jarRepo.updateJar(jar.id!, jar.balance - transaction.amount);
    } else if(transaction.type == CategoryType.income) {
      await _jarRepo.updateJar(jar.id!, jar.balance + transaction.amount);
    }

    final newTransaction = Transaction(
      id: transaction.id ?? const Uuid().v4(),
      userId: userId,
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

  Future<List<Map<String, dynamic>>> getQuarterReport(String userId, int month, int year) {
    return _repo.getQuarterReport(userId, month, year);
  }

Future<Map<String, dynamic>> getYearlyReport(
  String userId,
  int year,
) {
  return _repo.getYearlyReport(userId, year);
}

  Future<double> getTransactionsTotalIncome(String jarId) async {


    return _repo.getTotalIncome(jarId);
  }

  Future<double> getTransactionsTotalExpense(String jarId) async {


    return _repo.getTotalExpense(jarId);
  }

  Future<void> runRecurringTransactions() async {
    final list = await _repo.getRecurringDueTransactions();

    for (var old in list) {

      // 1. tạo transaction mới
      final newTransaction = old.copyWith(
        id: const Uuid().v4(),
        date: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
      );

      await add(newTransaction); // dùng lại logic add

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
      await _repo.updateNextRunDate(old.id!, nextDate.toIso8601String());
    }
  }

}
