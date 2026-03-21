import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../controllers/TransactionController.dart';

class ReportYearly extends StatefulWidget {
  const ReportYearly({super.key});

  @override
  State<ReportYearly> createState() => _ReportYearlyState();
}

class _ReportYearlyState extends State<ReportYearly> {
  final TransactionController controller = TransactionController();

  List<Map<String, dynamic>> yearlyData = [];

  int currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    loadYearly();
  }

  Future<void> loadYearly() async {
    final data = await controller.getYearlyReport(
      "1", // userId
      currentYear,
    );

    setState(() {
      yearlyData = data;
    });

    print("Yearly Data: $yearlyData");
  }

  // ================= YEAR SELECTOR =================
  Widget buildYearSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() {
              currentYear--;
            });
            loadYearly();
          },
        ),

        Text(
          "$currentYear",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            setState(() {
              currentYear++;
            });
            loadYearly();
          },
        ),
      ],
    );
  }

  // ================= CHART =================
  Widget buildYearlyChart() {
    if (yearlyData.isEmpty) return const SizedBox();

    final item = yearlyData.first;

    double income = (item['total_income'] as num).toDouble();
    double expense = (item['total_expense'] as num).toDouble();

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
                  if (value.toInt() == 0) {
                    return const Text("Thu");
                  } else {
                    return const Text("Chi");
                  }
                },
              ),
            ),
          ),

          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: income,
                  width: 30,
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: expense,
                  width: 30,
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),

        buildYearSelector(),

        const SizedBox(height: 10),

        if (yearlyData.isNotEmpty) buildYearlyChart(),

        Expanded(
          child: yearlyData.isEmpty
              ? const Center(child: Text("Không có dữ liệu"))
              : ListView.builder(
                  itemCount: yearlyData.length,
                  itemBuilder: (context, index) {
                    final item = yearlyData[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text("Năm: ${item['period']}"),
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
}