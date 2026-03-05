import 'package:flutter/material.dart';
import '../../../controllers/TransactionController.dart';
import '../../../models/Transaction.dart';

class TransactionEditPage extends StatefulWidget {
  final Transaction transaction;

  const TransactionEditPage({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionEditPage> createState() =>
      _TransactionEditPageState();
}

class _TransactionEditPageState
    extends State<TransactionEditPage> {

  final _formKey = GlobalKey<FormState>();
  final _controller = TransactionController();

  late TextEditingController _amountController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    _noteController =
        TextEditingController(text: widget.transaction.note ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sửa giao dịch')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số tiền',
                ),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  if (amount == null || amount <= 0) {
                    return 'Nhập số tiền hợp lệ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final updatedTransaction =
                  widget.transaction.copyWith(
                    amount:
                    double.parse(_amountController.text),
                    note: _noteController.text,
                  );

                  await _controller.update(updatedTransaction);

                  Navigator.pop(context, true);
                },
                child: const Text('Lưu thay đổi'),
              )
            ],
          ),
        ),
      ),
    );
  }
}