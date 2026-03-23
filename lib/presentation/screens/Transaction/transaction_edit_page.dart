import 'package:flutter/material.dart';
import '../../../controllers/TransactionController.dart';
import '../../../controllers/CategoryController.dart';
import '../../../controllers/JarController.dart';
import '../../../models/Transaction.dart';
import '../../../models/Category.dart';
import '../../../models/Jar.dart';
import '../../../services/session_services.dart';
import '../Category/CategoryListPage.dart';

class TransactionEditPage extends StatefulWidget {
  final Transaction transaction;

  const TransactionEditPage({super.key, required this.transaction});

  @override
  State<TransactionEditPage> createState() => _TransactionEditPageState();
}

class _TransactionEditPageState extends State<TransactionEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TransactionController();
  final _controllerJar = JarController();
  final _controllerCategory = CategoryController();

  late TextEditingController _amountController;
  late TextEditingController _noteController;

  // 🔥 Quản lý ID và Object để hiển thị UI
  String? _selectedJar;
  String? _selectedCategory;
  Category? _selectedCategoryObject;
  Jar? _selectedJarObject;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _noteController = TextEditingController(text: widget.transaction.note ?? '');

    // Gán ID ban đầu
    _selectedJar = widget.transaction.jarId;
    _selectedCategory = widget.transaction.categoryId;

    // Load dữ liệu chi tiết để hiển thị Icon/Tên hũ ngay khi vào trang
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cat = await _controllerCategory.getCategoryById(_selectedCategory!);
    final jar = await _controllerJar.getJarById(_selectedJar!);
    setState(() {
      _selectedCategoryObject = cat;
      _selectedJarObject = jar;
    });
  }

  // --- Copy các hàm hỗ trợ hiển thị Icon từ trang Add ---
  int _fallbackIconIdByName(String categoryName) {
    final mapping = {'Ăn uống': 2, 'Cafe': 6, 'Di chuyển': 10, 'Giải trí': 15, 'Mua sắm': 20, 'Lương': 50, 'Thưởng': 51};
    return mapping[categoryName] ?? 1;
  }

  String? _getCategoryIconPath(Category? category) {
    if (category == null) return null;
    final iconId = category.icon_id ?? _fallbackIconIdByName(category.name);
    return 'lib/assets/category_icon/$iconId.png';
  }

  Widget _buildCategoryIcon(Category? category, {double size = 24}) {
    final iconPath = _getCategoryIconPath(category);
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
      child: iconPath != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(iconPath, width: size, height: size, fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Icon(Icons.category, size: size * 0.6)),
      )
          : Icon(Icons.category, size: size * 0.6, color: Colors.grey),
    );
  }

  Widget _buildCategoryField() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<Category>(
          context,
          MaterialPageRoute(builder: (context) => const CategoryListPage(isSelectionMode: true)),
        );
        if (result != null) {
          setState(() {
            _selectedCategoryObject = result;
            _selectedCategory = result.id;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.category),
            const SizedBox(width: 16),
            if (_selectedCategoryObject != null) _buildCategoryIcon(_selectedCategoryObject, size: 20),
            if (_selectedCategoryObject != null) const SizedBox(width: 8),
            Text(_selectedCategoryObject?.name ?? 'Chọn hạng mục', style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sửa giao dịch'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Số tiền
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Số tiền',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  if (amount == null || amount <= 0) return 'Nhập số tiền hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 2. Chọn Hũ (Dropdown)
              FutureBuilder(
                future: _controllerJar.getListJarIdAndName(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  return DropdownButtonFormField<String>(
                    value: _selectedJar,
                    decoration: InputDecoration(
                      labelText: 'Chọn hũ',
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: (snapshot.data as List).map((jar) {
                      return DropdownMenuItem<String>(value: jar.id, child: Text(jar.name));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedJar = v),
                    validator: (v) => v == null ? 'Chọn hũ' : null,
                  );
                },
              ),
              const SizedBox(height: 20),

              // 3. Chọn Hạng mục
              _buildCategoryField(),
              const SizedBox(height: 20),

              // 4. Ghi chú
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Ghi chú',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),

              // 5. Nút Lưu
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

                    // Tạo bản cập nhật từ bản cũ
                    final updatedTransaction = widget.transaction.copyWith(
                      amount: double.parse(_amountController.text),
                      note: _noteController.text,
                      jarId: _selectedJar,
                      categoryId: _selectedCategory,

                      // Nếu có đổi category, cập nhật luôn type (income/expense)
                      type: _selectedCategoryObject?.type,
                    );

                    await _controller.update(updatedTransaction);
                    if (mounted) Navigator.pop(context, true);
                  },
                  child: const Text('Lưu thay đổi', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}