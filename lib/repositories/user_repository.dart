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
    if (exists) {
      return null;
    }

    final int id = await _db.registerRaw(email, password);

    if (id > 0) {
      final data = await _db.getUserById(id);
      if (data != null) {
        return User.fromMap(data);
      }
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
}
