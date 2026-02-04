import 'package:flutter/material.dart';
import '../../../controllers/TransactionController.dart';
import '../../../controllers/CategoryController.dart';
import '../../../controllers/JarController.dart';
import '../../../models/Transaction.dart';

class TransactionAddPage extends StatefulWidget {
  const TransactionAddPage({super.key});

  @override
  State<TransactionAddPage> createState() => _TransactionAddPageState();
}

class _TransactionAddPageState extends State<TransactionAddPage> {
  final _controller = TransactionController();
  final _controllerJar = JarController();
  final _controllerCategory = CategoryController();
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  int? _selectedJar;
  int? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm giao dịch'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Số tiền',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  if (amount == null || amount <= 0) {
                    return 'Nhập số tiền hợp lệ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              FutureBuilder(
                future: _controllerJar.getListJarIdAndName(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  return DropdownButtonFormField<int>(
                    value: _selectedJar,
                    decoration: InputDecoration(
                      labelText: 'Chọn hũ',
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: snapshot.data!.map((jar) {
                      return DropdownMenuItem(
                        value: jar.id,
                        child: Text(jar.name),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedJar = v),
                    validator: (v) => v == null ? 'Chọn hũ' : null,
                  );
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Danh mục',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              FutureBuilder(
                future: _controllerCategory.getAllCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  final categories = snapshot.data!;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: categories.map((c) {
                      final selected = _selectedCategory == c.id;
                      return ChoiceChip(
                        label: Text(c.name),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = c.id),
                        selectedColor: Colors.blue.shade100,
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Ghi chú',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    if (_selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chọn danh mục')),
                      );
                      return;
                    }

                    final transaction = Transaction(
                      userId: 1,
                      jarId: _selectedJar!,
                      categoryId: _selectedCategory!,
                      amount: double.parse(_amountController.text),
                      note: _noteController.text,
                      date: DateTime.now().toIso8601String(),
                      createdAt: DateTime.now().toIso8601String(),
                      isDeleted: 0,
                    );

                    await _controller.add(transaction);
                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    'Lưu giao dịch',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}