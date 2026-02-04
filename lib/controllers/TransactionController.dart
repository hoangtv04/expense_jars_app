



import '../models/Jar.dart';
import '../models/Reponse/TransactionWithCategory.dart';
import '../models/Transaction.dart';
import '../repositories/TransactionRepository.dart';

class TransactionController {
  final TransactionRepository _repo = TransactionRepository();

  Future<List<Transaction>> getAll() async {
    return await _repo.getAllTransactions();
  }

  Future<void> delete(int id) async {
    await _repo.deleteTransactions(id);
  }

  Future<void> add(Transaction transaction) async {
    if (transaction.amount <= 0) {
      throw Exception("Amount không hợp lệ");
    }
    await _repo.insertTransactions(transaction);
  }


    Future<List<Transaction>> getTransactionListById(int id) async {
    final list = await _repo.getAllTransactionByJarId(id);
    print('Jar count: ${list.length}');
    return list;
  }



  Future<List<TransactionWithCategory>> getTransactionWithCategory(int jarId) async {
    print('===== TransactionController =====');
    print('jarId nhận được: $jarId');

    final list = await _repo.getAllTransactionAndCategoryName(jarId);

    print('KẾT QUẢ TỪ REPO');
    print('Số lượng record: ${list.length}');

    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      print(
          '[$i] '
              'id=${item.id}, '
              'categoryId=${item.categoryId}, '
              'categoryName=${item.categoryName}, '
              'amount=${item.amount}'
      );
    }

    print('===== END TransactionController =====');

    return list;
  }

}
