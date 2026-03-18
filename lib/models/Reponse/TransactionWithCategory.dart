import '../Category.dart';
import '../Transaction.dart';

class TransactionWithCategory extends Transaction {
  final String? categoryName;
  @override
  final CategoryType type;

  TransactionWithCategory({
    String? id,                // int? -> String?
    required String userId,    // int -> String
    required String jarId,     // Giữ String (vì Jar đã đổi sang UUID)
    required String categoryId, // int -> String (vì Category đã đổi sang UUID)
    required double amount,
    String? note,
    String? date,
    String? status,
    required int isDeleted,
    String? createdAt,
    this.categoryName,
    required this.type,
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
    type: type,
  );

  factory TransactionWithCategory.fromMap(Map<String, dynamic> map) {
    return TransactionWithCategory(
      id: map['id']?.toString(),
      userId: map['user_id'].toString(),
      jarId: map['jar_id'].toString(),
      categoryId: map['category_id'].toString(),
      amount: (map['amount'] as num).toDouble(),
      note: map['note'],
      date: map['date'],
      status: map['status'],
      isDeleted: map['is_deleted'] ?? 0,
      createdAt: map['created_at'],
      categoryName: map['category_name'] as String?,
      type: CategoryType.values.firstWhere(
            (e) => e.name.toLowerCase() == (map['type']?.toString().toLowerCase().trim() ?? ""),
        orElse: () => CategoryType.expense,
      ),
    );
  }
}