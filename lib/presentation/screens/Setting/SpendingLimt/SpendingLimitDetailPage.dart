import 'package:flutter/material.dart';
import '../../../../controllers/SpendingLimitController.dart';
import '../../../../models/SpendingLimit.dart';
import 'EditSpendingLimitPage.dart';

class SpendingLimitDetailPage extends StatefulWidget {
  final int limitId;

  const SpendingLimitDetailPage({super.key, required this.limitId});

  @override
  State<SpendingLimitDetailPage> createState() =>
      _SpendingLimitDetailPageState();
}

class _SpendingLimitDetailPageState extends State<SpendingLimitDetailPage> {
  final SpendingLimitController _controller = SpendingLimitController();
  int _rebuildKey = 0;

  void _refresh() {
    setState(() {
      _rebuildKey++;
    });
  }

  String _formatCompactCurrency(double value) {
    final rounded = value.round();
    final sign = rounded < 0 ? '-' : '';
    final absValue = rounded.abs().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < absValue.length; i++) {
      final indexFromEnd = absValue.length - i;
      buffer.write(absValue[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return '$sign${buffer.toString()} đ';
  }

  String _formatDecimalCurrency(double value) {
    final sign = value < 0 ? '-' : '';
    final absValue = value.abs();

    // Format với 3 chữ số thập phân
    final formatted = absValue.toStringAsFixed(3);

    // Thay dấu chấm thập phân bằng dấu phẩy
    final withComma = formatted.replaceAll('.', ',');

    return '$sign$withComma đ';
  }

  String _formatShortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  String _formatFullDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: FutureBuilder<Map<String, dynamic>?>(
          key: ValueKey(_rebuildKey),
          future: _controller.getSpendingLimitDetailMetrics(widget.limitId),
          builder: (context, snapshot) {
            final limit = snapshot.data?['limit'] as SpendingLimit?;
            return Text(limit?.name ?? 'Chi tiết hạn mức');
          },
        ),
        actions: [
          FutureBuilder<Map<String, dynamic>?>(
            key: ValueKey('edit_$_rebuildKey'),
            future: _controller.getSpendingLimitDetailMetrics(widget.limitId),
            builder: (context, snapshot) {
              final limit = snapshot.data?['limit'] as SpendingLimit?;
              return IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Chỉnh sửa',
                onPressed: limit == null
                    ? null
                    : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditSpendingLimitPage(
                              spendingLimit: limit,
                              onUpdated: _refresh,
                            ),
                          ),
                        );
                        if (result == true && mounted) {
                          _refresh();
                        }
                      },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        key: ValueKey('body_$_rebuildKey'),
        future: _controller.getSpendingLimitDetailMetrics(widget.limitId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Không tìm thấy hạn mức chi'));
          }

          final limit = data['limit'] as SpendingLimit;
          final cycleStart = data['cycleStart'] as DateTime;
          final cycleEnd = data['cycleEnd'] as DateTime;
          final spent = (data['spent'] as num).toDouble();
          final amountRemaining = (data['amountRemaining'] as num).toDouble();
          final remainingDays = data['remainingDays'] as int;
          final actualDailySpend = (data['actualDailySpend'] as num).toDouble();
          final shouldDailySpend = (data['shouldDailySpend'] as num).toDouble();
          final projectedSpending = (data['projectedSpending'] as num)
              .toDouble();

          final progress = limit.amount <= 0
              ? 0.0
              : (spent / limit.amount).clamp(0.0, 1.0);

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFFE6EEF4),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hạn mức chi',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            _formatCompactCurrency(limit.amount),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          minHeight: 12,
                          value: progress,
                          backgroundColor: const Color(0xFFD7DCE2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            spent > limit.amount
                                ? Colors.red
                                : const Color(0xFF4A90E2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Còn lại ${_formatCompactCurrency(amountRemaining)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: amountRemaining < 0
                                ? Colors.red
                                : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_formatShortDate(cycleStart)} - ${_formatShortDate(cycleEnd)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            'Còn $remainingDays ngày',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_formatFullDate(cycleStart)} - ${_formatFullDate(cycleEnd)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetric(
                              title: 'Thực tế chi tiêu',
                              value: _formatCompactCurrency(actualDailySpend),
                              subtitle: '/ngày',
                            ),
                          ),
                          Expanded(
                            child: _buildMetric(
                              title: 'Nên chi',
                              value: _formatDecimalCurrency(shouldDailySpend),
                              subtitle: '/ngày',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildMetric(
                        title: 'Dự kiến chi tiêu',
                        value: _formatCompactCurrency(projectedSpending),
                        valueColor: projectedSpending > limit.amount
                            ? Colors.red
                            : Colors.green,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Đã chi: ${_formatCompactCurrency(spent)}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionRow(String text) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE9E9E9))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric({
    required String title,
    required String value,
    String subtitle = '',
    Color valueColor = Colors.black,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          '$value$subtitle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
