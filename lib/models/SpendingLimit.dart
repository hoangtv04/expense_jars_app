class SpendingLimit {
  final String? id;          // int? -> String?
  final String user_id;      // int -> String (UUID từ Supabase Auth)
  final String name;
  final double amount;
  final String categories;   // JSON string (Chứa danh sách UUID của Categories)
  final String accounts;     // JSON string (Chứa danh sách UUID của Jars)
  final String repeat_frequency;
  final String start_date;
  final String? end_date;
  final int carry_forward;
  final int is_deleted;
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
    required this.created_at,
  });

  factory SpendingLimit.fromMap(Map<String, dynamic> map) {
    return SpendingLimit(
      id: map['id']?.toString(), // Đảm bảo lấy ra String UUID
      user_id: map['user_id'].toString(),
      name: map['name'] ?? '',
      amount: (map['amount'] as num).toDouble(), // Ép kiểu double an toàn
      categories: map['categories'] ?? '[]',
      accounts: map['accounts'] ?? '[]',
      repeat_frequency: map['repeat_frequency'] ?? 'Hàng tháng',
      start_date: map['start_date'] ?? '',
      end_date: map['end_date'],
      carry_forward: map['carry_forward'] ?? 0,
      is_deleted: map['is_deleted'] ?? 0,
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
      'created_at': created_at.toIso8601String(),
    };
  }
}