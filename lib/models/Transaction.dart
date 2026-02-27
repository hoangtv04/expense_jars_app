import 'Category.dart';

class   Transaction {
  final int? id;
  final int userId;
  final int jarId;
  final int categoryId;
  final double amount;
  final String? note;
  final String? date;
  final String? status;
  final int isDeleted;
  final String? createdAt;

  /// 🔥 THÊM DÒNG NÀY
  final CategoryType? type;

  Transaction({
    this.id,
    required this.userId,
    required this.jarId,
    required this.categoryId,
    required this.amount,
    this.note,
    this.date,
    this.status = 'completed',
    this.isDeleted = 0,
    this.createdAt,
    this.type, // 🔥 THÊM
  });


  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      userId: map['user_id'],
      jarId: map['jar_id'],
      categoryId: map['category_id'],
      amount: (map['amount'] as num).toDouble(),
      note: map['note'],
      date: map['date'],
      status: map['status'],
      isDeleted: map['is_deleted'],
      createdAt: map['created_at'],

      /// 🔥 CONVERT STRING → ENUM
      type: map['type'] != null
          ? CategoryType.values.firstWhere(
            (e) => e.name == map['type'],
      )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'jar_id': jarId,
      'category_id': categoryId,
      'amount': amount,
      'note': note,
      'date': date,
      'status': status,
      'is_deleted': isDeleted,
      'created_at': createdAt,
    };
  }

}