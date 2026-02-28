import 'package:flutter/material.dart';
import '../../../controllers/CategoryController.dart';
import '../../../models/Category.dart';

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
  late Set<int> _expandedParentIds = {}; // Track expanded parent categories

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _categoryController = CategoryController();
    _selectedCategories = {};
    _loadCategories();
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

  String? _categoryIconPath(Category category) {
    final iconId =
        category.icon_id ?? _fallbackIconIdByName(category.name ?? '');
    return 'lib/assets/category_icon/$iconId.png';
  }

  Widget _buildCategoryIcon(Category category, {double size = 40}) {
    final iconPath = _categoryIconPath(category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: iconPath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
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

  Future<void> _loadCategories() async {
    try {
      // Sử dụng getCategoriesByType để giữ nguyên thứ tự như CategoryListPage
      final expenseCategories = await _categoryController.getCategoriesByType(
        CategoryType.expense,
      );

      setState(() {
        _allCategories = expenseCategories;
        _filteredCategories = expenseCategories;
      });

      // Mặc định chọn tất cả hạng mục (cha + con)
      final Set<String> allCategoryNames = {};
      for (var parent in expenseCategories.where(
        (cat) => cat.parent_id == null,
      )) {
        allCategoryNames.add(parent.name ?? '');
        final children = await _getSubcategoriesForParent(parent.id ?? 0);
        allCategoryNames.addAll(children.map((c) => c.name ?? ''));
      }

      setState(() {
        _selectedCategories = allCategoryNames;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<List<Category>> _getSubcategoriesForParent(int parentId) async {
    return await _categoryController.getSubcategories(parentId);
  }

  void _filterCategories(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCategories = _allCategories;
      });
    } else {
      setState(() {
        _filteredCategories = _allCategories
            .where(
              (category) => (category.name ?? '').toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      });
    }
  }

  void _toggleCategory(String categoryName, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedCategories.add(categoryName);
      } else {
        _selectedCategories.remove(categoryName);
      }
    });
  }

  void _selectAll() async {
    // Lấy tất cả hạng mục cha
    final allParentCategories = _filteredCategories
        .where((cat) => cat.parent_id == null)
        .toList();

    // Lấy tất cả hạng mục (cha + con)
    final Set<String> allCategoryNames = {};
    for (var parent in allParentCategories) {
      allCategoryNames.add(parent.name ?? '');
      final children = await _getSubcategoriesForParent(parent.id ?? 0);
      allCategoryNames.addAll(children.map((c) => c.name ?? ''));
    }

    setState(() {
      // Nếu tất cả đều đã được chọn, thì bỏ chọn tất cả
      if (_selectedCategories.containsAll(allCategoryNames) &&
          _selectedCategories.length == allCategoryNames.length) {
        _selectedCategories.clear();
      } else {
        // Nếu không, chọn tất cả
        _selectedCategories.clear();
        _selectedCategories.addAll(allCategoryNames);
      }
    });
  }

  bool _isAllSelected() {
    // Kiểm tra xem tất cả hạng mục có được chọn không
    final allParentCategories = _filteredCategories
        .where((cat) => cat.parent_id == null)
        .toList();

    if (allParentCategories.isEmpty) return false;

    for (var parent in allParentCategories) {
      if (!_selectedCategories.contains(parent.name ?? '')) {
        return false;
      }
    }

    return true;
  }

  int _getTotalCategoryCount() {
    return _allCategories.length;
  }

  List<Category> _getChildCategories(int parentId) {
    return _allCategories.where((cat) => cat.parent_id == parentId).toList();
  }

  Future<bool> _hasSubcategories(int parentId) async {
    final subcats = await _getSubcategoriesForParent(parentId);
    return subcats.isNotEmpty;
  }

  void _toggleExpanded(int parentId) {
    setState(() {
      if (_expandedParentIds.contains(parentId)) {
        _expandedParentIds.remove(parentId);
      } else {
        _expandedParentIds.add(parentId);
      }
    });
  }

  int _getDisplayItemCount() {
    int count = 0;
    for (var category in _filteredCategories) {
      if (category.parent_id == null) {
        count += 1;
        if (_expandedParentIds.contains(category.id)) {
          final children = _getChildCategories(category.id ?? 0);
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
        if (currentIndex == displayIndex) {
          return _buildParentCategoryTile(category);
        }
        currentIndex++;

        if (_expandedParentIds.contains(category.id)) {
          final children = _getChildCategories(category.id ?? 0);
          for (var child in children) {
            if (currentIndex == displayIndex) {
              return _buildChildCategoryTile(child);
            }
            currentIndex++;
          }
        }
      }
    }
    return SizedBox.shrink();
  }

  Widget _buildParentCategoryTile(Category category) {
    final categoryName = category.name ?? 'Không có tên';
    final isSelected = _selectedCategories.contains(categoryName);
    final isExpanded = _expandedParentIds.contains(category.id);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<bool>(
                  future: _hasSubcategories(category.id ?? 0),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return IconButton(
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.grey,
                          size: 24,
                        ),
                        onPressed: () => _toggleExpanded(category.id ?? 0),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      );
                    }
                    return const SizedBox(width: 40);
                  },
                ),
                const SizedBox(width: 8),
                _buildCategoryIcon(category, size: 40),
              ],
            ),
            title: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (value) {
                _toggleParentCategory(category, value ?? false);
              },
              activeColor: const Color(0xFF0288D1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onTap: () {
              _toggleParentCategory(category, !isSelected);
            },
          ),
        ),
        if (isExpanded)
          FutureBuilder<List<Category>>(
            future: _getSubcategoriesForParent(category.id ?? 0),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Column(
                  children: snapshot.data!
                      .map((child) => _buildChildCategoryTile(child))
                      .toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }

  void _toggleParentCategory(Category parent, bool isSelected) async {
    setState(() {
      final parentName = parent.name ?? '';
      if (isSelected) {
        _selectedCategories.add(parentName);
      } else {
        _selectedCategories.remove(parentName);
      }
    });

    // Tải hạng mục con từ database và cập nhật selection
    if (isSelected) {
      final children = await _getSubcategoriesForParent(parent.id ?? 0);
      setState(() {
        _selectedCategories.addAll(children.map((c) => c.name ?? ''));
      });
    } else {
      final children = await _getSubcategoriesForParent(parent.id ?? 0);
      setState(() {
        _selectedCategories.removeAll(children.map((c) => c.name ?? ''));
      });
    }
  }

  Widget _buildChildCategoryTile(Category category) {
    final categoryName = category.name ?? 'Không có tên';
    final isSelected = _selectedCategories.contains(categoryName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildCategoryIcon(category, size: 36),
        title: Text(
          categoryName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (value) {
            _toggleCategory(categoryName, value ?? false);
          },
          activeColor: const Color(0xFF0288D1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onTap: () {
          _toggleCategory(categoryName, !isSelected);
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Chọn hạng mục chi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE3F2FD),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCategories,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên hạng mục',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Category count and select all
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getTotalCategoryCount()} hạng mục',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: _selectAll,
                  child: Row(
                    children: [
                      const Text(
                        'Chọn tất cả',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0288D1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isAllSelected()
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: _selectedCategories.isEmpty
                            ? Colors.grey[400]
                            : const Color(0xFF0288D1),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Categories list
          Expanded(
            child: _filteredCategories.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy hạng mục',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _getDisplayItemCount(),
                    itemBuilder: (context, index) {
                      return _buildCategoryItem(index);
                    },
                  ),
          ),
        ],
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
            onPressed: () {
              // Xây dựng danh sách hiển thị
              final displayList = <String>[];

              // Kiểm tra từng hạng mục cha
              for (var parent in _filteredCategories.where(
                (cat) => cat.parent_id == null,
              )) {
                final parentName = parent.name ?? '';
                final parentId = parent.id ?? 0;

                // Lấy danh sách hạng mục con của cha này
                final children = _getChildCategories(parentId);
                final childNames = children.map((c) => c.name ?? '').toSet();

                // Kiểm tra xem tất cả con có được chọn không
                final allChildrenSelected =
                    childNames.isNotEmpty &&
                    childNames.every(
                      (name) => _selectedCategories.contains(name),
                    );

                if (_selectedCategories.contains(parentName)) {
                  // Nếu chọn cha, kiểm tra xem tất cả con có chọn không
                  if (allChildrenSelected && childNames.isNotEmpty) {
                    // Chỉ hiển thị tên cha nếu tất cả con được chọn
                    displayList.add(parentName);
                  } else {
                    // Hiển thị tên cha
                    displayList.add(parentName);
                  }
                } else {
                  // Nếu không chọn cha, kiểm tra xem có chọn con nào không
                  for (var child in children) {
                    final childName = child.name ?? '';
                    if (_selectedCategories.contains(childName)) {
                      displayList.add(childName);
                    }
                  }

                  // Nếu chọn tất cả con mà không chọn cha, thì hiển thị tên cha
                  if (allChildrenSelected && childNames.isNotEmpty) {
                    displayList.clear();
                    displayList.add(parentName);
                  }
                }
              }

              Navigator.pop(
                context,
                displayList.isNotEmpty ? displayList : ['Tất cả hạng mục chi'],
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0288D1),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Xác nhận',
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
}
