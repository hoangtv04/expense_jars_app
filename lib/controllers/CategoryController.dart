import 'package:uuid/uuid.dart';

import '../models/Category.dart';
import '../repositories/CategoryRepository.dart';

class CategoryController {
  final CategoryRepository _repo = CategoryRepository();
  final _uuid = const Uuid(); // 🔥 Khởi tạo instance uuid
  Future<void> addCategory({
    required String name,
    required CategoryType type,
    String? parentId, // 🔥 Đổi int? -> String?
    int? iconId,
    double? limitAmount,
    String? description,
  }) async {
    final category = Category(
      id: _uuid.v4(),
      icon_id: iconId,
      user_id: "aaa", // 🔥 Đổi sang "aaa"
      parent_id: parentId, // Bây giờ là String UUID
      name: name,
      type: type,
      limit_amount: limitAmount,
      description: description,
      created_at: DateTime.now(),
    );

    await _repo.insertCategory(category);
  }

  Future<void> deleteCategory(String id) async { // 🔥 Đổi int -> String
    await _repo.deleteCategory(id);
  }

  Future<void> updateCategory(Category category) async {
    await _repo.updateCategory(category);
  }

  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    return await _repo.getAllByType(type);
  }

  Future<List<Category>> getSubcategories(String parentId) async {
    return await _repo.getSubcategories(parentId);
  }

  Future<List<Category>> getAllCategories() async {
    final list = await _repo.getAll();

    // In ra để debug xem ID đã là UUID chưa
    for (var cat in list) {
      print('Category: ${cat.name} | ID: ${cat.id} | Parent: ${cat.parent_id}');
    }

    return list;
  }

  Future<Category?> getCategoryById(String id) async { // 🔥 Đổi int -> String
    return await _repo.getCategoryById(id);
  }

  CategoryType categoryTypeFromString(String value) {
    return CategoryType.values.firstWhere(
          (e) => e.name == value,
    );
  }
}