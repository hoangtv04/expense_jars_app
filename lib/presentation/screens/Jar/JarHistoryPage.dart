import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_jars/controllers/JarController.dart';

import '../../../controllers/TransactionController.dart';
import '../../../models/Category.dart';
import '../../../models/Reponse/TransactionWithCategory.dart';

class JarHistoryPage extends StatefulWidget {
  final String? jarId;

  const JarHistoryPage({
    super.key,
    this.jarId,
  });

  @override
  State<JarHistoryPage> createState() => _JarHistoryPageState();
}

class _JarHistoryPageState extends State<JarHistoryPage> {
  final _controller = TransactionController();
  final _controllerJar = JarController();

  Future<double>? _incomeFuture;
  Future<double>? _expenseFuture;
  Future<List<TransactionWithCategory>>? _transactionFuture;
  Future<double>? _balanceFuture; // Đổi tên cho rõ nghĩa

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _controller.runRecurringTransactions();

    if (mounted) {
      setState(() {
        _incomeFuture = _controller.getTransactionsTotalIncome(widget.jarId ?? '');
        _expenseFuture = _controller.getTransactionsTotalExpense(widget.jarId ?? '');
        _transactionFuture = _controller.getTransactionsWithCategory(widget.jarId ?? '');
        // Lấy số dư thật từ hũ
        _balanceFuture = _controllerJar.getJarBalance(widget.jarId ?? '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check thêm _balanceFuture ở đây
    if (_incomeFuture == null || _expenseFuture == null || _transactionFuture == null || _balanceFuture == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử giao dịch'), elevation: 0),
      body: Column(
        children: [
          /// ===== TỔNG QUAN (THU - CHI - DƯ) =====
          FutureBuilder<List<dynamic>>(
            // Đưa cả 3 Future vào đây để đợi cùng lúc
            future: Future.wait([_incomeFuture!, _expenseFuture!, _balanceFuture!]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final income = snapshot.data![0] as double;
              final expense = snapshot.data![1] as double;
              final currentJarBalance = snapshot.data![2] as double; // Đây là số dư thật từ hũ

              return Container(
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
                        _SummaryItem(label: 'Tổng thu', value: income, color: Colors.green),
                        _SummaryItem(label: 'Tổng chi', value: expense, color: Colors.red),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Số dư hũ hiện tại',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${currentJarBalance.toStringAsFixed(0)} đ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: currentJarBalance >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          /// ===== DANH SÁCH GIAO DỊCH CHI TIẾT =====
          Expanded(
            child: FutureBuilder<List<TransactionWithCategory>>(
              future: _transactionFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('Chưa có giao dịch nào trong hũ này'),
                      ],
                    ),
                  );
                }

                final transactions = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final item = transactions[index];
                    final isIncome = item.type == CategoryType.income;

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
                            backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                            child: Icon(
                              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.categoryName ?? 'Không xác định',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (item.note != null && item.note!.isNotEmpty)
                                  Text(
                                    item.note!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  item.createdAt.toString().substring(0, 16), // Cắt bớt phần mili giây
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black45,
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

// ===== WIDGET PHỤ (Dùng nội bộ trong trang) =====
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