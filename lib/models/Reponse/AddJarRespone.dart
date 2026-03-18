class AddJarRespone {
  final String? id;           // Thêm ID (UUID) để biết hũ nào vừa được tạo
  final String user_id;       // int -> String (UUID từ Supabase Auth)
  final String nameJar;
  final String name;          // Đây thường là JarType.name (String)
  final double balance;
  final String description;
  final int is_deleted;
  final DateTime created_at;

  AddJarRespone({
    this.id,
    required this.user_id,
    required this.nameJar,
    required this.name,
    required this.balance,
    this.description = '',
    this.is_deleted = 0,
    required this.created_at,
  });


}