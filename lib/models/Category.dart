class Category {
  final String? id;          // int? -> String?
  final int? icon_id;        // Giữ nguyên int vì đây là ID icon nội bộ
  final String user_id;      // int -> String (UUID từ Supabase Auth)
  final String? parent_id;   // int? -> String? (UUID của category cha)
  final String name;
  final CategoryType type;
  final double? limit_amount;
  final String? description;
  final int is_deleted;
  final DateTime created_at;

  Category({
    this.id,
    this.icon_id,
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
      id: map['id']?.toString(), // Đảm bảo lấy ra String
      icon_id: map['icon_id'],
      user_id: map['user_id'].toString(),
      parent_id: map['parent_id']?.toString(),
      name: map['name'],
      type: CategoryType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => CategoryType.expense, // Thêm orElse để tránh lỗi crash
      ),
      limit_amount: (map['limit_amount'] as num?)?.toDouble(),
      description: map['description'],
      is_deleted: map['is_deleted'] ?? 0,
      created_at: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'icon_id': icon_id,
      'user_id': user_id,
      'parent_id': parent_id,
      'name': name,
      'type': type.name,
      'limit_amount': limit_amount,
      'description': description,
      'is_deleted': is_deleted,
      'created_at': created_at.toIso8601String(),
    };
  }
}

enum CategoryType {
  income('Thu nhập'),
  expense('Chi tiêu');

  final String displayName;
  const CategoryType(this.displayName);
}