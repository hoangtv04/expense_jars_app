

import 'package:flutter/cupertino.dart';
import 'package:flutter_application_jars/models/Reponse/SavingRespone.dart';
import 'package:flutter_application_jars/repositories/SavingRepository.dart';
import 'package:flutter_application_jars/repositories/TransactionRepository.dart';
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
  // Dùng đúng UUID này xuyên suốt
  static const String categoryOpenSavingId = "550e8400-e29b-41d4-a716-446655440000";

  final SavingRepository _repo = SavingRepository();
  final TransactionRepository _transactionRepo = TransactionRepository();
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

     // BƯỚC 2: Tạo một Giao dịch (Transaction) để trừ tiền ở Hũ
     // (Vì gửi vào tiết kiệm thì tiền ở hũ phải mất đi)
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
}