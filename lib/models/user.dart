class User {
  final String id;
  final String email;
  final String password;
  final String? fullName;
  final String? phone;
  final String? birth;
  final String? gender;
  final int isSynced; // 0: Chưa sync, 1: Đã sync

  User({
    required this.id,
    required this.email,
    required this.password,
    this.fullName,
    this.phone,
    this.birth,
    this.gender,
    this.isSynced = 0, // Mặc định là 0
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(),
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      fullName: map['full_name'],
      phone: map['phone'],
      birth: map['birth'],
      gender: map['gender'],
      isSynced: map['is_synced'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone': phone,
      'birth': birth,
      'gender': gender,
      'is_synced': isSynced,
    };
  }
}