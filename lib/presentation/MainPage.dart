




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
      CategoryListPage(),
      TransactionListPage(onChanged: refresh)
    ];
  }
  void refresh() {
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeroMode(
        enabled: false,
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Hũ tiền',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Hạng mục',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Khác',
          ),
        ],
      ),
    );
  }
}