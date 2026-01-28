class Users {
  final int? id;
  final String email;
  final String password;

  Users({this.id, required this.email, required this.password});

  factory Users.fromMap(Map<String, dynamic> json) =>
      Users(id: json["id"], email: json["email"], password: json["password"]);

  Map<String, dynamic> toMap() => {
    "id": id,
    "email": email,
    "password": password,
  };
}
