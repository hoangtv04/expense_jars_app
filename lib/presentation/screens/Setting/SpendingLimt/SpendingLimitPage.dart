import 'package:flutter/material.dart';
import 'AddSpendingLimitPage.dart';
import 'SpendingLimitDetailPage.dart';
import '../../../../controllers/SpendingLimitController.dart';
import '../../../../models/SpendingLimit.dart';
import '../../../../models/Category.dart';
import '../../../../repositories/SpendingLimitRepository.dart';
import '../../../../repositories/CategoryRepository.dart';

class SpendingLimitPage extends StatefulWidget {
  const SpendingLimitPage({super.key});

  @override
  State<SpendingLimitPage> createState() => _SpendingLimitPageState();
}

class _SpendingLimitPageState extends State<SpendingLimitPage> {
  final SpendingLimitController _controller = SpendingLimitController();
  final SpendingLimitRepository _repository = SpendingLimitRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  String _formatCurrency(double amount) {
    final rounded = amount.round();
    final absValue = rounded.abs().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < absValue.length; i++) {
      final indexFromEnd = absValue.length - i;
      buffer.write(absValue[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${rounded < 0 ? '-' : ''}${buffer.toString()} đ';
  }

  Future<String?> _getCategoryIconPath(String categories) async {
    // Trim và kiểm tra
    final trimmedCategories = categories.trim();

    // Nếu là "Tất cả hạng mục chi", nhiều hạng mục (có dấu phẩy), hoặc rỗng
    if (trimmedCategories.isEmpty ||
        trimmedCategories.contains('Tất cả hạng mục chi') ||
        trimmedCategories.contains(',')) {
      return null;
    }

    // Chỉ có 1 hạng mục - lấy category từ database theo tên
    final categoryName = trimmedCategories;
    final allCategories = await _categoryRepository.getAll();
    final category = allCategories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => throw Exception('Category not found'),
    );

    final iconId = category.icon_id;
    if (iconId == null) return null;

    return 'lib/assets/category_icon/$iconId.png';
  }

  Widget _buildCategoryIcon(String categories) {
    return FutureBuilder<String?>(
      future: _getCategoryIconPath(categories),
      builder: (context, snapshot) {
        final iconPath = snapshot.data;

        if (iconPath == null) {
          // Hiển thị icon mặc định khi có nhiều hạng mục
          return Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.category, color: Colors.orange),
          );
        }

        // Hiển thị icon của hạng mục cụ thể
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              iconPath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.category, color: Colors.orange);
              },
            ),
          ),
        );
      },
    );
  }

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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<SpendingLimit>>(
        future: _controller.getSpendingLimits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final limits = snapshot.data ?? [];

          if (limits.isEmpty) {
            return _buildEmptyState();
          }

          return _buildSpendingLimitsList(limits);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddSpendingLimitPage(),
            ),
          ).then((value) {
            if (value == true) {
              setState(() {});
            }
          });
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
                  ).then((value) {
                    if (value == true) {
                      setState(() {});
                    }
                  });
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

  Widget _buildSpendingLimitsList(List<SpendingLimit> limits) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: limits.length,
      itemBuilder: (context, index) {
        final limit = limits[index];

        // Parse date range
        final startDate = DateTime.parse(limit.start_date);
        final endDate = limit.end_date != null
            ? DateTime.parse(limit.end_date!)
            : null;
        final dateRangeText = endDate != null
            ? '${_formatDate(startDate)} - ${_formatDate(endDate)}'
            : _formatDate(startDate);

        return FutureBuilder<double>(
          future: _repository.getSpentAmountForLimit(
            userId: limit.user_id,
            limit: limit,
            fromDate: startDate,
            toDate: endDate ?? startDate.add(const Duration(days: 30)),
          ),
          builder: (context, snapshot) {
            final spent = snapshot.data ?? 0.0;
            final remaining = limit.amount - spent;
            final percentage = limit.amount <= 0 ? 0.0 : spent / limit.amount;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SpendingLimitDetailPage(limitId: limit.id!),
                    ),
                  );
                  if (mounted) {
                    setState(() {});
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Icon, Name, Amount
                      Row(
                        children: [
                          // Category icon
                          _buildCategoryIcon(limit.categories),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  limit.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  dateRangeText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatCurrency(limit.amount),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Hạn mức',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percentage.clamp(0, 1),
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percentage > 1 ? Colors.red : Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Remaining amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Còn ${_getDaysRemaining(startDate, limit.end_date)} ngày',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Còn lại ${_formatCurrency(remaining)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: remaining < 0
                                  ? Colors.red
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  int _getDaysRemaining(DateTime startDate, String? endDate) {
    if (endDate == null) {
      return (startDate
              .add(const Duration(days: 30))
              .difference(DateTime.now())
              .inDays)
          .abs();
    }
    final end = DateTime.parse(endDate);
    return (end.difference(DateTime.now()).inDays).abs();
  }
}
