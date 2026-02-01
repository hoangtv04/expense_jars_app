import 'package:flutter/material.dart';
import 'package:flutter_application_jars/controllers/user_controller.dart';
import 'package:flutter_application_jars/models/user.dart';
import 'package:flutter_application_jars/presentation/screens/signup.dart';
import 'package:flutter_application_jars/presentation/widgets/auth_input.dart';
import 'package:flutter_application_jars/presentation/widgets/auth_button.dart';
import 'package:flutter_application_jars/presentation/screens/home.dart';

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

                    const SizedBox(height: 10),

                    AuthButton(text: 'LOGIN', onPressed: _handleLogin),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            // 🔥 KHÔNG NHÁY MÀN HÌNH
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

  Future<void> _handleLogin() async {
    if (!formkey.currentState!.validate()) return;

    final user = await _userController.login(
      email.text.trim(),
      password.text.trim(),
    );

    if (!mounted) return;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Wrong email or password')));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Login success')));

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
