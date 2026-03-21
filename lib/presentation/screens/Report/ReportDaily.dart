import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../controllers/TransactionController.dart';

class ReportDaily extends StatefulWidget {
  final String userId;
  const ReportDaily({super.key, required this.userId});

  @override
  State<ReportDaily> createState() => _ReportDailyState();
}

class _ReportDailyState extends State<ReportDaily> {
  final TransactionController controller = TransactionController();

  List<Map<String, dynamic>> dailyData = [];

  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadDaily();
  }

  Future<void> loadDaily() async {
    final data = await controller.getDailyReport(
      widget.userId,
      currentDate.day,
      currentDate.month,
      currentDate.year,
    );

    setState(() {
      dailyData = data;
    });
  }

  Widget buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() {
              currentDate = currentDate.subtract(const Duration(days: 1));
            });

            loadDaily();
          },
        ),

        Text(
          "${currentDate.day}/${currentDate.month}/${currentDate.year}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            setState(() {
              currentDate = currentDate.add(const Duration(days: 1));
            });

            loadDaily();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),

        buildDateSelector(),

        const SizedBox(height: 10),

        if (dailyData.isNotEmpty) buildDailyChart(),

        Expanded(
          child: dailyData.isEmpty
              ? const Center(child: Text("Chưa có giao dịch trong ngày này"))
              : ListView.builder(
                  itemCount: dailyData.length,
                  itemBuilder: (context, index) {
                    final item = dailyData[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text("Ngày: ${item['period']}"),
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

  Widget buildDailyChart() {
    double income = 0;
    double expense = 0;

    if (dailyData.isNotEmpty) {
      income = (dailyData[0]['total_income'] as num).toDouble();
      expense = (dailyData[0]['total_expense'] as num).toDouble();
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,

          titlesData: const FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),

          barGroups: [
            BarChartGroupData(
              x: 0,
              barsSpace: 6,
              barRods: [
                BarChartRodData(
                  toY: income,
                  width: 14,
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),

                BarChartRodData(
                  toY: expense,
                  width: 14,
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
