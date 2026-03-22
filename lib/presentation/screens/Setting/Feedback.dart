import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Feedback extends StatelessWidget {
  const Feedback({super.key});

  // Link Google Form 
  final String formUrl = "https://forms.gle/wwdhGeB1pduKjYh66"; // Thay bằng link thật

  // Hàm mở link
  Future<void> _openForm() async {
    final Uri url = Uri.parse(formUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Nếu lỗi
      throw 'Could not launch $formUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: const Color(0xFF2E86DE),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.open_in_new),
          label: const Text('Gửi phản hồi qua Google Form'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            backgroundColor: Colors.orange,
          ),
          onPressed: _openForm,
        ),
      ),
    );
  }
}