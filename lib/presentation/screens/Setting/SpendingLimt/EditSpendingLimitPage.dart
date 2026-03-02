import 'package:flutter/material.dart';
import '../../../../models/SpendingLimit.dart';
import '../../../../controllers/SpendingLimitController.dart';
import 'SelectCategoryForLimitPage.dart';
import 'SelectAccountForLimitPage.dart';

class EditSpendingLimitPage extends StatefulWidget {
  final SpendingLimit spendingLimit;
  final Function()? onUpdated;

  const EditSpendingLimitPage({
    Key? key,
    required this.spendingLimit,
    this.onUpdated,
  }) : super(key: key);

  @override
  _EditSpendingLimitPageState createState() => _EditSpendingLimitPageState();
}

class _EditSpendingLimitPageState extends State<EditSpendingLimitPage> {
  late TextEditingController _amountController;
  late TextEditingController _nameController;
  late String _selectedCategory;
  late String _selectedAccount;
  late String _repeatFrequency;
  late DateTime _startDate;
  DateTime? _endDate;
  late SpendingLimit _limit;

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

  @override
  void initState() {
    super.initState();
    _limit = widget.spendingLimit;
    _amountController = TextEditingController(
      text: _formatAmountWithCommas(_limit.amount.toStringAsFixed(0)),
    );
    _nameController = TextEditingController(text: _limit.name);
    _selectedCategory = _limit.categories;
    _selectedAccount = _limit.accounts;
    _repeatFrequency = _limit.repeat_frequency;
    _startDate = DateTime.parse(_limit.start_date);
    _endDate = _limit.end_date != null
        ? DateTime.parse(_limit.end_date!)
        : null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _save() async {
    final amount =
        double.tryParse(
          _amountController.text.replaceAll('.', '').replaceAll(',', ''),
        ) ??
        0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    final newName = _nameController.text.trim().isEmpty
        ? 'Hạn mức chi'
        : _nameController.text.trim();

    // Check if name already exists (excluding current limit)
    final nameExists = await SpendingLimitController().checkNameExists(
      newName,
      excludeId: _limit.id,
    );
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

    final updated = SpendingLimit(
      id: _limit.id,
      user_id: _limit.user_id,
      name: newName,
      amount: amount,
      categories: _selectedCategory,
      accounts: _selectedAccount,
      repeat_frequency: _repeatFrequency,
      start_date: _startDate.toIso8601String().split('T')[0],
      end_date: _endDate != null
          ? _endDate!.toIso8601String().split('T')[0]
          : null,
      carry_forward: 0,
      is_deleted: _limit.is_deleted,
      created_at: _limit.created_at,
    );
    await SpendingLimitController().updateSpendingLimit(updated);
    widget.onUpdated?.call();
    Navigator.pop(context, true);
  }

  void _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa hạn mức chi này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SpendingLimitController().deleteSpendingLimit(_limit.id!);
      widget.onUpdated?.call();
      // Pop twice: once for detail page, once for edit page
      Navigator.pop(context, true); // Exit edit page
      Navigator.pop(context, true); // Exit detail page to go back to list
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCategoryDisplay(String categoryString) {
    // Nếu chứa "Tất cả hạng mục chi" hoặc bằng chính xác thì hiển thị
    if (categoryString == 'Tất cả hạng mục chi' ||
        categoryString.contains('Tất cả hạng mục chi')) {
      return 'Tất cả hạng mục chi';
    }
    final categories = categoryString.split(', ');
    if (categories.length > 3) {
      return '${categories.length} hạng mục';
    }
    return categoryString;
  }

  String _formatAccountDisplay(String accountString) {
    if (accountString.contains('Tất cả tài khoản')) {
      return 'Tất cả tài khoản';
    }
    final accounts = accountString.split(', ');
    if (accounts.length > 3) {
      return '${accounts.length} tài khoản';
    }
    return accountString;
  }

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
      return null;
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

  void _showRepeatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn tần suất'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              [
                    'Hàng ngày',
                    'Hàng tuần',
                    'Hàng tháng',
                    'Hàng năm',
                    'Không lặp lại',
                  ]
                  .map(
                    (freq) => RadioListTile<String>(
                      title: Text(freq),
                      value: freq,
                      groupValue: _repeatFrequency,
                      onChanged: (value) {
                        setState(() {
                          _repeatFrequency = value!;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  )
                  .toList(),
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
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400]),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey[200]);
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
          'Sửa hạn mức',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
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
                  _buildSelectItem(
                    icon: Icons.calendar_today_outlined,
                    iconColor: Colors.grey,
                    label: 'Ngày kết thúc',
                    value: _endDate != null
                        ? _formatDate(_endDate!)
                        : 'Không xác định',
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? _startDate,
                        firstDate: _startDate,
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                  ),
                  _buildDivider(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Delete and Save buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _delete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Xóa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0288D1),
                        foregroundColor: Colors.white,
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
