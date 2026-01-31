class Jar {
  final int? id;
  final int user_id;
  final JarType name;
  final double balance;
  final String description;
  final int is_deleted;
  final DateTime created_at;

  Jar({
    this.id,
    required this.user_id,
    required this.name,
    required this.balance,
    this.description = '',
    this.is_deleted = 0,
    required this.created_at,
  });

  factory Jar.fromMap(Map<String, dynamic> map) {
    return Jar(
      id: map['id'],
      user_id: map['user_id'],
      name: JarType.values.firstWhere(
            (e) => e.name == map['name'],
      ),
      balance: map['balance'],
      description: map['description'] ?? '',
      is_deleted: map['is_deleted'],
      created_at: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': user_id,
      'name': name.name, // enum → string
      'balance': balance,
      'description': description,
      'is_deleted': is_deleted,
      'created_at': created_at.toIso8601String(), // DateTime → string
    };
  }
}


enum JarType {
  bank('Ngân hàng'),
  cash('Tiền mặt'),
  other('Khác');

  final String label;
  const JarType(this.label);
}