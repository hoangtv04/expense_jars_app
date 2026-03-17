import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ReportDaily.dart';
import '../../../controllers/TransactionController.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TransactionController controller = TransactionController();

  List<Map<String, dynamic>> monthlyData = [];

  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    loadMonthly();
  }

  Future<void> loadMonthly() async {
    final data = await controller.getMonthlyReport(
      1, // userId
      currentMonth, // tháng đang chọn
      currentYear, // năm
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

  // ---------------- MONTH SELECTOR ----------------

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

  // ---------------- MONTH TAB ----------------

  Widget buildMonthlyTab() {
    return Column(
      children: [
        const SizedBox(height: 10),

        buildMonthSelector(),

        const SizedBox(height: 10),

        // Nếu có dữ liệu thì show chart
        if (monthlyData.isNotEmpty) buildMonthlyChart(),

        // Nếu không có dữ liệu
        if (monthlyData.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Không có dữ liệu tháng này"),
          ),

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

  // ---------------- BAR CHART ----------------

  Widget buildMonthlyChart() {
    if (monthlyData.isEmpty) {
      return const SizedBox();
    }

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

            double income = (item['total_income'] as num).toDouble();
            double expense = (item['total_expense'] as num).toDouble();

            return BarChartGroupData(
              x: index,
              barsSpace: 6,
              barRods: [
                BarChartRodData(
                  toY: income,
                  width: 10,
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),

                BarChartRodData(
                  toY: expense,
                  width: 10,
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------------- MAIN UI ----------------

  @override
  Widget build(BuildContext context) {
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
          ReportDaily(),

          const Center(child: Text("Report Tuần")),

          buildMonthlyTab(),

          const Center(child: Text("Report Quý")),

          const Center(child: Text("Report Năm")),
        ],
      ),
    );
  }
}
