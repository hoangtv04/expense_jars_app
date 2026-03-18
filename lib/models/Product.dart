class Product {
  final String? id; // int? -> String? (Lưu UUID dạng chuỗi)
  final String title;
  final double amount;
  final String category;
  final String date;

  Product({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  // map -> object (từ DB)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString(), // Đảm bảo lấy ra String UUID
      title: map['title'] ?? '',
      amount: (map['amount'] as num).toDouble(), // Ép kiểu an toàn cho double
      category: map['category'] ?? '',
      date: map['date'] ?? '',
    );
  }

  // object -> map (lưu DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id, // String UUID
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
    };
  }
}