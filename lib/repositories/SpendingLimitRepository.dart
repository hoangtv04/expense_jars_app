import '../db/app_database.dart';
import '../models/SpendingLimit.dart';

class SpendingLimitRepository {
  Future<int> insertSpendingLimit(SpendingLimit limit) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('spending_limits', limit.toMap());
  }

  Future<int> updateSpendingLimit(SpendingLimit limit) async {
    final db = await AppDatabase.instance.database;
    return await db.update(
      'spending_limits',
      limit.toMap(),
      where: 'id = ?',
      whereArgs: [limit.id],
    );
  }

  Future<int> deleteSpendingLimit(int id) async {
    final db = await AppDatabase.instance.database;
    return await db.update(
      'spending_limits',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<SpendingLimit>> getSpendingLimitsByUserId(int userId) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'spending_limits',
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps.map((e) => SpendingLimit.fromMap(e)).toList();
  }

  Future<SpendingLimit?> getSpendingLimitById(int id) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      'spending_limits',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return SpendingLimit.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> isNameExists({
    required int userId,
    required String name,
    int? excludeId,
  }) async {
    final db = await AppDatabase.instance.database;
    final trimmedName = name.trim().toLowerCase();

    String where = 'LOWER(TRIM(name)) = ? AND user_id = ? AND is_deleted = 0';
    List<Object?> whereArgs = [trimmedName, userId];

    if (excludeId != null) {
      where += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final maps = await db.query(
      'spending_limits',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  List<String> _parseSelectionNames(String rawValue) {
    if (rawValue.trim().isEmpty) return [];
    if (rawValue.contains('Tất cả')) return [];

    return rawValue
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<double> getSpentAmountForLimit({
    required int userId,
    required SpendingLimit limit,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final db = await AppDatabase.instance.database;
    final categoryNames = _parseSelectionNames(limit.categories);
    final accountNames = _parseSelectionNames(limit.accounts);

    final whereParts = <String>[
      't.user_id = ?',
      '(t.is_deleted = 0 OR t.is_deleted IS NULL)',
      "c.type = 'expense'",
      'date(t.date) >= date(?)',
      'date(t.date) <= date(?)',
    ];

    final whereArgs = <Object?>[
      userId,
      fromDate.toIso8601String().split('T').first,
      toDate.toIso8601String().split('T').first,
    ];

    if (categoryNames.isNotEmpty) {
      final placeholders = List.filled(categoryNames.length, '?').join(', ');
      whereParts.add('c.name IN ($placeholders)');
      whereArgs.addAll(categoryNames);
    }

    if (accountNames.isNotEmpty) {
      final placeholders = List.filled(accountNames.length, '?').join(', ');
      whereParts.add('j.nameJar IN ($placeholders)');
      whereArgs.addAll(accountNames);
    }

    final query =
        '''
      SELECT COALESCE(SUM(t.amount), 0) AS total_spent
      FROM transactions t
      JOIN categories c ON c.id = t.category_id
      JOIN jars j ON j.id = t.jar_id
      WHERE ${whereParts.join(' AND ')}
    ''';

    final result = await db.rawQuery(query, whereArgs);
    final total = result.first['total_spent'];
    return total == null ? 0.0 : (total as num).toDouble();
  }
}
