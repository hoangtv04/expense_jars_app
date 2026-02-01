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
  final _confirmPassCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final UserController _controller = UserController();

  int _step = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

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
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset('lib/assets/login.png', width: 220),
                    const SizedBox(height: 20),
                    if (_step == 1) _emailStep(context),
                    if (_step == 2) _otpStep(context),
                    if (_step == 3) _newPasswordStep(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailStep(BuildContext context) {
    return _card(
      context,
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
          _button('Send OTP', _sendOtp),
          const SizedBox(height: 12),
          _backToLogin(),
        ],
      ),
    );
  }

  Widget _otpStep(BuildContext context) {
    return _card(
      context,
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
              hintText: 'OTP',
              prefixIcon: Icon(Icons.lock),
              border: InputBorder.none,
            ),
            validator: (v) => v == null || v.length != 6 ? 'Invalid OTP' : null,
          ),
          const SizedBox(height: 16),
          _button('Verify OTP', _verifyOtp),
          _back(() {
            setState(() {
              _step = 1;
              _otpCtrl.clear();
            });
          }),
        ],
      ),
    );
  }

  Widget _newPasswordStep(BuildContext context) {
    return _card(
      context,
      Column(
        children: [
          const Text(
            'Create New Password',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // New password
          TextFormField(
            controller: _newPassCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'New password',
              prefixIcon: Icon(Icons.lock_outline),
              border: InputBorder.none,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'At least 6 characters';
              return null;
            },
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _confirmPassCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Confirm password',
              prefixIcon: Icon(Icons.lock),
              border: InputBorder.none,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Please confirm password';
              }
              if (v != _newPassCtrl.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),
          _button('Update Password', _updatePassword),
          _back(() {
            setState(() {
              _step = 2;
              _newPassCtrl.clear();
              _confirmPassCtrl.clear();
            });
          }),
        ],
      ),
    );
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final ok = await _controller.sendOtpToEmail(_emailCtrl.text.trim());

    setState(() => _isLoading = false);

    if (!ok) {
      _toast('Email does not exist');
      return;
    }

    _toast('OTP sent');
    setState(() => _step = 2);
  }

  void _verifyOtp() {
    if (!_formKey.currentState!.validate()) return;

    final ok = _controller.verifyOtp(_otpCtrl.text.trim());
    if (!ok) {
      _toast('Wrong OTP');
      return;
    }

    _toast('OTP verified');
    setState(() => _step = 3);
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final ok = await _controller.resetPassword(_newPassCtrl.text.trim());

    setState(() => _isLoading = false);

    if (!ok) {
      _toast('Update failed');
      return;
    }

    _toast('Password updated');
    Navigator.pop(context);
  }

  Widget _card(BuildContext context, Widget child) {
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

  Widget _button(String text, VoidCallback onPressed) {
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

  Widget _back(VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: const Text('Back', style: TextStyle(color: Colors.black87)),
    );
  }

  Widget _backToLogin() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        'Back to Login',
        style: TextStyle(color: Colors.black87),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
