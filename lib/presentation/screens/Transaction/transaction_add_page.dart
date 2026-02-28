import 'package:flutter/material.dart';
import '../../../controllers/TransactionController.dart';
import '../../../controllers/CategoryController.dart';
import '../../../controllers/JarController.dart';
import '../../../models/Transaction.dart';
import '../../../models/Category.dart';
import '../Category/CategoryListPage.dart';

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
  Category? _selectedCategoryObject;

  // Fallback icon mapping by category name
  int _fallbackIconIdByName(String categoryName) {
    final mapping = {
      'Ăn uống': 2,
      'Cafe': 6,
      'Di chuyển': 10,
      'Giải trí': 15,
      'Mua sắm': 20,
      'Sức khỏe': 25,
      'Giáo dục': 30,
      'Gia đình': 35,
      'Quà tặng': 40,
      'Khác': 45,
      'Lương': 50,
      'Thưởng': 51,
      'Đầu tư': 52,
      'Bán đồ': 53,
      'Thu nhập khác': 54,
    };
    return mapping[categoryName] ?? 1;
  }

  String? _getCategoryIconPath(Category? category) {
    if (category == null) return null;
    final iconId = category.icon_id ?? _fallbackIconIdByName(category.name);
    return 'lib/assets/category_icon/$iconId.png';
  }

  Widget _buildCategoryIcon(Category? category, {double size = 24}) {
    final iconPath = category != null ? _getCategoryIconPath(category) : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: iconPath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                iconPath,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.category,
                    size: size * 0.6,
                    color: Colors.grey,
                  );
                },
              ),
            )
          : Icon(Icons.category, size: size * 0.6, color: Colors.grey),
    );
  }

  Widget _buildCategoryIconRow(Category? category) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.category),
        const SizedBox(width: 6),
        _buildCategoryIcon(category, size: 20),
      ],
    );
  }

  Widget _buildCategoryField() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<Category>(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoryListPage(isSelectionMode: true),
          ),
        );

        if (result != null) {
          setState(() {
            _selectedCategoryObject = result;
            _selectedCategory = result.id;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 12.0,
                top: 16.0,
                bottom: 16.0,
              ),
              child: const Icon(Icons.category),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  top: 16.0,
                  bottom: 16.0,
                ),
                child: Row(
                  children: [
                    if (_selectedCategoryObject != null)
                      _buildCategoryIcon(_selectedCategoryObject, size: 20),
                    if (_selectedCategoryObject != null)
                      const SizedBox(width: 8),
                    Text(
                      _selectedCategoryObject?.name ?? 'Chọn hạng mục',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedCategoryObject == null)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPrefixRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.category),
        const SizedBox(width: 6),
        _buildCategoryIcon(_selectedCategoryObject, size: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm giao dịch'), centerTitle: true),
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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

              const SizedBox(height: 20),

              // Category Selection Field
              _buildCategoryField(),

              const SizedBox(height: 20),

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

                    _controllerJar.updateJarAmount(
                      _selectedJar!,
                      -double.parse(_amountController.text),
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
