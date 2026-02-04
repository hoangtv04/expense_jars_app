import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../controllers/JarController.dart';
import '../../../controllers/TransactionController.dart';
import '../../../models/Reponse/TransactionWithCategory.dart';
import '../../../models/Transaction.dart';





class JarHistoryPage extends StatefulWidget {
   final int? jarId;

  const JarHistoryPage({
    super.key,
   this.jarId,
  });

  @override
  State<JarHistoryPage> createState() => _JarHistoryPageState();
}


class _JarHistoryPageState extends State<JarHistoryPage> {

  final _controller = TransactionController();

  void getTranscationById() {



  }

  @override
  Widget build(BuildContext context) {
    // final incomeTotal = _mockTransactions
    //     .where((e) => e['type'] == 'income')
    //     .fold<double>(0, (sum, e) => sum + e['amount']);
    //
    // final expenseTotal = _mockTransactions
    //     .where((e) => e['type'] == 'expense')
    //     .fold<double>(0, (sum, e) => sum + e['amount']);

    // final balance = incomeTotal - expenseTotal;
    final balance = 8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
      ),
      body: Column(
        children: [
          // ===== TỔNG QUAN =====
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SummaryItem(
                      label: 'Tổng thu',
                      value: 3,
                      color: Colors.green,
                    ),
                    _SummaryItem(
                      label: 'Tổng chi',
                      value: 3,
                      color: Colors.red,
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Số dư',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${balance.toStringAsFixed(0)} đ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
// ===== DANH SÁCH GIAO DỊCH =====
          Expanded(
            child: FutureBuilder<List<TransactionWithCategory>>(
              future: _controller.getTransactionWithCategory(widget.jarId!),
              builder: (context, snapshot) {
                print('===== FUTURE BUILDER =====');
                print('connectionState: ${snapshot.connectionState}');
                print('hasData: ${snapshot.hasData}');
                print('error: ${snapshot.error}');
                print('data length: ${snapshot.data?.length}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Chưa có giao dịch'));
                }

                final transactions = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final item = transactions[index];
                    final isIncome = item.amount >= 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isIncome
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            child: Icon(
                              isIncome
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.categoryName ?? '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  item.note ?? '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.createdAt.toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${isIncome ? '+' : '-'}${item.amount.toStringAsFixed(0)} đ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}



// ===== WIDGET PHỤ =====
class _SummaryItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(0)} đ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
