import 'package:supabase_flutter/supabase_flutter.dart';
import '../db/app_database.dart';

class SyncService {
  final _supabase = Supabase.instance.client;
  final _dbHelper = AppDatabase.instance;

  Future<void> _syncTable(String tableName) async {
    try {
      final List<Map<String, dynamic>> unsyncedRows = await _dbHelper.getUnsyncedRecords(tableName);
      if (unsyncedRows.isEmpty) return;

      final dataToUpload = unsyncedRows.map((row) {
        final copy = Map<String, dynamic>.from(row);

        // 1. Xóa cột is_synced vì Supabase không cần
        copy.remove('is_synced');

        // 2. XỬ LÝ LỖI: invalid input syntax for type integer: "false"
        // Vì trên Supabase bạn để is_deleted là INTEGER (0 hoặc 1)
        // Nên chúng ta PHẢI đảm bảo gửi lên là số 0 hoặc 1, KHÔNG ĐƯỢC gửi true/false.

        if (copy.containsKey('is_deleted')) {
          // Đảm bảo nó là int (0 hoặc 1) để khớp với INTEGER trên Supabase
          copy['is_deleted'] = (row['is_deleted'] == 1 || row['is_deleted'] == true) ? 1 : 0;
        }

        // Xử lý tương tự cho các cột boolean khác nếu có (ví dụ carry_forward)
        if (copy.containsKey('carry_forward')) {
          copy['carry_forward'] = (row['carry_forward'] == 1 || row['carry_forward'] == true) ? 1 : 0;
        }

        return copy;
      }).toList();

      await _supabase.from(tableName).upsert(dataToUpload);

      for (var row in unsyncedRows) {
        await _dbHelper.updateSyncStatus(tableName, row['id'].toString(), 1);
      }

      print('✅ Đồng bộ thành công bảng: $tableName (${unsyncedRows.length} dòng)');
    } catch (e) {
      print('❌ Lỗi đồng bộ bảng $tableName: $e');
    }
  }

  Future<void> syncAll() async {
    print('🔄 Bắt đầu tiến trình đồng bộ toàn cục...');



    // 2. Danh mục & Hũ (Level 1 - Cần users)
    await _syncTable('categories');
    await _syncTable('jars');

    // 3. Giao dịch (Level 2 - Cần jars & categories)
    await _syncTable('transactions');

    // 4. Nhật ký (Level 3 - Cần transactions)
    await _syncTable('jar_logs');
    await _syncTable('saving_logs');

    // 5. Các bảng khác
    await _syncTable('spending_limits');
    await _syncTable('savings');

    print('🏁 Hoàn tất đồng bộ.');
  }
}