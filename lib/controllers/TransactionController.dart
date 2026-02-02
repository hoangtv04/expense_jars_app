



import '../models/Jar.dart';
import '../models/Transaction.dart';
import '../repositories/TransactionRepository.dart';

class TransactionController {
  final TransactionRepository _repo = TransactionRepository();

  // Future<void> addTrasction(String name, String role) async {
  //   final transaction = Transaction(
  //
  //   );
  //
  //
  //   await _repo.insertTransaction(member);
  // }
  //
  //
  //
  // Future<List<Member>> getMember() async {
  //   return _repo.getAll();
  // }


    Future<List<Transaction>> getTransactionListById(int id) async {
    final list = await _repo.getAllTransactionById(id);
    print('Jar count: ${list.length}');
    return list;
  }

}
