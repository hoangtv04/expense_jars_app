import 'package:flutter/material.dart';
import '../../../controllers/CategoryController.dart';
import '../../../models/Category.dart';

class SelectCategoryPage extends StatefulWidget {
  final int? selectedCategoryId;

  const SelectCategoryPage({
    super.key,
    this.selectedCategoryId,
  });

  @override
  State<SelectCategoryPage> createState() => _SelectCategoryPageState();
}

class _SelectCategoryPageState extends State<SelectCategoryPage>
    with SingleTickerProviderStateMixin {
  final CategoryController _controller = CategoryController();
  late TabController _tabController;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCategoryId = widget.selectedCategoryId;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn hạng mục'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chi tiêu'),
            Tab(text: 'Thu tiền'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(CategoryType.expense),
          _buildCategoryList(CategoryType.income),
        ],
      ),
    );
  }

  Widget _buildCategoryList(CategoryType type) {
    return FutureBuilder<List<Category>>(
      future: _controller.getCategoriesByType(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final categories = snapshot.data ?? [];
        final parentCategories =
            categories.where((c) => c.parent_id == null).toList();

        if (parentCategories.isEmpty) {
          return const Center(
            child: Text('Chưa có hạng mục nào'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: parentCategories.length,
          itemBuilder: (context, index) {
            final parent = parentCategories[index];
            final subcategories = categories
                .where((c) => c.parent_id == parent.id)
                .toList();

            if (subcategories.isEmpty) {
              // Parent không có con - hiển thị trực tiếp
              return _buildCategoryItem(parent);
            }

            // Parent có con - hiển thị expandable
            return _buildExpandableCategory(parent, subcategories);
          },
        );
      },
    );
  }

  Widget _buildExpandableCategory(
      Category parent, List<Category> subcategories) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          parent.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          _selectedCategoryId == parent.id
              ? Icons.check_circle
              : Icons.arrow_drop_down,
          color: _selectedCategoryId == parent.id ? Colors.blue : null,
        ),
        onExpansionChanged: (expanded) {
          if (!expanded && _selectedCategoryId == parent.id) {
            // Khi thu lại mà đang chọn parent, vẫn giữ selection
          }
        },
        children: [
          // Nút chọn parent
          ListTile(
            title: const Text('Tất cả'),
            trailing: _selectedCategoryId == parent.id
                ? const Icon(Icons.check_circle, color: Colors.blue)
                : null,
            onTap: () {
              Navigator.pop(context, parent);
            },
          ),
          const Divider(height: 1),
          // Grid subcategories
          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                final subcategory = subcategories[index];
                final isSelected = _selectedCategoryId == subcategory.id;

                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, subcategory);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.blue, size: 20),
                        if (isSelected) const SizedBox(height: 4),
                        Text(
                          subcategory.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    final isSelected = _selectedCategoryId == category.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          category.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.blue)
            : null,
        onTap: () {
          Navigator.pop(context, category);
        },
      ),
    );
  }
}
