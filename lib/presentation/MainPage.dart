




import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_jars/presentation/screens/Jar/JarListPage.dart';
import 'package:flutter_application_jars/presentation/screens/Jar/JarLogPage.dart';
import 'package:flutter_application_jars/presentation/screens/Transaction/transaction_list_page.dart';
import 'package:flutter_application_jars/presentation/screens/home.dart';
import 'package:flutter_application_jars/presentation/screens/Category/CategoryListPage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      home(onChanged: refresh),
      JarListPage(onChanged: refresh),
      TransactionListPage(onChanged: refresh),
      Container(), // Placeholder for CategoryListPage - will be navigated separately
      Container(color: Colors.purple) // Placeholder for "Khác"
    ];
  }
  void refresh() {
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Jars'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload dữ liệu',
            onPressed: refresh,
          ),
        ],
      ),
      body: HeroMode(
        enabled: false,
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 8, bottom: 8),
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
    bool isSelected = _currentIndex == index;
    bool isCenter = index == 2; // "Ghi chép" button
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isCenter ? 40 : null,
              height: isCenter ? 40 : null,
              decoration: isCenter
                  ? BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Icon(
                icon,
                size: 24,
                color: isCenter
                    ? (isSelected ? Colors.white : Colors.grey.shade700)
                    : (isSelected ? Colors.blue : Colors.grey),
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.blue : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}