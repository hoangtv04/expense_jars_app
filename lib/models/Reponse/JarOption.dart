class JarOption {
  final int id;
  final String name;

  JarOption({
     required this.id,
     required this.name,
  });

  factory JarOption.fromMap(Map<String, dynamic> map) {
    return JarOption(
      id: map['id'],
      name: map['name'],
    );
  }

  static get values => null;
}
