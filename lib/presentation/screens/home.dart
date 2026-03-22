import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/DashboardController.dart';
import 'package:intl/intl.dart';
import '../../db/app_state.dart';
import '../../services/session_services.dart';
import '../../repositories/user_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardController controller = DashboardController();
  final formatter = NumberFormat('#,###', 'vi_VN');

  Future<Map<String, double>>? _summaryFuture;
  String? _userId;
  String _name = "User";
  String _avatar = "?";

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  // Khởi tạo tất cả dữ liệu lần đầu
  Future<void> _initAll() async {
    await _loadUser();
    _refreshSummary();
  }

  Future<void> _loadUser() async {
    final id = await SessionService.getUserId();
    if (id == null) return;

    final user = await UserRepository().getUserById(id);

    if (mounted && user != null) {
      setState(() {
        _userId = id;
        _name = (user.fullName != null && user.fullName!.isNotEmpty)
            ? user.fullName!
            : _formatName(user.email.split('@')[0]);
        _avatar = _name.isNotEmpty ? _name[0].toUpperCase() : "?";
      });
    }
  }

  // Hàm này chỉ để cập nhật lại số liệu Dashboard
  void _refreshSummary() {
    if (_userId == null) return;
    setState(() {
      _summaryFuture = controller.getSummary(_userId!);
    });
  }

  String _formatName(String raw) {
    return raw
        .replaceAll(RegExp(r'[0-9]'), '')
        .replaceAll(RegExp(r'[._]'), ' ')
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() + e.substring(1) : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),
      body: ValueListenableBuilder(
        valueListenable: AppState.jarChanged,
        builder: (context, value, child) {
          // KHÔNG gọi setState hay loadData ở đây.
          // Chỉ trả về Widget sử dụng FutureBuilder.
          return FutureBuilder<Map<String, double>>(
            future: _summaryFuture,
            builder: (context, snapshot) {
              if (_userId == null || snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("❌ Lỗi: ${snapshot.error}"));
              }

              final data = snapshot.data ?? {'income': 0.0, 'expense': 0.0, 'balance': 0.0};
              final income = data['income'] ?? 0.0;
              final expense = data['expense'] ?? 0.0;
              final balance = data['balance'] ?? 0.0;

              return RefreshIndicator(
                onRefresh: () async {
                  await _loadUser();
                  _refreshSummary();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeader(balance),
                      // Đưa nội dung vào Card cho đẹp
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Transform.translate(
                          offset: const Offset(0, -30),
                          child: _buildOverviewCard(income, expense),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ================= CÁC WIDGET GIAO DIỆN =================

  Widget _buildHeader(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 60), // Tăng bottom padding
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3FA9F5), Color(0xFF2B7CD3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Text(_avatar, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Xin chào!", style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text(_name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _refreshSummary,
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Text("Tổng số dư", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 5),
          Text(
            "${formatter.format(balance)} đ",
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(double income, double expense) {
    final diff = income - expense;
    final maxValue = income > expense ? income : expense;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tình hình thu chi", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              // Biểu đồ cột
              SizedBox(
                height: 120,
                width: 80,
                child: BarChart(
                  BarChartData(
                    maxY: maxValue == 0 ? 100 : maxValue * 1.2,
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(toY: income, width: 12, color: Colors.green, borderRadius: BorderRadius.circular(4)),
                          BarChartRodData(toY: expense, width: 12, color: Colors.red, borderRadius: BorderRadius.circular(4)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Thông tin chi tiết
              Expanded(
                child: Column(
                  children: [
                    _moneyRow("Thu", income.toInt(), Colors.green),
                    const SizedBox(height: 12),
                    _moneyRow("Chi", expense.toInt(), Colors.red),
                    const Divider(height: 24),
                    _moneyRow("Còn lại", diff.toInt(), Colors.blue),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _moneyRow(String title, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text("${formatter.format(value)} đ", style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}