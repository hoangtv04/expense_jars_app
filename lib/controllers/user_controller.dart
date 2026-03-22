import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_jars/models/user.dart';
import 'package:flutter_application_jars/repositories/SyncService.dart';
import 'package:flutter_application_jars/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../repositories/NetworkService.dart';
import '../services/session_services.dart';

class UserController {
  final UserRepository _repository = UserRepository();
  final _supabase = sb.Supabase.instance.client;
  final SyncService _syncService = SyncService();

  String? _otpCache;
  String? _emailCache;

  Future<User?> login(String email, String password) async {
    return _repository.login(email, password);
  }

  Future<User?> register(String email, String password) async {
    // bool isOnline = await checkInternet(); // Hàm check internet của bạn
    //
    // if (!isOnline) {
    //   // Thông báo cho người dùng
    //   showSnackBar("Cần kết nối mạng để tạo tài khoản mới!");
    //   return;
    // }

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

  String getDisplayName(User user) {
    String rawName = user.fullName ?? user.email.split('@')[0];

    return rawName
        .replaceAll(RegExp(r'[^a-zA-Z]'), ' ')
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
        .join(' ');
  }

  Future<bool> signIn(String email, String password) async {
    try {
      // 1. Gọi login từ Repository (Nó đã tự check Online/Offline)
      final User? user = await _repository.login(email, password);

      if (user != null) {
        final String? oldUserId = await SessionService.getUserId();

        // 2. Check đổi tài khoản (Dùng UUID String để so sánh)
        if (oldUserId != null && oldUserId != user.id) {
          debugPrint("⚠️ Đổi tài khoản, đang xóa dữ liệu cũ...");
          await _syncService.clearAllData();
        }

        // 3. Lưu Session (Cực kỳ quan trọng để các màn sau lấy được user_id)
        await SessionService.saveSession(user.id, user.email);

        // 4. Đồng bộ (Chỉ chạy khi có mạng)
        bool isOnline = await NetworkService.isOnline();
        if (isOnline) {
          debugPrint("🔄 Đang đồng bộ dữ liệu đám mây...");
          try {
            // Đẩy dữ liệu local lên trước
            await _syncService.syncAll();
            // Tải dữ liệu từ server về sau
            await _syncService.downloadAllDataFromServer(user.id);
          } catch (syncError) {
            // Nếu lỗi sync thì vẫn cho vào App, nhưng báo log để debug
            debugPrint("⚠️ Lỗi đồng bộ nhưng vẫn cho đăng nhập: $syncError");
          }
        }

        debugPrint("✅ Đăng nhập thành công!");
        return true; // Trả về true để mở cổng MainPage
      } else {
        debugPrint("❌ Đăng nhập thất bại: Sai email hoặc mật khẩu");
        return false; // Trả về false để hiện thông báo lỗi ở UI
      }
    } catch (e) {
      debugPrint("❌ Lỗi hệ thống khi đăng nhập: $e");
      return false; // Trả về false khi gặp lỗi crash/mạng
    }
  }
  Future<User?> registerV2(String email, String password) async {
    // Đăng ký bắt buộc phải có mạng
    final User? user = await _repository.register(email, password);
    if (user != null) {
      await SessionService.saveSession(user.id, user.email);
    }
    return user;
  }

}
