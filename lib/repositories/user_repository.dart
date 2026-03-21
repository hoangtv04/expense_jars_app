import 'package:flutter_application_jars/db/app_database.dart';
import 'package:flutter_application_jars/models/user.dart';

class UserRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<User?> login(String email, String password) async {
    final data = await _db.loginRaw(email, password);

    if (data != null) {
      return User.fromMap(data);
    }

    return null;
  }

  Future<User?> register(String email, String password) async {
    final bool exists = await _db.isEmailExists(email);
    if (exists) return null;

    await _db.registerRaw(email, password);

    final data = await _db.loginRaw(email, password);
    if (data != null) {
      return User.fromMap(data);
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

    return true;
  }
}
