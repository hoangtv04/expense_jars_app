class Product {
  final String? id;          // UUID String
  final String title;
  final double amount;
  final String category;
  final String date;
  final int is_synced;       // 0: chưa đồng bộ, 1: đã đồng bộ
  final int is_deleted;      // 0: bình thường, 1: đã xóa

  Product({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.is_synced = 0,      // Mặc định 0 khi tạo mới tại local
    this.is_deleted = 0,
  });

  // map -> object (từ SQLite hoặc Supabase)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString(),
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      date: map['date'] ?? '',
      is_synced: map['is_synced'] ?? 0,
      is_deleted: map['is_deleted'] ?? 0,
    );
  }

  // object -> map (để lưu vào SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
      'is_synced': is_synced,
      'is_deleted': is_deleted,
    };
  }

  // Hàm copyWith để cập nhật trạng thái sau khi Sync thành công
  Product copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    String? date,
    int? isSynced,
    int? isDeleted,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      is_synced: isSynced ?? this.is_synced,
      is_deleted: isDeleted ?? this.is_deleted,
    );
  }
}