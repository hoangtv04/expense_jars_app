import 'package:flutter/material.dart';
import 'package:flutter_application_jars/controllers/user_controller.dart';
// import 'package:flutter_application_jars/models/user.dart'; // Đã dùng trong controller
import 'package:flutter_application_jars/presentation/MainPage.dart';
import 'package:flutter_application_jars/presentation/screens/signup.dart';
import 'package:flutter_application_jars/presentation/widgets/auth_input.dart';
import 'package:flutter_application_jars/presentation/widgets/auth_button.dart';
// import 'package:flutter_application_jars/presentation/screens/home.dart';
import 'package:flutter_application_jars/presentation/screens/forgot_password.dart';
import 'package:flutter_application_jars/services/session_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final formkey = GlobalKey<FormState>();
  bool isVisible = false;

  final UserController _userController = UserController();

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
                      validator: (v) =>
                      v == null || v.isEmpty ? 'Enter email' : null,
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

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    AuthButton(text: 'LOGIN', onPressed: _handleLogin),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const Signup(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: const Text("Sign Up"),
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

  // --- PHẦN LOGIC ĐÃ ĐƯỢC CẬP NHẬT ---
  Future<void> _handleLogin() async {
    if (!formkey.currentState!.validate()) return;

    // Hiển thị loading để người dùng biết app đang xử lý (nhất là khi sync)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Sử dụng hàm signIn trong UserController (hàm đã bao gồm sync và check mạng)
      await _userController.signIn(
        email.text.trim(),
        password.text.trim(),
      );

      // Tắt loading
      if (!mounted) return;
      Navigator.pop(context);

      // Kiểm tra xem session đã được lưu chưa (để xác nhận đăng nhập thành công)
      final currentId = await SessionService.getUserId();

      if (currentId != null) {
        debugPrint("✅ CURRENT USER ID: $currentId");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login success!')),
        );

        // Chuyển hướng vào MainPage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
              (route) => false,
        );
      } else {
        // Trường hợp không tìm thấy user (sai pass hoặc chưa từng login offline)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wrong email or password')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tắt loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}