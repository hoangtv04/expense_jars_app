import 'Category.dart';

class Transaction {
  final String? id;
  final String userId;
  final String jarId;
  final String categoryId; // 🔥 Đã chuyển int -> String (UUID)
  final double amount;
  final String? note;
  final String? date;
  final String? status;
  final int isDeleted;
  final String? createdAt;
  final CategoryType? type;

  Transaction({
    this.id,
    required this.userId,
    required this.jarId,
    required this.categoryId, // 🔥 String
    required this.amount,
    this.note,
    this.date,
    this.status = 'completed',
    this.isDeleted = 0,
    this.createdAt,
    this.type,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id']?.toString(),
      userId: map['user_id'].toString(),
      jarId: map['jar_id'].toString(),
      categoryId: map['category_id'].toString(), // 🔥 Ép kiểu về String
      amount: (map['amount'] as num).toDouble(),
      note: map['note'],
      date: map['date'],
      status: map['status'],
      isDeleted: map['is_deleted'] ?? 0,
      createdAt: map['created_at'],
      type: CategoryType.values.firstWhere(
            (e) => e.name.toLowerCase() == (map['type']?.toString().toLowerCase().trim() ?? ""),
        orElse: () => CategoryType.expense,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'jar_id': jarId,
      'category_id': categoryId, // 🔥 String UUID
      'amount': amount,
      'note': note,
      'date': date,
      'status': status,
      'is_deleted': isDeleted,
      'created_at': createdAt,
    };
  }

  // Hàm copyWith để tiện cập nhật object
  Transaction copyWith({
    String? id,
    String? userId,
    String? jarId,
    String? categoryId,
    double? amount,
    String? note,
    String? date,
    String? status,
    int? isDeleted,
    String? createdAt,
    CategoryType? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jarId: jarId ?? this.jarId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
    );
  }
}