import '../Category.dart';
import '../Transaction.dart';

class TransactionWithCategory1 {
  final Transaction transaction;
  final String categoryName;
  final CategoryType type;

  TransactionWithCategory1({
    required this.transaction,
    required this.categoryName,
    required this.type,
  });

  factory TransactionWithCategory1.fromMap(Map<String, dynamic> map) {
    return TransactionWithCategory1(
      transaction: Transaction.fromMap(map),
      categoryName: map['category_name'],
      type: CategoryType.values.firstWhere(
            (e) => e.name == map['type'],
      ),
    );
  }
}