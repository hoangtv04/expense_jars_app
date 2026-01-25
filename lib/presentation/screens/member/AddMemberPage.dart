


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../controllers/MemberController.dart';

class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _controller = MemberController();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();

  void _save() async {
    try {
      await _controller.addMember(
        _nameController.text,
        _roleController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm thành viên'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(
                labelText: 'Vai trò',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}