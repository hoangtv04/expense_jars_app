import 'package:flutter/material.dart';

class JarLogPage extends StatelessWidget {
  final VoidCallback onChanged;

  const JarLogPage({
    super.key,
    required this.onChanged,
  });


  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả (sau này thay bằng DB)
    final List<Map<String, dynamic>> logs = [
      {
        'title': 'Ăn sáng',
        'amount': -30000,
        'date': '01/02/2026',
      },
      {
        'title': 'Lương part-time',
        'amount': 200000,
        'date': '31/01/2026',
      },
      {
        'title': 'Mua sách',
        'amount': -120000,
        'date': '30/01/2026',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử hũ tiền'),
      ),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final bool isIncome = log['amount'] > 0;

          return ListTile(
            leading: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
            ),
            title: Text(log['title']),
            subtitle: Text(log['date']),
            trailing: Text(
              '${log['amount']} đ',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // sau này mở trang thêm log
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
