import 'package:flutter/material.dart';
import '../../../controllers/TransactionController.dart';
import '../../../models/Transaction.dart';


class TransactionAddPage extends StatelessWidget {
  final _controller = TransactionController();
  final _amountController = TextEditingController();

  TransactionAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final transaction = Transaction(
                  userId: 1,
                  jarId: 1,
                  categoryId: 1,
                  amount: double.parse(_amountController.text),
                  date: DateTime.now().toString(),
                );
                await _controller.add(transaction);
                Navigator.pop(context, true);
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}