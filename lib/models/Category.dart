class Category {
  final int? id;
  final int user_id;
  final int? parent_id;
  final String name;
  final CategoryType type;
  final double? limit_amount;
  final String? description;
  final int is_deleted;
  final DateTime created_at;

  Category({
    this.id,
    required this.user_id,
    this.parent_id,
    required this.name,
    required this.type,
    this.limit_amount,
    this.description,
    this.is_deleted = 0,
    required this.created_at,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      user_id: map['user_id'],
      parent_id: map['parent_id'],
      name: map['name'],
      type: CategoryType.values.firstWhere(
        (e) => e.name == map['type'],
      ),
      limit_amount: map['limit_amount'],
      description: map['description'],
      is_deleted: map['is_deleted'] ?? 0,
      created_at: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': user_id,
      'parent_id': parent_id,
      'name': name,
      'type': type.name, // enum → string
      'limit_amount': limit_amount,
      'description': description,
      'is_deleted': is_deleted,
      'created_at': created_at.toIso8601String(), // DateTime → string
    };
  }
}

enum CategoryType {
  income('Thu nhập'),
  expense('Chi tiêu');

  final String displayName;
  const CategoryType(this.displayName);
}
