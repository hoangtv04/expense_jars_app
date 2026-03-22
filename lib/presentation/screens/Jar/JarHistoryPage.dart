import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_jars/controllers/JarController.dart';

import '../../../controllers/TransactionController.dart';
import '../../../models/Category.dart';
import '../../../models/Reponse/TransactionWithCategory.dart';
import '../../../models/Transaction.dart';
import '../Transaction/transaction_edit_page.dart';

class JarHistoryPage extends StatefulWidget {
  final String? jarId;

  const JarHistoryPage({super.key, this.jarId});

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

  final List<TransactionWithCategory> _transactions = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final newTransactions = await _controller.runRecurringTransactions();

    if (mounted) {
      setState(() {
        _incomeFuture = _controller.getTransactionsTotalIncome(
          widget.jarId ?? '',
        );
        _expenseFuture = _controller.getTransactionsTotalExpense(
          widget.jarId ?? '',
        );
        _transactionFuture = _controller.getTransactionsWithCategory(
          widget.jarId ?? '',
        );
        // Lấy số dư thật từ hũ
        _balanceFuture = _controllerJar.getJarBalance(widget.jarId ?? '');
      });
    }
    //  THÔNG BÁO ĐƠN GIẢN
    if (newTransactions.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Có ${newTransactions.length} giao dịch định kỳ mới"),
        ),
      );
    }

    setState(() {
      _incomeFuture = _controller.getTransactionsTotalIncome(widget.jarId!);

      _expenseFuture = _controller.getTransactionsTotalExpense(widget.jarId!);

      _transactionFuture = _controller.getTransactionsWithCategory(
        widget.jarId!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check thêm _balanceFuture ở đây
    if (_incomeFuture == null ||
        _expenseFuture == null ||
        _transactionFuture == null ||
        _balanceFuture == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử giao dịch'), elevation: 0),
      body: Column(
        children: [
          /// ===== TỔNG QUAN (THU - CHI - DƯ) =====
          FutureBuilder<List<dynamic>>(
            // Đưa cả 3 Future vào đây để đợi cùng lúc
            future: Future.wait([
              _incomeFuture!,
              _expenseFuture!,
              _balanceFuture!,
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final income = snapshot.data![0] as double;
              final expense = snapshot.data![1] as double;
              final currentJarBalance =
                  snapshot.data![2] as double; // Đây là số dư thật từ hũ

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
                        _SummaryItem(
                          label: 'Tổng thu',
                          value: income,
                          color: Colors.green,
                        ),
                        _SummaryItem(
                          label: 'Tổng chi',
                          value: expense,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Số dư hũ hiện tại',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${currentJarBalance.toStringAsFixed(0)} đ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: currentJarBalance >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          /// ===== DANH SÁCH GIAO DỊCH =====
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
                        Icon(
                          Icons.history_toggle_off,
                          size: 60,
                          color: Colors.grey,
                        ),
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
                      // ... decoration giữ nguyên ...
                      child: Row(
                        children: [
                          // Giữ nguyên CircleAvatar và Column thông tin
                          CircleAvatar(/* ... */),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.categoryName ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  item.note ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Hiển thị số tiền
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isIncome ? '+' : '-'}${item.amount.toStringAsFixed(0)} đ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isIncome ? Colors.green : Colors.red,
                                ),
                              ),

                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Nút Sửa
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      // Chuyển TransactionWithCategory về Transaction model để dùng cho trang Edit
                                      final transactionToEdit = Transaction(
                                        id: item.id,
                                        userId: item.userId,
                                        jarId: item.jarId,
                                        categoryId: item.categoryId,
                                        amount: item.amount,
                                        type: item.type,
                                        note: item.note,
                                        date: item.date,
                                      );

                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TransactionEditPage(
                                                transaction: transactionToEdit,
                                              ),
                                        ),
                                      );

                                      if (result == true) {
                                        _initData(); // Load lại toàn bộ số liệu và danh sách
                                      }
                                    },
                                  ),

                                  // Nút Xóa
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Xác nhận"),
                                          content: const Text(
                                            "Bạn có chắc muốn xóa giao dịch này không?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text("Hủy"),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text(
                                                "Xóa",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        final transactionToDelete = Transaction(
                                          id: item.id,
                                          userId: item.userId,
                                          jarId: item.jarId,
                                          categoryId: item.categoryId,
                                          amount: item.amount,
                                          type: item.type,
                                          note: item.note,
                                          date: item.date,
                                        );

                                        await _controller.delete(
                                          transactionToDelete,
                                        );

                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Đã xóa giao dịch"),
                                            ),
                                          );
                                        }

                                        _initData();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
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
