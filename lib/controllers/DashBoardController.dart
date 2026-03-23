import 'package:flutter_application_jars/repositories/TransactionRepository.dart';


class DashboardController {

  final TransactionRepository transactionRepo = TransactionRepository();

  Future<Map<String, double>> getSummary(String userId) async {
    return await transactionRepo.getSummary(userId);
  }
}
