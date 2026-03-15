import 'package:flutter/material.dart';
import '../../../controllers/CategoryController.dart';
import '../../../models/Category.dart';
import 'EditCategoryPage.dart';
import 'TransferCategoryPage.dart';

class CategoryListPage extends StatefulWidget {
  final bool isSelectionMode; // Thêm tham số để biết có phải chế độ chọn không
  final String? customTitle; // optional custom title

  const CategoryListPage({super.key, this.isSelectionMode = false, this.customTitle});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CategoryController _controller = CategoryController();
  final TextEditingController _searchController = TextEditingController();

  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];

  List<Category> _filteredExpenseCategories = [];
  List<Category> _filteredIncomeCategories = [];

  Map<int, List<Category>> _subcategoriesMap = {};
  Set<int> _expandedCategories = {};

  bool _isLoading = true;
  String _searchQuery = '';

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
    final iconId = category.icon_id ?? _fallbackIconIdByName(category.name);
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    final expense = await _controller.getCategoriesByType(CategoryType.expense);
    final income = await _controller.getCategoriesByType(CategoryType.income);

    // Load subcategories for all parent categories
    Map<int, List<Category>> subcatsMap = {};
    for (var cat in [...expense, ...income]) {
      if (cat.id != null) {
        final subcats = await _controller.getSubcategories(cat.id!);
        if (subcats.isNotEmpty) {
          subcatsMap[cat.id!] = subcats;
        }
      }
    }

    setState(() {
      _expenseCategories = expense;
      _incomeCategories = income;
      _subcategoriesMap = subcatsMap;
      _isLoading = false;
    });

    _filterCategories();
  }

  void _filterCategories() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredExpenseCategories = _expenseCategories;
        _filteredIncomeCategories = _incomeCategories;
      } else {
        _filteredExpenseCategories = _expenseCategories.where((cat) {
          final matchesName = cat.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          final hasMatchingSubcategory =
              _subcategoriesMap[cat.id]?.any(
                (subcat) => subcat.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              ) ??
              false;
          return matchesName || hasMatchingSubcategory;
        }).toList();

        _filteredIncomeCategories = _incomeCategories.where((cat) {
          final matchesName = cat.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          final hasMatchingSubcategory =
              _subcategoriesMap[cat.id]?.any(
                (subcat) => subcat.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              ) ??
              false;
          return matchesName || hasMatchingSubcategory;
        }).toList();
      }
    });
  }

  void _toggleCategory(int categoryId) {
    setState(() {
      if (_expandedCategories.contains(categoryId)) {
        _expandedCategories.remove(categoryId);
      } else {
        _expandedCategories.add(categoryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.customTitle ?? (widget.isSelectionMode ? 'Chọn hạng mục' : 'Quản lý hạng mục'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
            if (widget.customTitle == 'Hạng mục thu/chi')
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                tooltip: 'Chuyển hạng mục',
                onPressed: () async {
                  // Open transfer page for expense categories
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TransferCategoryPage(type: CategoryType.expense)),
                  );
                  if (result == true) {
                    // reload categories after transfer
                    _loadCategories();
                  }
                },
              ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditCategoryPage(),
                  ),
                ).then((_) => _loadCategories());
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.black,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Chi tiêu'),
            Tab(text: 'Thu tiền'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hạng mục',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterCategories();
              },
            ),
          ),
          // Tab content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCategoryList(_filteredExpenseCategories),
                      _buildCategoryList(_filteredIncomeCategories),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Chưa có hạng mục nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final hasSubcategories = _subcategoriesMap.containsKey(category.id);
        final isExpanded = _expandedCategories.contains(category.id);

        return Column(
          children: [
            _buildCategoryItem(category, hasSubcategories, isExpanded),
            if (hasSubcategories && isExpanded)
              _buildSubcategoriesGrid(category.id!),
          ],
        );
      },
    );
  }

  Widget _buildSubcategoriesGrid(int parentId) {
    final subcategories = _subcategoriesMap[parentId] ?? [];

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          final subcat = subcategories[index];
          return _buildSubcategoryItem(subcat);
        },
      ),
    );
  }

  Widget _buildSubcategoryItem(Category subcategory) {
    return GestureDetector(
      onTap: () {
        if (widget.isSelectionMode) {
          // Nếu ở chế độ chọn, trả về category đã chọn
          Navigator.pop(context, subcategory);
        } else {
          // Nếu không, hiển thị snackbar như cũ
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã chọn: ${subcategory.name}'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryIcon(subcategory, size: 32),
            const SizedBox(height: 4),
            Text(
              subcategory.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmojiForCategory(String name) {
    final emojiMap = {
      'Ăn vặt': '🍿',
      'Ăn tối': '🍖',
      'Ăn trưa': '🥗',
      'Ăn sáng': '🍩',
      'Cafe': '☕',
      'Ăn tiệm': '🍜',
      'Đi chợ/siêu thị': '🛍️',
      'Thuê người giúp việc': '🧹',
      'Điện thoại cố định': '☎️',
      'Truyền hình': '📺',
      'Gas': '🔥',
      'Điện thoại di động': '📱',
      'Internet': '📡',
      'Nước': '💧',
      'Điện': '💡',
      'Taxi/thuê xe': '🚗',
      'Rửa xe': '🚿',
      'Gửi xe': '🅿️',
      'Sửa chữa, bảo dưỡng xe': '🔧',
    };
    return emojiMap[name] ?? '📁';
  }

  Widget _buildCategoryItem(
    Category category,
    bool hasSubcategories,
    bool isExpanded,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasSubcategories)
              IconButton(
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 24,
                  color: Colors.grey[600],
                ),
                onPressed: () => _toggleCategory(category.id!),
              )
            else
              const SizedBox(width: 24),
            const SizedBox(width: 8),
            _buildCategoryIcon(category, size: 40),
          ],
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        onTap: () {
          if (widget.isSelectionMode) {
            // Ở chế độ chọn: chọn hạng mục (cha hoặc không có con)
            Navigator.pop(context, category);
          } else {
            // Không ở chế độ chọn: hiển thị snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã chọn: ${category.name}'),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
      ),
    );
  }
}
