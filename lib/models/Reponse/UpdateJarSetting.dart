class UpdateJarSetting {
  final String id; // int -> String (UUID của hũ cần cập nhật)
  final String nameJar;
  final String name; // Thường là JarType.name
  final double balance;
  final String description;

  UpdateJarSetting({
    required this.id,
    required this.nameJar,
    required this.name,
    required this.balance,
    this.description = '',
  });

  // Có thể thêm toMap để dùng khi gọi hàm update trong DatabaseHelper
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameJar': nameJar,
      'name': name,
      'balance': balance,
      'description': description,
    };
  }
}