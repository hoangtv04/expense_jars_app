import 'package:flutter/material.dart';
import 'AddSpendingLimitPage.dart';

class SpendingLimitPage extends StatefulWidget {
  const SpendingLimitPage({super.key});

  @override
  State<SpendingLimitPage> createState() => _SpendingLimitPageState();
}

class _SpendingLimitPageState extends State<SpendingLimitPage> {
  // TODO: Load spending limits from database
  List<Map<String, dynamic>> spendingLimits = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hạn mức chi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: spendingLimits.isEmpty
          ? _buildEmptyState()
          : _buildSpendingLimitsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddSpendingLimitPage(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Image.asset(
              'lib/assets/revenue.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            Text(
              'Bạn chưa có hạn mức chi nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddSpendingLimitPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 22),
                label: const Text(
                  'Thêm hạn mức',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0288D1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                _showHelpDialog();
              },
              child: const Text(
                'Hạn mức chi là gì?',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF0288D1),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingLimitsList() {
    // TODO: Implement list view for spending limits
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: spendingLimits.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text(spendingLimits[index]['name'] ?? ''),
            subtitle: Text(spendingLimits[index]['amount']?.toString() ?? ''),
          ),
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hạn mức chi là gì?'),
        content: const Text(
          'Hạn mức chi giúp bạn kiểm soát chi tiêu bằng cách đặt giới hạn số tiền có thể chi trong một khoảng thời gian nhất định (ngày, tuần, tháng).\n\n'
          'Khi chi tiêu vượt quá hạn mức, bạn sẽ nhận được thông báo cảnh báo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }
}
