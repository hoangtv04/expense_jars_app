import '../models/Category.dart';
import '../repositories/CategoryRepository.dart';

class CategoryController {
  final CategoryRepository _repo = CategoryRepository();

  Future<void> addCategory({
    required String name,
    required CategoryType type,
    int? parentId,
    double? limitAmount,
    String? description,
  }) async {
    final category = Category(
      user_id: 1, // TODO: Get from logged user
      parent_id: parentId,
      name: name,
      type: type,
      limit_amount: limitAmount,
      description: description,
      created_at: DateTime.now(),
    );

    await _repo.insertCategory(category);
  }

  Future<void> deleteCategory(int id) async {
    await _repo.deleteCategory(id);
  }

  Future<void> updateCategory(Category category) async {
    await _repo.updateCategory(category);
  }

  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    return await _repo.getAllByType(type);
  }

  Future<List<Category>> getSubcategories(int parentId) async {
    return await _repo.getSubcategories(parentId);
  }

  Future<List<Category>> getAllCategories() async {
    return await _repo.getAll();
  }

  Future<Category?> getCategoryById(int id) async {
    return await _repo.getCategoryById(id);
  }

  CategoryType categoryTypeFromString(String value) {
    return CategoryType.values.firstWhere(
      (e) => e.name == value,
    );
  }
}
