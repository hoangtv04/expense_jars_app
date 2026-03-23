

import 'package:flutter/cupertino.dart';
import 'package:flutter_application_jars/models/Reponse/SavingRespone.dart';
import 'package:flutter_application_jars/repositories/JarRepository.dart';
import 'package:flutter_application_jars/repositories/SavingRepository.dart';
import 'package:flutter_application_jars/repositories/TransactionRepository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../db/app_database.dart';
import '../db/app_state.dart';
import '../models/Category.dart';
import '../models/Saving.dart';
import '../models/SavingLog.dart';
import '../models/Transaction.dart';
import '../services/session_services.dart';

class SavingController {
  // Dùng đúng UUID này xuyên suốtcategoryWithdrawSavingId
  static const String categoryOpenSavingId = "550e8400-e29b-41d4-a716-446655440000";
  static const String categoryWithdrawSavingId = "660e8400-e29b-41d4-a716-446655440000";

  final SavingRepository _repo = SavingRepository();
  final TransactionRepository _transactionRepo = TransactionRepository();
  final JarRepository _repoJar = JarRepository();

  final _uuid = const Uuid();

  Future<void> addSaving(SavingRespone res) async {
    final userId = await SessionService.getUserId();
    if (userId == null) return;

    final database = await AppDatabase.instance.database;
    final now = DateTime.now().toIso8601String();
    final savingId = _uuid.v4();

    final saving = Saving(
      id: savingId,
      userId: userId,
      jarId: res.jarId,
      interestRate: res.interestRate,
      name: res.name,
      principal: res.principal,
      createdAt: res.createdAt ?? now,
      startDate: res.startDate ?? now,
      endDate: res.endDate,
      status: res.status ?? 'active',
      note: res.note,
    );

    try {
      // Ép kiểu rõ ràng là sqflite.Transaction để tránh nhầm với Model Transaction
      await database.transaction((sqflite.Transaction txn) async {

        // Bước A: Lưu sổ
        await _repo.insertSavingInTxn(txn, saving);

        // Bước B: Nếu có tiền gửi vào, tạo giao dịch trừ tiền Hũ
        if (res.principal > 0 && res.jarId != null) {
          final txId = _uuid.v4();
          final tx = Transaction(
            id: txId,
            userId: userId,
            jarId: res.jarId!,
            amount: res.principal,
            type: CategoryType.expense,
            note: "Mở sổ tiết kiệm: ${res.name}",
            date: now,
            categoryId: categoryOpenSavingId, // 🔥 SỬA: Dùng biến static ở trên
            createdAt: now,
          );

          // Đảm bảo hàm này trong TransactionRepo nhận vào (sqflite.Transaction txn, ...)
          await _transactionRepo.insertInTxn(txn, tx);
        }
      });

      print("✅ Thành công! Đã lưu sổ và trừ tiền hũ.");

      // 🔥 QUAN TRỌNG: Thông báo cho UI biết dữ liệu đã thay đổi
      AppState.jarChanged.value++;

    } catch (e) {
      // In lỗi chi tiết ra để xem nó bị Foreign Key hay lỗi kiểu dữ liệu
      print("❌ Lỗi cụ thể tại addSaving: $e");
    }
  }


   Future<void> depositToSaving({
     required String savingId,
     required double amount,
     required String fromJarId,
   }) async {
     final database = await AppDatabase.instance.database;

     final saving = await _repo.getById(savingId);
     if (saving == null) throw Exception("Không tìm thấy sổ");


     final jar = await _repoJar.getJarById(fromJarId);
     if (jar == null) throw Exception("Không tìm thấy hũ trích tiền");

     if (jar.balance < amount) {
       throw Exception("Số dư hũ '${jar.nameJar}' không đủ để gửi tiết kiệm (Hiện có: ${jar.balance.toStringAsFixed(0)}đ)");
     }
     // -------------------------------
     final tx = Transaction(
       id: const Uuid().v4(),
       userId: saving.userId,
       jarId: fromJarId,
       amount: amount,
       type: CategoryType.expense,
       note: "Gửi tiền vào sổ: ${saving.name}",
       date: DateTime.now().toIso8601String(),
       categoryId: categoryOpenSavingId, // ID hạng mục tiết kiệm
     );

     // BƯỚC 3: Tạo Log cho sổ tiết kiệm
     final log = SavingLog(
       id: const Uuid().v4(),
       userId: saving.userId,
       savingId: savingId,
       changeAmount: amount,
       type: 'deposit',
       createdAt: DateTime.now().toIso8601String(),
     );



     await database.transaction((txn) async {
       await _transactionRepo.insertInTxn(txn, tx); // Trừ tiền hũ
       // await _savingLogRepo.insertInTxn(txn, log);  // Ghi log sổ

       double newPrincipal = saving.principal + amount;
       await _repo.updatePrincipalInTxn(txn, savingId, newPrincipal);
     });
     AppState.jarChanged.value++;

   }

  Future<void> withdrawFromSaving({
    required String savingId,
    required double amount,
    required String toJarId, // Hũ nhận tiền rút ra
  }) async {
    final database = await AppDatabase.instance.database;

    // Bước 1: Lấy thông tin sổ
    final saving = await _repo.getById(savingId);
    if (saving == null) throw Exception("Không tìm thấy sổ tiết kiệm");
    if (saving.principal < amount) throw Exception("Số dư trong sổ không đủ để rút");

    // Bước 2: Tạo giao dịch (Transaction) để CỘNG tiền vào Hũ
    // Khi rút từ sổ vào hũ, hũ sẽ nhận được một khoản "Thu nhập"
    final tx = Transaction(
      id: const Uuid().v4(),
      userId: saving.userId,
      jarId: toJarId,
      amount: amount,
      type: CategoryType.income, // Rút về hũ nên hũ tăng tiền (Income)
      note: "Rút tiền từ sổ: ${saving.name}",
      date: DateTime.now().toIso8601String(),
      categoryId: categoryWithdrawSavingId, // Bạn nên định nghĩa ID hạng mục "Rút tiết kiệm"

    );

    // Bước 3: Tạo Log cho sổ tiết kiệm
    final log = SavingLog(
      id: const Uuid().v4(),
      userId: saving.userId,
      savingId: savingId,
      changeAmount: -amount, // Số âm vì là rút ra
      type: 'withdraw',
      createdAt: DateTime.now().toIso8601String(),
    );

    await database.transaction((txn) async {
      await _transactionRepo.insertInTxn(txn, tx);

      // await _savingLogRepo.insertInTxn(txn, log);

      double newPrincipal = saving.principal - amount;
      await _repo.updatePrincipalInTxn(txn, savingId, newPrincipal);

    });
    AppState.jarChanged.value++;

  }

   Future<List<Saving>> getSaving() async {
     final userId = await SessionService.getUserId();

     if (userId == null) {
       debugPrint("⚠ Warning: UserId is null in getSaving");
       return [];
     }

     // 2. Gọi hàm repo (Đảm bảo repo đã đổi tên thành getAllActive)
     final list = await _repo.getAllActive(userId);

     // 3. Sửa lại nội dung print cho đúng nghiệp vụ
     print(' Saving count: ${list.length}');

     return list;
   }

  Future<void> deleteSaving(String id) async {
    try {

      await _repo.softDelete(id);

      print("✅ Xóa thành công sổ: $id");
    } catch (e) {
      print("❌ Lỗi xóa sổ: $e");
      // Fallback: Vẫn xóa local nếu lỗi mạng để User không thấy sổ đó nữa
      await _repo.softDelete(id);
    }
  }
}