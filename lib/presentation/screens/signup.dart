import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_jars/controllers/user_controller.dart';
import 'package:flutter_application_jars/presentation/screens/login.dart';
import 'package:flutter_application_jars/presentation/widgets/auth_input.dart';
import 'package:flutter_application_jars/presentation/widgets/auth_button.dart';
import 'package:flutter_application_jars/presentation/validators/auth_validators.dart';

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

                    // if (kDebugMode)
                    //   TextButton(
                    //     onPressed: () async {
                    //       await _userController.resetUsers();

                    //       if (!mounted) return;

                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         const SnackBar(
                    //           content: Text(
                    //             'All users deleted (ID reset to 1)',
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //     child: const Text(
                    //       'RESET DATA (TESTDATA)',
                    //       style: TextStyle(
                    //         color: Colors.red,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),

                    // if (kDebugMode)
                    //   TextButton(
                    //     onPressed: () async {
                    //       await _userController.printAllUsers();
                    //     },
                    //     child: const Text(
                    //       'PRINT ALL USERS (TESTDATA)',
                    //       style: TextStyle(color: Colors.blue),
                    //     ),
                    //   ),
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

  Future<void> _handleSignup() async {
    // reset lỗi cũ
    setState(() {
      emailErrorText = null;
    });

    if (!formkey.currentState!.validate()) return;

    final user = await _userController.register(
      email.text.trim(),
      password.text.trim(),
    );

    if (!mounted) return;

    if (user == null) {
      setState(() {
        emailErrorText = 'Email already exists';
      });
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Register success')));

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
