import 'dart:math';
import 'package:flutter/material.dart';
import '../../../controllers/DashBoardController.dart';

class Thongke extends StatefulWidget {
  const Thongke({super.key});

  @override
  State<Thongke> createState() => _ThongkeState();
}

class _ThongkeState extends State<Thongke> {
  final DashboardController controller = DashboardController();

  double income = 0;
  double expense = 0;
  bool isLoading = true;

  double get balance => income - expense;

  double get percent {
    if (income + expense == 0) return 0;
    return income / (income + expense);
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      const userId = 1;

      final summary = await controller.getSummary(userId);

      setState(() {
        income = summary['income'] ?? 0;
        expense = summary['expense'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Lỗi loadData: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Báo cáo tổng quan',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Biểu đồ thu / chi',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      height: 200,
                      width: 200,
                      child: CustomPaint(
                        painter: PieChartPainter(incomePercent: percent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(child: LegendWidget()),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Số dư hiện tại'),
          const SizedBox(height: 8),
          Text(
            '${balance.toStringAsFixed(0)} đ',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  title: 'Tổng thu',
                  value: '+${income.toStringAsFixed(0)} đ',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  title: 'Tổng chi',
                  value: '-${expense.toStringAsFixed(0)} đ',
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final double incomePercent;

  PieChartPainter({required this.incomePercent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 16;

    final incomePaint = Paint()..color = Colors.green;
    final expensePaint = Paint()..color = Colors.red;

    final startAngle = -pi / 2;
    final incomeSweep = 2 * pi * incomePercent;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      incomeSweep,
      true,
      incomePaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + incomeSweep,
      2 * pi * (1 - incomePercent),
      true,
      expensePaint,
    );
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.incomePercent != incomePercent;
  }
}

class LegendWidget extends StatelessWidget {
  const LegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _LegendItem(color: Colors.green, text: 'Tổng thu'),
        SizedBox(width: 24),
        _LegendItem(color: Colors.red, text: 'Tổng chi'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}