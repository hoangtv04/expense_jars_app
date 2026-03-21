import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter_application_jars/controllers/user_controller.dart';
import 'package:flutter_application_jars/presentation/screens/login.dart';
import 'package:flutter_application_jars/presentation/widgets/auth_input.dart';
import 'package:flutter_application_jars/presentation/widgets/auth_button.dart';
import 'package:flutter_application_jars/presentation/validators/auth_validators.dart';
import 'package:flutter_application_jars/services/session_services.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final formkey = GlobalKey<FormState>();
  bool isVisible = false;

  final UserController _userController = UserController();

  String? emailErrorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('lib/assets/login_bg.png', fit: BoxFit.cover),
          ),
          Center(
            child: SingleChildScrollView(
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    Image.asset('lib/assets/login.png', width: 250),
                    const SizedBox(height: 15),

                    AuthInput(
                      controller: email,
                      hint: 'Email',
                      icon: Icons.email,
                      validator: signupEmailValidator,
                      errorText: emailErrorText,
                    ),

                    AuthInput(
                      controller: password,
                      hint: 'Password',
                      icon: Icons.lock,
                      obscure: !isVisible,
                      validator: (v) =>
                      v == null || v.isEmpty ? 'Enter password' : null,
                      suffix: IconButton(
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => isVisible = !isVisible);
                        },
                      ),
                    ),

                    AuthInput(
                      controller: confirmPassword,
                      hint: 'Confirm Password',
                      icon: Icons.lock_outline,
                      obscure: true,
                      validator: (v) =>
                      v != password.text ? 'Password not match' : null,
                    ),

                    const SizedBox(height: 10),

                    AuthButton(text: 'SIGN UP', onPressed: _handleSignup),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                const LoginScreen(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: const Text("Login"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC ĐĂNG KÝ CẬP NHẬT ---
  Future<void> _handleSignup() async {
    setState(() {
      emailErrorText = null;
    });

    if (!formkey.currentState!.validate()) return;

    // 1. Hiện Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Kiểm tra nếu máy đang có Session của ai đó thì dọn dẹp trước khi tạo mới
      final String? oldUserId = await SessionService.getUserId();
      if (oldUserId != null) {
        // Gọi hàm clearAllData từ UserController thông qua SyncService
        // Đảm bảo máy sạch sẽ cho User mới
        await _userController.resetUsers();
      }

      // 3. Gọi hàm register (Hàm này đã được nâng cấp để dùng Supabase ID)
      final user = await _userController.registerV2(
        email.text.trim(),
        password.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context); // Tắt Loading

      if (user == null) {
        setState(() {
          emailErrorText = 'Email already exists or connection error';
        });
        return;
      }

      // 4. Thông báo và chuyển hướng
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register success! Please login.')),
      );

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tắt Loading

      setState(() {
        emailErrorText = e.toString().contains('already registered')
            ? 'This email is already taken'
            : 'Registration failed. Try again.';
      });
    }
  }
}