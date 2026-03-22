import 'dart:math';
import 'package:flutter/material.dart';
import '../../../controllers/DashBoardController.dart';
import '../../../db/app_state.dart';
import '../../../services/session_services.dart';
import '../../screens/login.dart';// chắc là path LoginScreen

class Thongke extends StatefulWidget {
  const Thongke({super.key});

  @override
  State<Thongke> createState() => _ThongkeState();
}

class _ThongkeState extends State<Thongke> {
  final DashboardController controller = DashboardController();
  String? userId;
  Future<Map<String, double>>? summaryFuture;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  // Hàm này sẽ dùng chung cho cả lúc khởi tạo và lúc bấm nút Reload
  Future<void> initUser() async {
    final id = await SessionService.getUserId();

    if (id == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }

    setState(() {
      userId = id;
      // Gọi lại getSummary để làm mới dữ liệu
      summaryFuture = controller.getSummary(userId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔥 THÊM APPBAR CÓ NÚT RELOAD
      appBar: AppBar(
        title: const Text("Thống kê"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Khi bấm nút refresh thì gọi lại initUser
              initUser();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // Tách phần body ra cho code sạch sẽ
  Widget _buildBody() {
    if (userId == null || summaryFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<int>(
      valueListenable: AppState.jarChanged,
      builder: (context, value, child) {
        return FutureBuilder<Map<String, double>>(
          // Mỗi khi initUser gọi setState, summaryFuture mới sẽ được truyền vào đây
          future: summaryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("Không có dữ liệu"));
            }

            final income = snapshot.data!['income'] ?? 0;
            final expense = snapshot.data!['expense'] ?? 0;
            final balance = snapshot.data!['balance'] ?? 0;

            final percent = (income + expense == 0) ? 0.0 : income / (income + expense);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Báo cáo tổng quan",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildBalanceCard(balance, income, expense),
                  const SizedBox(height: 24),
                  const Text(
                    "Biểu đồ thu / chi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            );
          },
        );
      },
    );
  }

  Widget _buildBalanceCard(double balance, double income, double expense) {
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
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
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