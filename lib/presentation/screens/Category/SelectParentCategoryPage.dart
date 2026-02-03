import 'package:flutter/material.dart';
import '../../../models/Category.dart';

class SelectParentCategoryPage extends StatefulWidget {
  final List<Category> parentCategories;
  final Category? currentSelectedParent;

  const SelectParentCategoryPage({
    super.key,
    required this.parentCategories,
    this.currentSelectedParent,
  });

  @override
  State<SelectParentCategoryPage> createState() =>
      _SelectParentCategoryPageState();
}

class _SelectParentCategoryPageState extends State<SelectParentCategoryPage> {
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentSelectedParent;
  }

  String _getCategoryEmoji(String name) {
    final emojiMap = {
      'Ăn uống': '🍎',
      'Dịch vụ sinh hoạt': '🏠',
      'Đi lại': '📍',
      'Con cái': '👶',
      'Trang phục': '👔',
      'Hiếu hỉ': '🌾',
      'Sức khỏe': '❤️',
      'Nhà cửa': '🏠',
      'Hưởng thụ': '🎁',
      'Phát triển bản thân': '👨',
      'Ngân hàng': '🏦',
      'Tiền ra': '💸',
    };
    return emojiMap[name] ?? '📁';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hạng mục cha',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // "Không chọn" option
          _buildCategoryItem(
            icon: '--',
            backgroundColor: Colors.grey[200]!,
            title: 'Không chọn',
            isSelected: _selectedCategory == null,
            onTap: () {
              setState(() {
                _selectedCategory = null;
              });
              Navigator.pop(context, null);
            },
          ),
          // Parent categories
          ...widget.parentCategories.map((category) {
            final isSelected = _selectedCategory?.id == category.id;
            return _buildCategoryItem(
              icon: _getCategoryEmoji(category.name),
              backgroundColor: Colors.lightBlue[100]!,
              title: category.name,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
                Navigator.pop(context, category);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required String icon,
    required Color backgroundColor,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[100] : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Colors.blue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
