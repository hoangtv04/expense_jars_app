import 'package:flutter/material.dart';
import 'package:flutter_application_jars/controllers/CategoryController.dart';
import 'package:flutter_application_jars/controllers/JarController.dart';
import 'package:flutter_application_jars/presentation/screens/login.dart';

import '../../models/Category.dart';




class home extends StatefulWidget {

  final VoidCallback onChanged;
  const home({
    super.key,
    required this.onChanged,
  });
  @override
  State<home> createState() => _homeState();
}



class _homeState extends State<home> {
  final _controller = JarController();

final _controllerCategory = CategoryController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý chi tiêu'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

          FutureBuilder<double>(
            future: _controller.calTotalMoney2(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text('...');
              }

              double? money = snapshot.data;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng số dư',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${money} ₫',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
            const SizedBox(height: 24),

            // ===== TIÊU ĐỀ =====
            const Text(
              'Các hũ chi tiêu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            FutureBuilder(future: _controllerCategory.getAllCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text('...');
                }

                List<Category> c  =snapshot.data!;
              return  GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: c.map((category) {
                    return _JarItem(
                      title: category.name,
                      amount: '0 ₫',
                      icon: Icons.category,
                      color: Colors.blue,
                    );

                  }).toList()
                );

            },)




          ],
        ),
      ),

      // ===== FLOAT BUTTON =====
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Đăng xuất'),
      content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const LoginScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

// ================= WIDGET HŨ =================
class _JarItem extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const _JarItem({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
