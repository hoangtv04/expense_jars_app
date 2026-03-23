import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../controllers/TransactionController.dart';
import 'ReportDaily.dart';
import 'ReportWeekly.dart';
import 'ReportYearly.dart';
import 'ReportQuarter.dart';
import '../../../services/session_services.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String? userId; // 
  final TransactionController controller = TransactionController();

  List<Map<String, dynamic>> monthlyData = [];

  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    initUser();
  }

  // ================= LOAD USER =================
  Future<void> initUser() async {
    final id = await SessionService.getUserId();

    print("GET USER ID: $id");

    if (id == null) {
      print("Không có userId → cần login lại");
      return;
    }

    setState(() {
      userId = id;
    });

    await loadMonthly();
  }

  Future<void> loadMonthly() async {
    if (userId == null) return;

    final data = await controller.getMonthlyReport(
      userId!,
      currentMonth,
      currentYear,
    );

    setState(() {
      monthlyData = data;
    });

    print("Monthly Data: $monthlyData");
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ================= MONTH SELECTOR =================

  Widget buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() {
              currentMonth--;

              if (currentMonth < 1) {
                currentMonth = 12;
                currentYear--;
              }
            });

            loadMonthly();
          },
        ),
        Text(
          "Tháng $currentMonth / $currentYear",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            setState(() {
              currentMonth++;

              if (currentMonth > 12) {
                currentMonth = 1;
                currentYear++;
              }
            });

            loadMonthly();
          },
        ),
      ],
    );
  }

  // ================= MONTH TAB =================

  Widget buildMonthlyTab() {
    return Column(
      children: [
        const SizedBox(height: 10),
        buildMonthSelector(),
        const SizedBox(height: 10),

        if (monthlyData.isNotEmpty) buildMonthlyChart(),

        if (monthlyData.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                "Chưa có giao dịch nào trong tháng này.",
                textAlign: TextAlign.center,
              ),
            ),
          ),

        if (monthlyData.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: monthlyData.length,
              itemBuilder: (context, index) {
                final item = monthlyData[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("Tháng: ${item['period']}"),
                    subtitle: Text(
                      "Thu: ${item['total_income']} | Chi: ${item['total_expense']}",
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ================= CHART =================

  Widget buildMonthlyChart() {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();

                  if (index >= monthlyData.length) {
                    return const Text("");
                  }

                  String period = monthlyData[index]['period'];
                  String month = period.split('-')[1];

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(month),
                  );
                },
              ),
            ),
          ),
          barGroups: monthlyData.asMap().entries.map((entry) {
            int index = entry.key;
            var item = entry.value;

            double income = (item['total_income'] ?? 0).toDouble();
            double expense = (item['total_expense'] ?? 0).toDouble();

            return BarChartGroupData(
              x: index,
              barsSpace: 6,
              barRods: [
                BarChartRodData(toY: income,borderRadius: BorderRadius.circular(2),width: 10, color: Colors.green),
                BarChartRodData(toY: expense, borderRadius: BorderRadius.circular(2), width: 10, color: Colors.red),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ================= MAIN UI =================

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: loading trước khi có userId
    if (userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Báo Cáo"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: "Ngày"),
            Tab(text: "Tuần"),
            Tab(text: "Tháng"),
            Tab(text: "Quý"),
            Tab(text: "Năm"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ReportDaily(userId: userId!),
          ReportWeekly(userId: userId!),
          buildMonthlyTab(),
          ReportQuarter(userId: userId!),
          ReportYearly(userId: userId!),
        ],
      ),
    );
  }
}
