import 'package:flutter/material.dart';
import 'package:flutter_application_jars/controllers/user_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final UserController _userController = UserController();

  int _step = 1;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ===== BACKGROUND =====
          Positioned.fill(
            child: Image.asset('lib/assets/login_bg.png', fit: BoxFit.cover),
          ),

          // ===== BODY =====
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ===== LOGO =====
                      Image.asset('lib/assets/login.png', width: 220),
                      const SizedBox(height: 20),

                      if (_step == 1) _emailStep(),
                      if (_step == 2) _otpStep(),
                      if (_step == 3) _newPasswordStep(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailStep() {
    return _card(
      Column(
        children: [
          const Text(
            'Forgot Password',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: InputBorder.none,
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Email is required' : null,
          ),
          const SizedBox(height: 16),
          _button(text: 'Send OTP', onPressed: _sendOtp),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // back to Login
            },
            child: const Text(
              'Back to Login',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpStep() {
    return _card(
      Column(
        children: [
          const Text(
            'Enter OTP',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'OTP Code',
              prefixIcon: Icon(Icons.lock),
              border: InputBorder.none,
            ),
            validator: (v) => v == null || v.length != 6 ? 'Invalid OTP' : null,
          ),
          const SizedBox(height: 16),
          _button(text: 'Verify OTP', onPressed: _verifyOtp),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _step = 1;
                _otpCtrl.clear();
              });
            },
            child: const Text(
              'Back',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _newPasswordStep() {
    return _card(
      Column(
        children: [
          const Text(
            'New Password',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPassCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'New password',
              prefixIcon: Icon(Icons.lock_outline),
              border: InputBorder.none,
            ),
            validator: (v) => v == null || v.length < 6
                ? 'Password must be at least 6 characters'
                : null,
          ),
          const SizedBox(height: 16),
          _button(text: 'Update Password', onPressed: _updatePassword),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _step = 2;
                _newPassCtrl.clear();
              });
            },
            child: const Text(
              'Back',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: MediaQuery.of(context).size.width * .9,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _button({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text),
      ),
    );
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final ok = await _userController.sendOtpToEmail(_emailCtrl.text.trim());

    setState(() => _isLoading = false);
    if (!ok) {
      _toast('Email not found');
      return;
    }

    _toast('OTP sent (check console)');
    setState(() => _step = 2);
  }

  void _verifyOtp() {
    if (!_formKey.currentState!.validate()) return;

    if (!_userController.verifyOtp(_otpCtrl.text.trim())) {
      _toast('Invalid OTP');
      return;
    }

    setState(() => _step = 3);
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final ok = await _userController.resetPassword(
      _emailCtrl.text.trim(),
      _newPassCtrl.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!ok) {
      _toast('Update failed');
      return;
    }

    _toast('Password updated');
    Navigator.pop(context);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
