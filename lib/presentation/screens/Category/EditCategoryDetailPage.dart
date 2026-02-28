import 'package:flutter/material.dart';
import '../../../controllers/CategoryController.dart';
import '../../../models/Category.dart';
import 'SelectParentCategoryPage.dart';
import 'SelectCategoryIconPage.dart';

class EditCategoryDetailPage extends StatefulWidget {
  final Category category;
  final bool isSubcategory;

  const EditCategoryDetailPage({
    super.key,
    required this.category,
    this.isSubcategory = false,
  });

  @override
  State<EditCategoryDetailPage> createState() => _EditCategoryDetailPageState();
}

class _EditCategoryDetailPageState extends State<EditCategoryDetailPage> {
  late TextEditingController _nameController;
  Category? _selectedParentCategory;
  int? _selectedIconId;
  final CategoryController _controller = CategoryController();
  List<Category> _parentCategories = [];
  bool _isLoadingParents = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedIconId = widget.category.icon_id;
    _loadParentCategories();
  }

  String? _selectedIconPath() {
    if (_selectedIconId == null) return null;
    return 'lib/assets/category_icon/${_selectedIconId!}.png';
  }

  Future<void> _showIconSelector() async {
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

  Future<void> _loadParentCategories() async {
    setState(() => _isLoadingParents = true);
    
    final parents = await _controller.getCategoriesByType(widget.category.type);
    
    // If this is editing a subcategory, load the current parent
    if (widget.category.parent_id != null) {
      final currentParent = await _controller.getCategoryById(widget.category.parent_id!);
      _selectedParentCategory = currentParent;
    }
    
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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _deleteCategory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning,
                color: Colors.orange,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Xóa hạng mục',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Nếu bạn xóa hạng mục này, tất cả các ghi chép liên quan bị để trống thông tin hạng mục. Bạn có thực sự muốn xóa không?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Không',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Có',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _controller.deleteCategory(widget.category.id!);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa hạng mục')),
        );
      }
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

    final updatedCategory = Category(
      id: widget.category.id,
      icon_id: _selectedIconId,
      user_id: widget.category.user_id,
      parent_id: _selectedParentCategory?.id,
      name: newName,
      type: widget.category.type,
      limit_amount: widget.category.limit_amount,
      description: widget.category.description,
      is_deleted: widget.category.is_deleted,
      created_at: widget.category.created_at,
    );

    await _controller.updateCategory(updatedCategory);

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu thay đổi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isSubcategory ? 'Sửa hạng mục chi' : 'Sửa hạng mục',
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: _showIconSelector,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _selectedIconPath() == null
                                  ? Icon(
                                      Icons.image_outlined,
                                      color: Colors.blue[300],
                                      size: 30,
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Image.asset(
                                        _selectedIconPath()!,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.blue[300],
                                          size: 30,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _showIconSelector,
                            child: const Text(
                              'Chọn icon',
                              style: TextStyle(
                                color: Colors.lightBlue,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _nameController.clear();
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.cancel,
                                  color: Colors.grey[500],
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Only show parent category selection if this is a subcategory
                  if (widget.category.parent_id != null) ...[
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
                                _selectedParentCategory?.name ?? 'Không chọn',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            if (_selectedParentCategory != null)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedParentCategory = null;
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Bottom buttons
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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _deleteCategory,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
