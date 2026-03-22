import '../db/app_database.dart';
import '../models/Category.dart';
import '../models/Reponse/TransactionWithCategory.dart';
import '../models/Reponse/TransactionjoinCategory.dart';

class CategoryRepository {

  Future<int> insertCategory(Category category) async {
    final db = await AppDatabase.instance.database;
    return await db.insert("categories", category.toMap());
  }

  Future<int> deleteCategory(String id) async {
    final db = await AppDatabase.instance.database;
    return await db.update(
      'categories',
      // 🔥 Thêm is_synced = 0 để đánh dấu cần đồng bộ việc xóa này
      {'is_deleted': 1, 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateCategory(Category category) async {
    final db = await AppDatabase.instance.database;
    final updateMap = category.toMap();
    // Giữ created_at không thay đổi, chỉ cập nhật các trường khác
    updateMap.remove('created_at');
    // 🔥 Thêm is_synced = 0 để đánh dấu dữ liệu đã thay đổi, cần sync lại
    updateMap['is_synced'] = 0;

    return await db.update(
      'categories',
      updateMap,
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<List<Category>> getAllByType(CategoryType type) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'categories',
      where: 'type = ? AND is_deleted = 0 AND parent_id IS NULL',
      whereArgs: [type.name],
      orderBy: 'created_at ASC',
    );

    return maps.map((e) => Category.fromMap(e)).toList();
  }

  Future<List<Category>> getSubcategories(String parentId) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'categories',
      where: 'parent_id = ? AND is_deleted = 0',
      whereArgs: [parentId],
      orderBy: 'created_at ASC',
    );

    return maps.map((e) => Category.fromMap(e)).toList();
  }

  Future<List<Category>> getAll() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'categories',
      where: 'is_deleted = 0',
      orderBy: 'created_at DESC',
    );


    return maps.map((e) => Category.fromMap(e)).toList();
  }

  Future<List<TransactionWithCategory>> getType(int id) async {
    final db = await AppDatabase.instance.database;

    final result = await db.rawQuery('''
    SELECT t.*, c.name as category_name, c.type
    FROM transactions t
    JOIN categories c ON t.category_id = c.id
    WHERE t.is_deleted = 0
    ORDER BY t.created_at DESC
  ''');

    return result
        .map((e) => TransactionWithCategory.fromMap(e))
        .toList();
  }
  Future<List<TransactionWithCategory>> getTransactionWithCategory(String id) async {
    final db = await AppDatabase.instance.database;

    final result = await db.rawQuery('''
    SELECT 
      t.*, 
      c.name as category_name, 
      c.type
    FROM transactions t
    INNER JOIN categories c ON t.category_id = c.id
    WHERE t.is_deleted = 0
      AND t.jar_id = ?
    ORDER BY t.created_at DESC
  ''', [id]);

    return result
        .map((e) => TransactionWithCategory.fromMap(e))
        .toList();
  }
  Future<Category?> getCategoryById(String id) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'categories',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  /// Transfer all transactions from one category to another.
  /// Returns the number of rows updated.
  Future<int> transferTransactions(String fromCategoryId, String toCategoryId) async {
    final db = await AppDatabase.instance.database;

    // 1. Lấy thông tin của Category mới để biết 'type' (Thu/Chi) của nó là gì
    final List<Map<String, dynamic>> toCategoryMap = await db.query(
      'categories',
      columns: ['type'],
      where: 'id = ?',
      whereArgs: [toCategoryId],
      limit: 1,
    );

    if (toCategoryMap.isEmpty) {
      print(" Không tìm thấy Category đích để lấy Type");
      return 0;
    }

    final String newType = toCategoryMap.first['type'];

    // 2. Thực hiện update đồng loạt: Đổi ID danh mục, đổi loại (Type) và đánh dấu chưa Sync
    return await db.rawUpdate('''
    UPDATE transactions 
    SET category_id = ?, 
        type = ?, 
        is_synced = 0 
    WHERE category_id = ?
  ''', [toCategoryId, newType, fromCategoryId]);
  }
}