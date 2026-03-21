class Category {
  final String? id;
  final int? icon_id;
  final String user_id;
  final String? parent_id;
  final String name;
  final CategoryType type;
  final double? limit_amount;
  final String? description;
  final int is_deleted;
  final int is_synced;       // THÊM: 0 = chưa đồng bộ, 1 = đã đồng bộ
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
    this.is_synced = 0,      // Mặc định là 0 khi khởi tạo mới
    required this.created_at,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toString(),
      icon_id: map['icon_id'],
      user_id: map['user_id'].toString(),
      parent_id: map['parent_id']?.toString(),
      name: map['name'] ?? '',
      type: CategoryType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => CategoryType.expense,
      ),
      limit_amount: (map['limit_amount'] as num?)?.toDouble(),
      description: map['description'],
      is_deleted: map['is_deleted'] ?? 0,
      is_synced: map['is_synced'] ?? 0, // THÊM: Lấy dữ liệu từ DB
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
      'is_synced': is_synced,    // THÊM: Để lưu trạng thái vào SQLite
      'created_at': created_at.toIso8601String(),
    };
  }

  // Hàm tiện ích để tạo bản sao với trạng thái sync mới
  Category copyWith({int? isSynced, int? isDeleted}) {
    return Category(
      id: id,
      icon_id: icon_id,
      user_id: user_id,
      parent_id: parent_id,
      name: name,
      type: type,
      limit_amount: limit_amount,
      description: description,
      is_deleted: isDeleted ?? is_deleted,
      is_synced: isSynced ?? is_synced,
      created_at: created_at,
    );
  }
}

enum CategoryType {
  income('Thu nhập'),
  expense('Chi tiêu');

  final String displayName;
  const CategoryType(this.displayName);
}