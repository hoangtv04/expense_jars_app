import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const AuthButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 🔥 GIỐNG HỆT Ô INPUT
      margin: const EdgeInsets.all(8),
      height: 55,
      width: double.infinity, // 👈 full width giống TextField
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8), // 👈 giống input
        color: Colors.orange,
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
