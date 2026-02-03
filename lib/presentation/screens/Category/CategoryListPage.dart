import 'package:flutter/material.dart';
import '../../../controllers/CategoryController.dart';
import '../../../models/Category.dart';
import 'EditCategoryPage.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

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
          final matchesName = cat.name.toLowerCase().contains(_searchQuery.toLowerCase());
          final hasMatchingSubcategory = _subcategoriesMap[cat.id]?.any(
            (subcat) => subcat.name.toLowerCase().contains(_searchQuery.toLowerCase())
          ) ?? false;
          return matchesName || hasMatchingSubcategory;
        }).toList();
        
        _filteredIncomeCategories = _incomeCategories.where((cat) {
          final matchesName = cat.name.toLowerCase().contains(_searchQuery.toLowerCase());
          final hasMatchingSubcategory = _subcategoriesMap[cat.id]?.any(
            (subcat) => subcat.name.toLowerCase().contains(_searchQuery.toLowerCase())
          ) ?? false;
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
        title: const Text(
          'Chọn hạng mục',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã chọn: ${subcategory.name}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            subcategory.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.2,
            ),
          ),
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

  Widget _buildCategoryItem(Category category, bool hasSubcategories, bool isExpanded) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: hasSubcategories
            ? Icon(
                isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                size: 24,
                color: Colors.grey[600],
              )
            : const SizedBox(width: 24),
        title: Text(
          category.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: hasSubcategories
            ? () => _toggleCategory(category.id!)
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã chọn: ${category.name}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
      ),
    );
  }
}
