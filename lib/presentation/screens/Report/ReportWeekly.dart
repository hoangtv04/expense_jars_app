import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../controllers/TransactionController.dart';

class ReportWeekly extends StatefulWidget {
  final String userId;
  const ReportWeekly({super.key, required this.userId});

  @override
  State<ReportWeekly> createState() => _ReportWeeklyState();
}

class _ReportWeeklyState extends State<ReportWeekly> {

  final TransactionController controller = TransactionController();

  List<Map<String, dynamic>> weeklyData = [];

  DateTime currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadWeekly();
  }

  Future<void> loadWeekly() async {

    final data = await controller.getWeeklyReport(
      widget.userId,
      currentMonth.month,
      currentMonth.year,
    );

    setState(() {
      weeklyData = data;
    });
  }

  Widget buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {

            setState(() {
              currentMonth = DateTime(
                currentMonth.year,
                currentMonth.month - 1,
              );
            });

            loadWeekly();
          },
        ),

        Text(
          "Tháng ${currentMonth.month}/${currentMonth.year}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {

            setState(() {
              currentMonth = DateTime(
                currentMonth.year,
                currentMonth.month + 1,
              );
            });

            loadWeekly();
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

        buildMonthSelector(),

        const SizedBox(height: 10),

        if (weeklyData.isNotEmpty) buildWeeklyChart(),

        Expanded(
          child: weeklyData.isEmpty
              ? const Center(child: Text("Chưa có giao dịch trong tuần này"))
              : ListView.builder(
                  itemCount: weeklyData.length,
                  itemBuilder: (context, index) {

                    final item = weeklyData[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text("Tuần ${item['week']}"),
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

  Widget buildWeeklyChart() {

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

                  int week = value.toInt();

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text("W$week"),
                  );
                },
              ),
            ),

          ),

          barGroups: weeklyData.map((item) {

            int week = item['week'];

            double income = (item['total_income'] as num).toDouble();
            double expense = (item['total_expense'] as num).toDouble();

            return BarChartGroupData(
              x: week,
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
}