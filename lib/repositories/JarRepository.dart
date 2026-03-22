import 'package:flutter_application_jars/models/Reponse/UpdateJarSetting.dart';
import '../db/app_database.dart';
import '../models/Jar.dart';

class JarRepository {
  // ==========================================
  // 1. CÁC HÀM LIÊN QUAN ĐẾN JARS
  // ==========================================

  Future<int> insertJar(Jar jar) async {
    final db = await AppDatabase.instance.database;
    // Khi insert mới, mặc định is_synced là 0 (SQLite sẽ tự lo nếu bạn để DEFAULT 0)
    return await db.insert("jars", jar.toMap());
  }

  Future<void> updateJar(String id, double amount) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'jars',
      {
        'balance': amount,
        'is_synced': 0, // Reset về 0 để đồng bộ lại số dư mới
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateJarName(String id, String name) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'jars',
      {
        'nameJar': name,
        'is_synced': 0, // Reset về 0 khi đổi tên
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateJarSetting(UpdateJarSetting updateJarSetting) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'jars',
      {
        'nameJar': updateJarSetting.nameJar,
        'name': updateJarSetting.name,
        'balance': updateJarSetting.balance,
        'description': updateJarSetting.description,
        'is_synced': 0, // Có bất kỳ thay đổi nào cũng reset sync
      },
      where: 'id = ?',
      whereArgs: [updateJarSetting.id],
    );
  }

  Future<Jar?> getJarById(String id) async {
    final db = await AppDatabase.instance.database;
    final result = await db.query(
      'jars',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Jar.fromMap(result.first);
  }

  Future<int> deleteJar(String id) async {
    final db = await AppDatabase.instance.database;
    return await db.update(
      'jars',
      {
        'is_deleted': 1,
        'is_synced': 0, // Reset về 0 để báo Server xóa hũ này
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getJarBalanceById(String id) async {
    final db = await AppDatabase.instance.database;
    final result = await db.query(
      'jars',
      columns: ['balance'], // Chỉ lấy cột balance cho nhẹ
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return (result.first['balance'] as num).toDouble();
    }
    return 0.0; // Trả về 0 nếu không tìm thấy hũ
  }

  Future<List<Jar>> getAll() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'jars',
      where: 'is_deleted = ?',
      whereArgs: [0], // Chỉ lấy hũ chưa bị xóa
      orderBy: 'created_at DESC',
    );
    return maps.map((e) => Jar.fromMap(e)).toList();
  }

  // ==========================================
  // 2. CÁC HÀM LIÊN QUAN ĐẾN JAR_LOGS
  // ==========================================

  /// Thêm một dòng log biến động số dư
  Future<int> insertJarLog(Map<String, dynamic> logData) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('jar_logs', logData);
  }

  /// Lấy toàn bộ log của một hũ cụ thể
  Future<List<Map<String, dynamic>>> getJarLogs(String jarId) async {
    final db = await AppDatabase.instance.database;
    return await db.query(
      'jar_logs',
      where: 'jar_id = ?',
      whereArgs: [jarId],
      orderBy: 'created_at DESC',
    );
  }



  /// Lấy tất cả dữ liệu chưa đồng bộ (cả jars và logs)
  Future<List<Map<String, dynamic>>> getUnsyncedJars() async {
    final db = await AppDatabase.instance.database;
    return await db.query('jars', where: 'is_synced = 0');
  }

  Future<List<Map<String, dynamic>>> getUnsyncedLogs() async {
    final db = await AppDatabase.instance.database;
    return await db.query('jar_logs', where: 'is_synced = 0');
  }

  /// Đánh dấu đã đồng bộ thành công
  Future<void> markJarAsSynced(String id) async {
    final db = await AppDatabase.instance.database;
    await db.update('jars', {'is_synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markLogAsSynced(String id) async {
    final db = await AppDatabase.instance.database;
    await db.update('jar_logs', {'is_synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}