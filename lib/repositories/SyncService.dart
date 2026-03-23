import 'package:sqflite/sqflite.dart';
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

  Future<void> downloadAllDataFromServer(String userId) async {
    print('📥 Đang bắt đầu tải dữ liệu từ Server cho User: $userId');

    final tables = [
      'categories',      // Danh mục chi tiêu
      'jars',            // Các hũ tài chính
      'savings',         // Khoản tiết kiệm (Nếu có)
      'spending_limits', // Hạn mức chi tiêu
      'transactions',    // Giao dịch (Cần jars & categories)
      'jar_logs',        // Lịch sử biến động hũ (Cần transactions)
      'saving_logs'      // Lịch sử tiết kiệm (Cần savings)
    ];

    try {
      for (String tableName in tables) {
        // 1. Lấy dữ liệu từ Supabase theo userId
        final List<dynamic> remoteData = await _supabase
            .from(tableName)
            .select()
            .eq('user_id', userId);

        if (remoteData.isNotEmpty) {
          for (var row in remoteData) {
            // 2. Chèn vào SQLite
            // Chúng ta dùng 'upsert' hoặc 'insert' với conflict algorithm là replace
            // Đặt is_synced = 1 vì đây là dữ liệu từ Server về, đã khớp 100%
            final dataForLocal = Map<String, dynamic>.from(row);
            dataForLocal['is_synced'] = 1;

            await _dbHelper.insertFromServer(tableName, dataForLocal);
          }
          print('✅ Đã tải ${remoteData.length} dòng cho bảng $tableName');
        }
      }
      print('🏁 Hoàn tất quá trình khôi phục dữ liệu.');
    } catch (e) {
      print('❌ Lỗi khi tải dữ liệu từ Server: $e');
      // Có thể throw e để bên ngoài AuthService biết mà xử lý
    }
  }

  Future<void> syncAll() async {
    print('🔄 Bắt đầu tiến trình đồng bộ toàn cục...');

    await _syncTable('users');


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

  Future<void> clearAllData() async {
    final db = await _dbHelper.database;
    // Sử dụng Transaction để đảm bảo nếu lỗi một bảng thì sẽ không xóa các bảng khác
    await db.transaction((txn) async {
      print('🧹 Đang xóa toàn bộ dữ liệu cục bộ...');

      // 1. Xóa các bảng tầng 3 (Nhật ký)
      await txn.delete('jar_logs');
      await txn.delete('saving_logs');

      // 2. Xóa các bảng tầng 2 (Giao dịch & Hạn mức)
      await txn.delete('transactions');
      await txn.delete('spending_limits');

      // 3. Xóa các bảng tầng 1 (Hũ & Danh mục & Tiết kiệm)
      await txn.delete('jars');
      await txn.delete('categories');
      await txn.delete('savings');

      // 4. Xóa bảng User (nếu bạn có bảng user riêng trong SQLite)
      // await txn.delete('users');

      print('✨ Đã dọn dẹp sạch sẽ database.');
    });
  }

  Future<void> insertUser(Map<String, dynamic> userData) async {
    final db = await _dbHelper.database;

    try {
      await db.insert(
        'users',
        userData,
        // Nếu trùng ID (primary key), nó sẽ ghi đè dữ liệu mới nhất
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ Đã lưu thông tin User vào SQLite: ${userData['email']}');
    } catch (e) {
      print('❌ Lỗi khi insertUser: $e');
      rethrow;
    }
  }
}