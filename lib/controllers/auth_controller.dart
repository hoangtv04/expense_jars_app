import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== SEND RESET PASSWORD EMAIL =====
  Future<void> sendResetPasswordEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
