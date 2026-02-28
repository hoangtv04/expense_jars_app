import 'package:flutter/material.dart';
import '../../../controllers/CategoryController.dart';
import '../../../models/Category.dart';
import 'SelectParentCategoryPage.dart';
import 'SelectCategoryIconPage.dart';

class AddCategoryPage extends StatefulWidget {
  final CategoryType categoryType;

  const AddCategoryPage({
    super.key,
    required this.categoryType,
  });

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController _nameController = TextEditingController();
  Category? _selectedParentCategory;
  int? _selectedIconId;
  final CategoryController _controller = CategoryController();
  List<Category> _parentCategories = [];
  bool _isLoadingParents = false;

  @override
  void initState() {
    super.initState();
    _loadParentCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadParentCategories() async {
    setState(() => _isLoadingParents = true);
    
    final parents = await _controller.getCategoriesByType(widget.categoryType);
    
    setState(() {
      _parentCategories = parents;
      _isLoadingParents = false;
    });
  }

  void _showParentCategorySelector() async {
    final result = await Navigator.push<Category?>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectParentCategoryPage(
          parentCategories: _parentCategories,
          currentSelectedParent: _selectedParentCategory,
        ),
      ),
    );

    if (result != null || result == null) {
      setState(() {
        _selectedParentCategory = result;
      });
    }
  }

  void _showIconSelector() async {
    final result = await Navigator.push<int?>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectCategoryIconPage(
          selectedIconId: _selectedIconId,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedIconId = result;
      });
    }
  }

  Future<void> _saveCategory() async {
    final newName = _nameController.text.trim();
    
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên hạng mục')),
      );
      return;
    }

    await _controller.addCategory(
      name: newName,
      type: widget.categoryType,
      parentId: _selectedParentCategory?.id,
      iconId: _selectedIconId,
    );

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm hạng mục mới')),
      );
    }
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
        title: Text(
          widget.categoryType == CategoryType.expense 
              ? 'Thêm hạng mục chi' 
              : 'Thêm hạng mục thu',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and Name input row
                  Row(
                    children: [
                      // Icon selection button
                      GestureDetector(
                        onTap: _showIconSelector,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _selectedIconId != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'lib/assets/category_icon/$_selectedIconId.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.category);
                                    },
                                  ),
                                )
                              : const Icon(Icons.add_a_photo),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name input
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Tên hạng mục',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Parent category selection
                  const Text(
                    'Chọn hạng mục cha',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showParentCategorySelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedParentCategory?.name ?? 'Chọn hạng mục cha',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedParentCategory == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
          ),
        ],
      ),
    );
  }
}
