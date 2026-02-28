import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key, required void Function() onChanged});

  final formatter = NumberFormat('#,###', 'vi_VN');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Transform.translate(
              offset: const Offset(0, -30),
              child: _buildOverviewCard(),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 50,
        left: 20,
        right: 20,
        bottom: 25,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF3FA9F5),
            Color(0xFF2B7CD3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ===== TOP ROW =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// Avatar + Name
              Row(
                children: [
                  CircleAvatar(
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

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Xin chào!",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
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

              /// Icons bên phải
              Row(
                children: [
                  Stack(
                    children: [
                      const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            "3",
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 25),

          /// ===== BALANCE =====
          const Text(
            "Tổng số dư",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Text(
                "1.009.477 đ",
                style: TextStyle(
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
  Widget _buildOverviewCard() {
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
          // HEADER ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tình hình thu chi",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Icon(Icons.settings_outlined,
                      color: Colors.grey),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: const Row(
                      children: [
                        Text("Tuần này"),
                        Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),

          const SizedBox(height: 25),

          // BAR + TEXT
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 120,
                width: 80,
                child: BarChart(
                  BarChartData(
                    maxY: 600,
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: 522,
                            width: 20,
                            color: Colors.red,
                            borderRadius:
                            BorderRadius.circular(6),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  children: [
                    _moneyRow("Thu", 0, Colors.green),
                    const SizedBox(height: 15),
                    _moneyRow("Chi", 522, Colors.red),
                    const Divider(),
                    _moneyRow("Chênh lệch", -522, Colors.black),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 30),

          // DONUT CHART
          Row(
            children: [
              SizedBox(
                height: 160,
                width: 160,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 50,
                    sections: [
                      PieChartSectionData(
                        value: 100,
                        color: Colors.orange,
                        showTitle: false,
                        radius: 40,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: Colors.orange,
                      ),
                      SizedBox(width: 8),
                      Text("Con cái"),
                      SizedBox(width: 30),
                      Text("100%",
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              )
            ],
          ),

          const SizedBox(height: 20),

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
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}