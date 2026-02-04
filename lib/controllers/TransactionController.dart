



import '../models/Jar.dart';
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
    final list = await _repo.getAllTransactionById(id);
    print('Jar count: ${list.length}');
    return list;
  }

}
