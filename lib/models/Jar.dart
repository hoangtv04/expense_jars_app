enum JarType {
  bank('Ngân hàng'),
  cash('Tiền mặt'),
  other('Khác');

  final String label;
  const JarType(this.label);
}

class Jar {
  final String? id;         // String UUID
  final String user_id;     // 🔥 Đã đổi int -> String (để khớp với "aaa")
  final String nameJar;
  final JarType name;
  final double balance;
  final String description;
  final int is_deleted;
  final DateTime created_at;
  final int is_synced;

  Jar({
    this.id,
    required this.user_id, // 🔥 String
    required this.nameJar,
    required this.name,
    required this.balance,
    this.description = '',
    this.is_deleted = 0,
    required this.created_at,
    this.is_synced = 0,
  });

  factory Jar.fromMap(Map<String, dynamic> map) {
    return Jar(
      id: map['id']?.toString(), // Đảm bảo lấy ra String
      user_id: map['user_id'].toString(), // 🔥 Ép kiểu về String
      nameJar: map['nameJar'] ?? '',
      name: JarType.values.firstWhere(
            (e) => e.name == map['name'],
        orElse: () => JarType.cash,
      ),
      balance: (map['balance'] as num).toDouble(),
      description: map['description'] ?? '',
      is_deleted: map['is_deleted'] ?? 0,
      is_synced: map['is_synced'] ?? 0,
      created_at: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, // String UUID
      'user_id': user_id, // "aaa"
      'nameJar': nameJar,
      'name': name.name, // enum → string
      'balance': balance,
      'description': description,
      'is_deleted': is_deleted,
      'is_synced': is_synced,
      'created_at': created_at.toIso8601String(), // DateTime → string
    };
  }

  // Thêm copyWith để tiện cho việc cập nhật số dư hũ sau này
  Jar copyWith({
    String? id,
    String? user_id,
    String? nameJar,
    JarType? name,
    double? balance,
    String? description,
    int? is_deleted,
    int? isSynced,
    DateTime? created_at,

  }) {
    return Jar(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      nameJar: nameJar ?? this.nameJar,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      description: description ?? this.description,
      is_deleted: is_deleted ?? this.is_deleted,
      is_synced: isSynced ?? this.is_synced,
      created_at: created_at ?? this.created_at,
    );
  }
}