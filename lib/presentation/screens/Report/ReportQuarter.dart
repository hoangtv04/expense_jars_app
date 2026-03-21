import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../controllers/TransactionController.dart';

class ReportQuarter extends StatefulWidget {
  final String userId;
  const ReportQuarter({super.key, required this.userId});

  @override
  State<ReportQuarter> createState() => _ReportQuarterState();
}

class _ReportQuarterState extends State<ReportQuarter> {
  final TransactionController controller = TransactionController();

  List<Map<String, dynamic>> quarterData = [];
  DateTime currentDate = DateTime.now();

  int get currentQuarter => ((currentDate.month - 1) ~/ 3) + 1;

  @override
  void initState() {
    super.initState();
    loadQuarter();
  }

  Future<void> loadQuarter() async {
    final data = await controller.getQuarterReport(
      widget.userId,
      currentDate.month,
      currentDate.year,
    );

    setState(() {
      quarterData = data;
    });
  }

  // 🔁 chuyển quý
  void changeQuarter(int delta) {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + (delta * 3));
    });

    loadQuarter();
  }

  Widget buildQuarterSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => changeQuarter(-1),
        ),
        Text(
          "Q$currentQuarter/${currentDate.year}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () => changeQuarter(1),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        buildQuarterSelector(),
        const SizedBox(height: 10),
        if (quarterData.isNotEmpty) buildQuarterChart(),
        Expanded(
          child: quarterData.isEmpty
              ? const Center(child: Text("Không có dữ liệu trong Quý này"))
              : ListView.builder(
                  itemCount: quarterData.length,
                  itemBuilder: (context, index) {
                    final item = quarterData[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(item['period']),
                        subtitle: Text(
                          "Thu: ${item['total_income'] ?? 0} | Chi: ${item['total_expense'] ?? 0}",
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget buildQuarterChart() {
    final item = quarterData.isNotEmpty ? quarterData.first : null;

    double income = (item?['total_income'] ?? 0).toDouble();
    double expense = (item?['total_expense'] ?? 0).toDouble();

    double maxY = (income > expense ? income : expense) * 1.2; // scale chart

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.center,
          titlesData: const FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barsSpace: 6,
              barRods: [
                BarChartRodData(
                  toY: income,
                  width: 20,
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),
                BarChartRodData(
                  toY: expense,
                  width: 20,
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