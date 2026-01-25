class Member {
  final int? id;
  final String name;
  final String role;
  final String created_at;
  // bảng family đề phòng trường hợp gia đình tách riêng ra


  Member({
    this.id,
    required this.name,
    required this.role,
    required this.created_at,
  });

  // map -> object (từ DB)
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      created_at: map['created_at'],
    );
  }

  // object -> map (lưu DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'created_at': created_at,
    };
  }
}
