import 'package:flutter/material.dart';
import '../../../../controllers/CategoryController.dart';
import '../../../../models/Category.dart';

class SelectCategoryForLimitPage extends StatefulWidget {
  final String selectedCategory;

  const SelectCategoryForLimitPage({super.key, required this.selectedCategory});

  @override
  State<SelectCategoryForLimitPage> createState() =>
      _SelectCategoryForLimitPageState();
}

class _SelectCategoryForLimitPageState
    extends State<SelectCategoryForLimitPage> {
  late TextEditingController _searchController;
  late CategoryController _categoryController;
  List<Category> _filteredCategories = [];
  List<Category> _allCategories = [];
  late Set<String> _selectedCategories;

  // 🔥 CHUYỂN Set<int> sang Set<String> để lưu UUID của cha đang mở rộng
  late Set<String> _expandedParentIds = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _categoryController = CategoryController();
    _selectedCategories = {};
    _loadCategories();
  }

  // Giữ nguyên mapping icon theo tên vì đây là logic UI
  int _fallbackIconIdByName(String categoryName) {
    final mapping = {
      'Ăn uống': 2, 'Cafe': 6, 'Di chuyển': 10, 'Giải trí': 15,
      'Mua sắm': 20, 'Sức khỏe': 25, 'Giáo dục': 30, 'Gia đình': 35,
      'Quà tặng': 40, 'Khác': 45, 'Lương': 50, 'Thưởng': 51,
      'Đầu tư': 52, 'Bán đồ': 53, 'Thu nhập khác': 54,
    };
    return mapping[categoryName] ?? 1;
  }

  String? _categoryIconPath(Category category) {
    final iconId = category.icon_id ?? _fallbackIconIdByName(category.name);
    return 'lib/assets/category_icon/$iconId.png';
  }

  Widget _buildCategoryIcon(Category category, {double size = 40}) {
    final iconPath = _categoryIconPath(category);
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: iconPath != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          iconPath, width: size, height: size, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.category, size: size * 0.6, color: Colors.grey),
        ),
      )
          : Icon(Icons.category, size: size * 0.6, color: Colors.grey),
    );
  }

  Future<void> _loadCategories() async {
    try {
      final expenseCategories = await _categoryController.getCategoriesByType(
        CategoryType.expense,
      );

      setState(() {
        _allCategories = expenseCategories;
        _filteredCategories = expenseCategories;
      });

      final Set<String> allCategoryNames = {};
      for (var parent in expenseCategories.where((cat) => cat.parent_id == null)) {
        allCategoryNames.add(parent.name);
        // 🔥 Đảm bảo id truyền vào là String UUID
        final children = await _getSubcategoriesForParent(parent.id ?? "");
        allCategoryNames.addAll(children.map((c) => c.name));
      }

      setState(() {
        _selectedCategories = allCategoryNames;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<List<Category>> _getSubcategoriesForParent(String parentId) async {
    return await _categoryController.getSubcategories(parentId);
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _allCategories;
      } else {
        _filteredCategories = _allCategories
            .where((category) => category.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleCategory(String categoryName, bool isSelected) {
    setState(() {
      isSelected ? _selectedCategories.add(categoryName) : _selectedCategories.remove(categoryName);
    });
  }

  void _selectAll() async {
    final allParentCategories = _filteredCategories.where((cat) => cat.parent_id == null).toList();
    final Set<String> allCategoryNames = {};
    for (var parent in allParentCategories) {
      allCategoryNames.add(parent.name);
      final children = await _getSubcategoriesForParent(parent.id ?? "");
      allCategoryNames.addAll(children.map((c) => c.name));
    }

    setState(() {
      if (_selectedCategories.containsAll(allCategoryNames) && _selectedCategories.length == allCategoryNames.length) {
        _selectedCategories.clear();
      } else {
        _selectedCategories.clear();
        _selectedCategories.addAll(allCategoryNames);
      }
    });
  }

  bool _isAllSelected() {
    final allParentCategories = _filteredCategories.where((cat) => cat.parent_id == null).toList();
    if (allParentCategories.isEmpty) return false;
    for (var parent in allParentCategories) {
      if (!_selectedCategories.contains(parent.name)) return false;
    }
    return true;
  }

  int _getTotalCategoryCount() => _allCategories.length;

  // 🔥 So sánh parentId kiểu String
  List<Category> _getChildCategories(String parentId) {
    return _allCategories.where((cat) => cat.parent_id == parentId).toList();
  }

  void _toggleExpanded(String parentId) {
    setState(() {
      _expandedParentIds.contains(parentId)
          ? _expandedParentIds.remove(parentId)
          : _expandedParentIds.add(parentId);
    });
  }

  int _getDisplayItemCount() {
    int count = 0;
    for (var category in _filteredCategories) {
      if (category.parent_id == null) {
        count += 1;
        if (_expandedParentIds.contains(category.id)) {
          final children = _getChildCategories(category.id ?? "");
          count += children.length;
        }
      }
    }
    return count;
  }

  Widget _buildCategoryItem(int displayIndex) {
    int currentIndex = 0;
    for (var category in _filteredCategories) {
      if (category.parent_id == null) {
        if (currentIndex == displayIndex) return _buildParentCategoryTile(category);
        currentIndex++;
        if (_expandedParentIds.contains(category.id)) {
          final children = _getChildCategories(category.id ?? "");
          for (var child in children) {
            if (currentIndex == displayIndex) return _buildChildCategoryTile(child);
            currentIndex++;
          }
        }
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildParentCategoryTile(Category category) {
    final isSelected = _selectedCategories.contains(category.name);
    final isExpanded = _expandedParentIds.contains(category.id);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<bool>(
                  future: _categoryController.getSubcategories(category.id ?? "").then((v) => v.isNotEmpty),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return IconButton(
                        icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                        onPressed: () => _toggleExpanded(category.id ?? ""),
                      );
                    }
                    return const SizedBox(width: 48);
                  },
                ),
                _buildCategoryIcon(category),
              ],
            ),
            title: Text(category.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (value) => _toggleParentCategory(category, value ?? false),
              activeColor: const Color(0xFF0288D1),
            ),
            onTap: () => _toggleParentCategory(category, !isSelected),
          ),
        ),
      ],
    );
  }

  void _toggleParentCategory(Category parent, bool isSelected) async {
    setState(() {
      isSelected ? _selectedCategories.add(parent.name) : _selectedCategories.remove(parent.name);
    });

    final children = await _getSubcategoriesForParent(parent.id ?? "");
    setState(() {
      if (isSelected) {
        _selectedCategories.addAll(children.map((c) => c.name));
      } else {
        _selectedCategories.removeAll(children.map((c) => c.name));
      }
    });
  }

  Widget _buildChildCategoryTile(Category category) {
    final isSelected = _selectedCategories.contains(category.name);
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: _buildCategoryIcon(category, size: 36),
        title: Text(category.name, style: const TextStyle(fontSize: 14)),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (value) => _toggleCategory(category.name, value ?? false),
          activeColor: const Color(0xFF0288D1),
        ),
        onTap: () => _toggleCategory(category.name, !isSelected),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text('Chọn hạng mục chi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE3F2FD),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCategories,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_getTotalCategoryCount()} hạng mục'),
                TextButton(onPressed: _selectAll, child: Text(_isAllSelected() ? 'Bỏ chọn hết' : 'Chọn tất cả')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getDisplayItemCount(),
              itemBuilder: (context, index) => _buildCategoryItem(index),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              // Logic kiểm tra hiển thị "Tất cả" hoặc danh sách tên
              final allParents = _allCategories.where((cat) => cat.parent_id == null).toList();
              bool allSelected = allParents.every((p) {
                final children = _getChildCategories(p.id ?? "");
                return _selectedCategories.contains(p.name) &&
                    children.every((c) => _selectedCategories.contains(c.name));
              });

              if (allSelected) {
                Navigator.pop(context, ['Tất cả hạng mục chi']);
              } else {
                Navigator.pop(context, _selectedCategories.toList());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0288D1)),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}