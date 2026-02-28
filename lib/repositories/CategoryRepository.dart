import '../db/app_database.dart';
import '../models/Category.dart';
import '../models/Reponse/TransactionWithCategory.dart';
import '../models/Reponse/TransactionjoinCategory.dart';

class CategoryRepository {
  
  Future<int> insertCategory(Category category) async {
    final db = await AppDatabase.instance.database;
    return await db.insert("categories", category.toMap());
  }

  Future<int> deleteCategory(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.update(
      'categories',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateCategory(Category category) async {
    final db = await AppDatabase.instance.database;
    return await db.update(
      'categories',
      category.toMap(),
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

  Future<List<Category>> getSubcategories(int parentId) async {
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

  Future<Category?> getCategoryById(int id) async {
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
}
