import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/DashboardController.dart';
import 'package:intl/intl.dart';
import '../../db/app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardController controller = DashboardController();
  final formatter = NumberFormat('#,###', 'vi_VN');

  late Future<Map<String, double>> summaryFuture;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    summaryFuture = controller.getSummary("aaa");
  }

  void refreshData() {
    setState(() {
      summaryFuture = controller.getSummary("aaa");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),

      body: ValueListenableBuilder(
        valueListenable: AppState.jarChanged,
        builder: (context, value, child) {
          return FutureBuilder<Map<String, double>>(
            future: controller.getSummary("aaa"),

            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data!;
              final income = data['income'] ?? 0;
              final expense = data['expense'] ?? 0;
              final balance = data['balance'] ?? 0;

              return RefreshIndicator(
                onRefresh: () async {
                  refreshData();
                },

                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeader(balance),

                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: _buildOverviewCard(income, expense),
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

  // ================= HEADER =================

  Widget _buildHeader(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3FA9F5), Color(0xFF2B7CD3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Text(
                      "DC",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Xin chào!",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),

                      SizedBox(height: 4),

                      Text(
                        "duc cuong",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: refreshData,
                  ),

                  const Icon(Icons.notifications_none, color: Colors.white),
                ],
              ),
            ],
          ),

          const SizedBox(height: 25),

          const Text(
            "Tổng số dư",
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Text(
                "${formatter.format(balance)} đ",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.visibility_outlined,
                color: Colors.white70,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= CARD =================

 Widget _buildOverviewCard(double income, double expense) {

  final diff = income - expense;

  final maxValue = income > expense ? income : expense;

  return Container(
    margin: const EdgeInsets.only(top: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(25),
    ),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Tình hình thu chi",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 25),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= BAR CHART =================

            Column(
              children: [

                SizedBox(
                  height: 120,
                  width: 90,

                  child: BarChart(
                    BarChartData(

                      maxY: maxValue + 200,

                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(show: false),

                      barGroups: [

                        BarChartGroupData(
                          x: 0,
                          barsSpace: 8,

                          barRods: [

                            BarChartRodData(
                              toY: income,
                              width: 14,
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(6),
                            ),

                            BarChartRodData(
                              toY: expense,
                              width: 14,
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),

                          ],
                        ),

                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    _legend(Colors.green, "Thu"),
                    const SizedBox(width: 10),
                    _legend(Colors.red, "Chi"),
                  ],
                )

              ],
            ),

            const SizedBox(width: 20),

            // ================= MONEY INFO =================

            Expanded(
              child: Column(
                children: [

                  _moneyRow("Thu", income.toInt(), Colors.green),

                  const SizedBox(height: 15),

                  _moneyRow("Chi", expense.toInt(), Colors.red),

                  const Divider(),

                  _moneyRow("Chênh lệch", diff.toInt(), Colors.blue),

                ],
              ),
            )

          ],
        ),

        const SizedBox(height: 30),

        Center(
          child: OutlinedButton(
            onPressed: () {},
            child: const Text("Lịch sử ghi chép"),
          ),
        )

      ],
    ),
  );
}

  Widget _moneyRow(String title, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),

        Text(
          "${formatter.format(value)} đ",

          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _legend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
