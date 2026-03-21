import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../controllers/TransactionController.dart';

class ReportYearly extends StatefulWidget {
  final String userId;
  const ReportYearly({super.key, required this.userId});

  @override
  State<ReportYearly> createState() => _ReportYearlyState();
}

class _ReportYearlyState extends State<ReportYearly> {
  final TransactionController controller = TransactionController();

  Map<String, double> yearlyTotal = {'total_income': 0.0, 'total_expense': 0.0};
  int currentYear = DateTime.now().year;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadYearly();
  }

  Future<void> loadYearly() async {
    setState(() => loading = true);
    final data = await controller.getYearlyReport(widget.userId, currentYear);
    setState(() {
      yearlyTotal = data.map((key, value) => MapEntry(key, value.toDouble()));
      loading = false;
    });
  }

  Widget buildYearSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() => currentYear--);
            loadYearly();
          },
        ),
        Text(
          "$currentYear",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            setState(() => currentYear++);
            loadYearly();
          },
        ),
      ],
    );
  }

  Widget buildYearlyChart() {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) =>
                    value.toInt() == 0 ? const Text("Thu") : const Text("Chi"),
              ),
            ),
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                    toY: yearlyTotal['total_income'] ?? 0,
                    width: 30,
                    color: Colors.green)
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                    toY: yearlyTotal['total_expense'] ?? 0,
                    width: 20,
                    color: Colors.red)
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    final hasData = (yearlyTotal['total_income'] ?? 0) > 0 ||
        (yearlyTotal['total_expense'] ?? 0) > 0;

    return Column(
      children: [
        const SizedBox(height: 10),
        buildYearSelector(),
        const SizedBox(height: 10),
        if (hasData) buildYearlyChart(),
        Expanded(
          child: hasData
              ? ListView(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text("Năm: $currentYear"),
                        subtitle: Text(
                            "Thu: ${yearlyTotal['total_income']} | Chi: ${yearlyTotal['total_expense']}"),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Text(
                    "Chưa có giao dịch nào trong năm này.",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      ],
    );
  }
}