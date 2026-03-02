import 'package:flutter/material.dart';
import 'SelectCategoryForLimitPage.dart';
import 'SelectAccountForLimitPage.dart';
import '../../../../controllers/SpendingLimitController.dart';

class AddSpendingLimitPage extends StatefulWidget {
  const AddSpendingLimitPage({super.key});

  @override
  State<AddSpendingLimitPage> createState() => _AddSpendingLimitPageState();
}

class _AddSpendingLimitPageState extends State<AddSpendingLimitPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final SpendingLimitController _controller = SpendingLimitController();

  String _selectedCategory = 'Tất cả hạng mục chi';
  String _selectedAccount = 'Tất cả tài khoản';
  String _repeatFrequency = 'Hàng tháng';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  String _formatAmountWithCommas(String value) {
    final digits = value.replaceAll(',', '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final indexFromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  void _onAmountChanged(String value) {
    final formatted = _formatAmountWithCommas(value);
    if (formatted == value) return;

    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

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

  String? _getCategoryIconPath(String categoryName) {
    if (categoryName.contains('Tất cả') || categoryName.contains(',')) {
      return null; // Không hiển thị icon nếu chọn nhiều hạng mục
    }
    final iconId = _fallbackIconIdByName(categoryName);
    return 'lib/assets/category_icon/$iconId.png';
  }

  Widget _buildCategoryIcon(String categoryName, {double size = 20}) {
    final iconPath = _getCategoryIconPath(categoryName);
    if (iconPath == null) return const SizedBox();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          iconPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.category, size: size * 0.6, color: Colors.grey);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _formatCategoryDisplay(String categoryString) {
    // Nếu chứa "Tất cả hạng mục chi" hoặc bằng chính xác thì hiển thị
    if (categoryString == 'Tất cả hạng mục chi' ||
        categoryString.contains('Tất cả hạng mục chi')) {
      return 'Tất cả hạng mục chi';
    }
    // Nếu danh sách dài quá, hiển thị số lượng
    final categories = categoryString.split(', ');
    if (categories.length > 3) {
      return '${categories.length} hạng mục';
    }
    return categoryString;
  }

  String _formatAccountDisplay(String accountString) {
    // Nếu chứa "Tất cả tài khoản" thì hiển thị "Tất cả tài khoản"
    if (accountString.contains('Tất cả tài khoản')) {
      return 'Tất cả tài khoản';
    }
    // Nếu danh sách dài quá, hiển thị số lượng
    final accounts = accountString.split(', ');
    if (accounts.length > 3) {
      return '${accounts.length} tài khoản';
    }
    return accountString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thêm hạn mức',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSpendingLimit,
          ),
        ],
        backgroundColor: const Color(0xFFE3F2FD),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Amount input section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Số tiền',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: IntrinsicWidth(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            onChanged: _onAmountChanged,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                              hintStyle: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700]?.withOpacity(0.3),
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'đ',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form fields section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildTextField(
                    icon: Icons.edit,
                    iconColor: Colors.orange,
                    hint: 'Tên hạn mức',
                    controller: _nameController,
                  ),
                  _buildDivider(),
                  _buildSelectItem(
                    icon: Icons.category,
                    iconColor: Colors.red,
                    label: 'Hạng mục chi',
                    value: _formatCategoryDisplay(_selectedCategory),
                    categoryIcon: _buildCategoryIcon(_selectedCategory),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectCategoryForLimitPage(
                            selectedCategory: _selectedCategory,
                          ),
                        ),
                      );
                      if (result != null && result is List) {
                        setState(() {
                          _selectedCategory = result.join(', ');
                        });
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildSelectItem(
                    icon: Icons.account_balance_wallet,
                    iconColor: Colors.grey,
                    label: 'Tài khoản',
                    value: _formatAccountDisplay(_selectedAccount),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectAccountForLimitPage(
                            selectedAccount: _selectedAccount,
                          ),
                        ),
                      );
                      if (result != null && result is List) {
                        setState(() {
                          _selectedAccount = result.join(', ');
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Repeat settings section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSelectItem(
                    icon: Icons.refresh,
                    iconColor: Colors.grey,
                    label: 'Lặp lại',
                    value: _repeatFrequency,
                    onTap: () {
                      _showRepeatDialog();
                    },
                  ),
                  _buildDivider(),
                  _buildSelectItem(
                    icon: Icons.calendar_today,
                    iconColor: Colors.grey,
                    label: 'Ngày bắt đầu',
                    value: _formatDate(_startDate),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                  ),
                  _buildDivider(),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ngày kết thúc',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _endDate == null
                                      ? 'Không xác định'
                                      : _formatDate(_endDate!),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Nút X để xóa ngày kết thúc
                          if (_endDate != null)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _endDate = null;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                              ),
                            ),
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Carry forward toggle
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _saveSpendingLimit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0288D1),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Lưu lại',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required Color iconColor,
    required String hint,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Widget? categoryIcon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (categoryIcon != null) ...[
                        categoryIcon,
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showRepeatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn chu kỳ lặp lại'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRepeatOption('Không lặp lại'),
            _buildRepeatOption('Hàng ngày'),
            _buildRepeatOption('Hàng tuần'),
            _buildRepeatOption('Hàng tháng'),
            _buildRepeatOption('Hàng quý'),
            _buildRepeatOption('Hàng năm'),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatOption(String option) {
    return RadioListTile<String>(
      title: Text(option),
      value: option,
      groupValue: _repeatFrequency,
      onChanged: (value) {
        setState(() {
          _repeatFrequency = value!;
        });
        Navigator.pop(context);
      },
    );
  }

  void _saveSpendingLimit() async {
    // Validate inputs
    final name = _nameController.text.trim();
    final amountStr = _amountController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên hạn mức chi')),
      );
      return;
    }

    if (amountStr.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số tiền')));
      return;
    }

    final amount = double.tryParse(amountStr.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    // Check if name already exists
    final nameExists = await _controller.checkNameExists(name);
    if (nameExists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tên hạn mức chi đã tồn tại. Vui lòng chọn tên khác.',
            ),
          ),
        );
      }
      return;
    }

    try {
      await _controller.addSpendingLimit(
        name: name,
        amount: amount,
        categories: _selectedCategory,
        accounts: _selectedAccount,
        repeatFrequency: _repeatFrequency,
        startDate: _startDate.toIso8601String().split('T')[0],
        endDate: _endDate != null
            ? _endDate!.toIso8601String().split('T')[0]
            : null,
        carryForward: false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu hạn mức chi thành công')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }
}
