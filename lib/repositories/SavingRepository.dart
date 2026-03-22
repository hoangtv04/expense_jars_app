import 'package:flutter_application_jars/models/Saving.dart';
import 'package:sqflite/sqflite.dart' as sq;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../db/app_database.dart';
import '../models/Jar.dart';
class SavingRepository {
  Future<int> insertSaving(Saving saving) async {
    final db = await AppDatabase.instance.database;
    return await db.insert(
      "savings",
      saving.toMap(),
      conflictAlgorithm: sq.ConflictAlgorithm.replace,
    );
  }
  Future<void> insertSavingInTxn(sq.Transaction txn, Saving saving) async {
    await txn.insert(
      'savings',
      saving.toMap(),
      // Sử dụng replace để nếu trùng ID (khi sync) thì nó sẽ cập nhật bản mới nhất
      conflictAlgorithm: sq.ConflictAlgorithm.replace,
    );
    print("✅ Đã chèn Saving vào DB trong Transaction");
  }
  Future<List<Saving>> getAllActive(String userId) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'savings',
      where: 'user_id = ?', // Bỏ is_deleted = 0
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((e) => Saving.fromMap(e)).toList();
  }

  Future<Saving?> getById(String id) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'savings',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Saving.fromMap(maps.first);
    }
    return null;
  }

  // Lưu ý: Cường truyền txn vào để đảm bảo tính nguyên tử (Atomicity)
  Future<void> updatePrincipalInTxn(sq.Transaction txn, String id, double newPrincipal) async {
    await txn.update(
      'savings',
      {
        'principal': newPrincipal,
        'is_synced': 0, // Đánh dấu để sync lại lên server
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  final supabase = Supabase.instance.client;
  // 5. Xóa mềm (Soft Delete)
  Future<int> softDelete(String id) async {
    final db = await AppDatabase.instance.database;
    final response = await supabase.from('savings').delete().eq('id', id);
    // Lệnh này sẽ xóa sạch dòng có ID này trong bảng savings
    return await db.delete(
      'savings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}