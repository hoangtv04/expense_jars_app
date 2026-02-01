import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_jars/models/user.dart';
import 'package:flutter_application_jars/repositories/user_repository.dart';

class UserController {
  final UserRepository _repository = UserRepository();

  String? _otpCache;
  String? _emailCache;

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

  Future<bool> sendOtpToEmail(String email) async {
    final exists = await _repository.isEmailExists(email);
    if (!exists) return false;

    final otp = (100000 + Random().nextInt(900000)).toString();

    _otpCache = otp;
    _emailCache = email;

    debugPrint('===== OTP SENT TO EMAIL =====');
    debugPrint('EMAIL: $email');
    debugPrint('OTP: $otp');
    debugPrint('===================================');

    return true;
  }

  bool verifyOtp(String inputOtp) {
    if (_otpCache == null) return false;
    return inputOtp == _otpCache;
  }

  Future<bool> resetPassword(String newPassword) async {
    if (_emailCache == null) return false;

    final success = await _repository.resetPassword(_emailCache!, newPassword);
    _otpCache = null;
    _emailCache = null;

    return success;
  }
}
