import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    loadMonthly();
  }

  Future<void> loadMonthly() async {
    final data = await controller.getMonthlyReport(1); 
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

  Widget buildMonthlyTab() {
    if (monthlyData.isEmpty) {
      return const Center(
        child: Text("Không có dữ liệu"),
      );
    }

    return ListView.builder(
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
    );
  }

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
          const Center(child: Text("Report Ngày")),
          const Center(child: Text("Report Tuần")),
          buildMonthlyTab(),
          const Center(child: Text("Report Quý")),
          const Center(child: Text("Report Năm")),
        ],
      ),
    );
  }
}