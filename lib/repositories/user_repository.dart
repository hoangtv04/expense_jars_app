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
      final authRes = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // ✅ Login online thành công
      if (authRes.user != null) {
        final user = User(
          id: authRes.user!.id,
          email: email,
          password: password,
          isSynced: 1,
        );

        await _syncService.insertUser(user.toMap());
        return user;
      }

    } on sb.AuthException catch (e) {
      // ❌ Sai tài khoản hoặc password → KHÔNG fallback
      print("❌ Sai email hoặc mật khẩu: ${e.message}");
      return null;

    } catch (e) {
      // 🌐 Lỗi mạng / server → mới fallback offline
      print("🌐 Lỗi mạng, thử login offline: $e");

      final data = await getUserByEmail(email);

      if (data != null && data['password'] == password) {
        return User.fromMap(data);
      } else {
        print("❌ Offline cũng sai luôn");
        return null;
      }
    }

    return null;
  }

  Future<User?> register(String email, String password) async {
    try {
      // 1. Đăng ký trên Auth của Supabase
      final authRes = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (authRes.user == null) {
        print("Step 1.1: Auth thành công nhưng User null (Check Confirm Email Provider!)");
        return null;
      }
      final sb.User? sbUser = authRes.user;

      if (sbUser != null) {
        // 🔥 BƯỚC QUAN TRỌNG: Chèn vào bảng public.users trên Supabase
        // Nếu không có bước này, các bảng jars/transactions sau này sẽ báo lỗi Foreign Key
        await _supabase.from('users').insert({
          'id': sbUser.id,
          'email': email,
          'password': password, // Lưu ý: thực tế nên mã hóa hoặc bỏ qua cột này ở public
        });

        // 2. Tạo Model User cho SQLite
        final newUser = User(
          id: sbUser.id,
          email: email,
          password: password,
          isSynced: 1,
        );

        // 3. Lưu vào SQLite local
        await _syncService.insertUser(newUser.toMap());

        return newUser;
      }
    } on sb.AuthException catch (e) {
      print("❌ Lỗi Auth: ${e.message}");
      rethrow;
    } catch (e) {
      print("❌ Lỗi Database: $e");
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

  Future<void> updateProfile(
    String id,
    String fullName,
    String phone,
    String gender,
    String birth,
  ) async {
    final db = await _db.database;

    await db.update(
      'users',
      {'full_name': fullName, 'phone': phone, 'gender': gender, 'birth': birth},
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
