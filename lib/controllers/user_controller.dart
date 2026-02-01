import '../models/user.dart';
import '../repositories/user_repository.dart';
import 'package:flutter/foundation.dart';

class UserController {
  final UserRepository _repository = UserRepository();

  Future<User?> login(String email, String password) {
    return _repository.login(email, password);
  }

  Future<User?> register(String email, String password) async {
    final User? user = await _repository.register(email, password);

    if (user != null) {
      debugPrint('========== REGISTER USER ==========');
      debugPrint('ID: ${user.id}');
      debugPrint('Email: ${user.email}');
      debugPrint('Password: ${user.password}');
      debugPrint('===================================');
    }

    return user;
  }

  Future<void> resetUsers() async {
    await _repository.resetUsers();

    debugPrint('===== USERS TABLE RESET =====');
  }

  Future<void> printAllUsers() async {
    final users = await _repository.getAllUsers();

    debugPrint('========== ALL USERS ==========');

    if (users.isEmpty) {
      debugPrint('No users found');
    } else {
      for (final user in users) {
        debugPrint(
          'ID: ${user.id} | Email: ${user.email} | Password: ${user.password}',
        );
      }
    }

    debugPrint('===============================');
  }
}
