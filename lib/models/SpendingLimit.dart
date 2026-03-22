class SpendingLimit {
  final String? id;
  final String user_id;
  final String name;
  final double amount;
  final String categories;
  final String accounts;
  final String repeat_frequency;
  final String start_date;
  final String? end_date;
  final int carry_forward;
  final int is_deleted;
  final int is_synced;       // THÊM: 0 = chưa sync, 1 = đã sync
  final DateTime created_at;

  SpendingLimit({
    this.id,
    required this.user_id,
    required this.name,
    required this.amount,
    required this.categories,
    required this.accounts,
    required this.repeat_frequency,
    required this.start_date,
    this.end_date,
    this.carry_forward = 0,
    this.is_deleted = 0,
    this.is_synced = 0,      // Mặc định là 0
    required this.created_at,
  });

  factory SpendingLimit.fromMap(Map<String, dynamic> map) {
    return SpendingLimit(
      id: map['id']?.toString(),
      user_id: map['user_id'].toString(),
      name: map['name'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      categories: map['categories'] ?? '[]',
      accounts: map['accounts'] ?? '[]',
      repeat_frequency: map['repeat_frequency'] ?? 'Hàng tháng',
      start_date: map['start_date'] ?? '',
      end_date: map['end_date'],
      carry_forward: map['carry_forward'] ?? 0,
      is_deleted: map['is_deleted'] ?? 0,
      is_synced: map['is_synced'] ?? 0, // Lấy từ DB
      created_at: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': user_id,
      'name': name,
      'amount': amount,
      'categories': categories,
      'accounts': accounts,
      'repeat_frequency': repeat_frequency,
      'start_date': start_date,
      'end_date': end_date,
      'carry_forward': carry_forward,
      'is_deleted': is_deleted,
      'is_synced': is_synced,    // Lưu vào SQLite
      'created_at': created_at.toIso8601String(),
    };
  }

  // Hàm copyWith để cập nhật sau khi sync
  SpendingLimit copyWith({
    String? id,
    int? isSynced,
    int? isDeleted,
    double? amount,
  }) {
    return SpendingLimit(
      id: id ?? this.id,
      user_id: user_id,
      name: name,
      amount: amount ?? this.amount,
      categories: categories,
      accounts: accounts,
      repeat_frequency: repeat_frequency,
      start_date: start_date,
      end_date: end_date,
      carry_forward: carry_forward,
      is_deleted: isDeleted ?? this.is_deleted,
      is_synced: isSynced ?? this.is_synced,
      created_at: created_at,
    );
  }
}