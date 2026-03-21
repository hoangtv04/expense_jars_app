class Member {
  final String? id; // UUID String
  final String name;
  final String role;
  final String created_at;
  final int is_synced;  // 0: chưa đồng bộ, 1: đã đồng bộ
  final int is_deleted; // 0: hoạt động, 1: đã xóa

  Member({
    this.id,
    required this.name,
    required this.role,
    required this.created_at,
    this.is_synced = 0,  // Mặc định là 0 khi tạo mới tại local
    this.is_deleted = 0,
  });

  // map -> object (từ SQLite hoặc Supabase)
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id']?.toString(),
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      created_at: map['created_at'] ?? '',
      is_synced: map['is_synced'] ?? 0,
      is_deleted: map['is_deleted'] ?? 0,
    );
  }

  // object -> map (lưu SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'created_at': created_at,
      'is_synced': is_synced,
      'is_deleted': is_deleted,
    };
  }

  // Hàm copyWith để cập nhật trạng thái sync hoặc thông tin member
  Member copyWith({
    String? id,
    String? name,
    String? role,
    String? created_at,
    int? isSynced,
    int? isDeleted,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      created_at: created_at ?? this.created_at,
      is_synced: isSynced ?? this.is_synced,
      is_deleted: isDeleted ?? this.is_deleted,
    );
  }
}