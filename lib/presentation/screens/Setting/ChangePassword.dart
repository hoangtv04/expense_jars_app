import 'package:flutter/material.dart';
import 'package:flutter_application_jars/services/session_services.dart';
import 'package:flutter_application_jars/repositories/user_repository.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final oldPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

  Future<void> handleChange() async {
    if (newPass.text != confirmPass.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Mật khẩu không khớp")));
      return;
    }

    final userId = await SessionService.getUserId();
    if (userId == null) return;

    final success = await UserRepository().changePassword(
      userId,
      oldPass.text.trim(),
      newPass.text.trim(),
    );

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đổi mật khẩu thành công")));

      await SessionService.logout();

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Sai mật khẩu cũ")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đổi mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: oldPass,
              decoration: const InputDecoration(labelText: "Mật khẩu cũ"),
            ),
            TextField(
              controller: newPass,
              decoration: const InputDecoration(labelText: "Mật khẩu mới"),
            ),
            TextField(
              controller: confirmPass,
              decoration: const InputDecoration(labelText: "Xác nhận mật khẩu"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleChange,
              child: const Text("Cập nhật"),
            ),
          ],
        ),
      ),
    );
  }
}
