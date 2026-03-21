import 'package:flutter_application_jars/db/app_database.dart' ;
import 'package:flutter_application_jars/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../models/user.dart';
import 'SyncService.dart';

class UserRepository {
  final AppDatabase _db = AppDatabase.instance;
  final _supabase = sb.Supabase.instance.client;
  final SyncService _syncService = SyncService();


  Future<User?> login(String email, String password) async {
    try {
      // 1. Thử đăng nhập Online trước
      final authRes = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authRes.user != null) {
        final user = User(
          id: authRes.user!.id,
          email: email,
          password: password,
          isSynced: 1, // Online về thì mặc định là 1
        );
        // Lưu lại vào SQLite để lần sau login offline
        await _syncService.insertUser(user.toMap());
        return user;
      }
    } catch (e) {
      print("🌐 Đang thử đăng nhập Offline do lỗi: $e");
      // 2. Nếu lỗi mạng hoặc lỗi server, kiểm tra SQLite
      final data = await getUserByEmail(email);
      if (data != null && data['password'] == password) {
        return User.fromMap(data);
      }
    }
    return null;
  }

  Future<User?> register(String email, String password) async {
    try {
      // 1. Đăng ký trên Cloud trước để lấy ID "chính chủ"
      final authRes = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final sb.User? sbUser = authRes.user;

      if (sbUser != null) {
        // 2. Tạo Model User với ID từ Supabase và isSynced = 1
        final newUser = User(
          id: sbUser.id, // Dùng ID của Supabase trả về
          email: email,
          password: password,
          isSynced: 1, // Đã khớp với Server
        );

        // 3. Lưu vào SQLite (thay cho registerRaw cũ)
        await _syncService.insertUser(newUser.toMap());

        return newUser;
      }
    } on sb.AuthException catch (e) {
      // Supabase sẽ tự check email tồn tại và báo lỗi ở đây
      print("❌ Lỗi từ Supabase: ${e.message}");
      rethrow;
    }
    return null;
  }

  Future<User?> getUserById(String id) async {
    final db = await _db.database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }

    return null;
  }

  Future<void> resetUsers() async {
    await _db.resetUsersTable();
  }

  Future<List<User>> getAllUsers() async {
    final result = await _db.getAllUsers();
    return result.map((e) => User.fromMap(e)).toList();
  }

  Future<bool> isEmailExists(String email) {
    return _db.isEmailExists(email);
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    final exists = await _db.isEmailExists(email);
    if (!exists) return false;

    await _db.updatePasswordByEmail(email, newPassword);
    return true;
  }

  Future<void> updateProfile(String id, String fullName) async {
    final db = await _db.database;

    await db.update(
      'users',
      {'full_name': fullName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> changePassword(
    String userId,
    String oldPassword,
    String newPassword,
  ) async {
    final db = await _db.database;

    final result = await db.query(
      'users',
      where: 'id = ? AND password = ?',
      whereArgs: [userId, oldPassword],
    );

    if (result.isEmpty) return false;

    await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );


    try {
      await _supabase.auth.updateUser(sb.UserAttributes(password: newPassword));
      await db.update('users', {'is_synced': 1}, where: 'id = ?', whereArgs: [userId]);
    } catch (e) {
      print("⚠️ Chưa cập nhật pass lên Cloud được, sẽ sync sau.");
    }
    return true;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await _db.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1, // Chỉ lấy 1 bản ghi đầu tiên tìm thấy
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

}
