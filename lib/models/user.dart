class User {
  final String id; // int -> String (UUID từ Supabase Auth)
  final String email;
  final String password;

  User({required this.id, required this.email, required this.password});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(), // Đảm bảo lấy ra dạng String UUID
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, // String UUID
      'email': email,
      'password': password
    };
  }
}