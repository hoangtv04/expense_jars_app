class Product {
  final int? id;
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
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: map['date'],
    );
  }

  // object -> map (lưu DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
    };
  }
}
