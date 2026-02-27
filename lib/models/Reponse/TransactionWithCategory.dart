import '../Category.dart';
import '../Transaction.dart';

class TransactionWithCategory extends Transaction {
  final String? categoryName;
  final CategoryType type; // 🔥 THÊM DÒNG NÀY

  TransactionWithCategory({
    int? id,
    required int userId,
    required int jarId,
    required int categoryId,
    required double amount,
    String? note,
    String? date,
    String? status,
    required int isDeleted,
    required String createdAt,
    this.categoryName,
    required this.type, // 🔥 THÊM
  }) : super(
    id: id,
    userId: userId,
    jarId: jarId,
    categoryId: categoryId,
    amount: amount,
    note: note,
    date: date,
    status: status,
    isDeleted: isDeleted,
    createdAt: createdAt,
  );

  factory TransactionWithCategory.fromMap(Map<String, dynamic> map) {
    return TransactionWithCategory(
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
      categoryName: map['category_name'] as String?,

      type: CategoryType.values.firstWhere(
            (e) => e.name == map['category_type'],
        orElse: () => CategoryType.expense, // fallback an toàn
      ),
    );
  }
}