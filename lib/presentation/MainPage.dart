import 'package:flutter/material.dart';
import 'package:flutter_application_jars/presentation/screens/Jar/JarListPage.dart';
import 'package:flutter_application_jars/presentation/screens/Transaction/transaction_list_page.dart';
import 'package:flutter_application_jars/presentation/screens/home.dart';
import 'package:flutter_application_jars/presentation/screens/Report/Thongke.dart';
import 'package:flutter_application_jars/presentation/screens/Report/Other.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  void refresh() {
    setState(() {});
  }

  late final List<Widget> _pages = [
    home(onChanged: refresh), 
    JarListPage(onChanged: refresh),
    TransactionListPage(onChanged: refresh),
    const Thongke(),
    const OtherPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Jars'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          ),
        ],
      ),


      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Trang chủ', 0),
            _buildNavItem(Icons.account_balance_wallet, 'Hũ tiền', 1),
            _buildNavItem(Icons.add, 'Ghi chép', 2),
            _buildNavItem(Icons.bar_chart, 'Thống kê', 3),
            _buildNavItem(Icons.more_horiz, 'Khác', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final isCenter = index == 2;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          debugPrint("Current Index: $_currentIndex");
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isCenter ? 42 : null,
            height: isCenter ? 42 : null,
            decoration: isCenter
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.blue : Colors.grey.shade400,
                  )
                : null,
            child: Icon(
              icon,
              color: isCenter
                  ? Colors.white
                  : (isSelected ? Colors.blue : Colors.grey),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.blue : Colors.grey,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}