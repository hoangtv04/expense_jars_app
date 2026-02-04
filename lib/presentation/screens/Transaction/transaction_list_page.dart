import 'package:flutter/material.dart';
import '../../../controllers/TransactionController.dart';
import '../../../models/Transaction.dart';
import 'transaction_add_page.dart';

class TransactionListPage extends StatefulWidget {
  final VoidCallback onChanged;

  const TransactionListPage({
        super.key,
         required this.onChanged,
  });

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  final TransactionController _controller = TransactionController();
  late Future<List<Transaction>> _futureTransactions;

  @override
  void initState() {
    super.initState();
    _futureTransactions = _controller.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: HeroMode(
          enabled: false,
          child: AppBar(
            title: const Text('Transactions'),
          ),
        ),
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _futureTransactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final transactions = snapshot.data!;

          if (transactions.isEmpty) {
            return const Center(child: Text('Không có giao dịch nào'));
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              return ListTile(
                title: Text('Số tiền: ${t.amount}'),
                subtitle: Text(t.date!),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await _controller.delete(t.id!);
                    setState(() {
                      _futureTransactions = _controller.getAll();
                    });
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TransactionAddPage()),
          );
          if (result == true) {
            setState(() {
              _futureTransactions = _controller.getAll();
            });
          }
        },
     ),
    );
  }
}