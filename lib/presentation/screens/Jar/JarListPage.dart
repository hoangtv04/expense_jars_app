import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../controllers/JarController.dart';
import '../../../models/Jar.dart';
import 'JarAddPage.dart';

class JarListPage extends StatefulWidget {
  const JarListPage({super.key});

  @override
  State<JarListPage> createState() => _JarListPageState();
}

class _JarListPageState extends State<JarListPage> {
  final _controller = JarController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hũ của bạn')),
      body: FutureBuilder<List<Jar>>(
        future: _controller.getJar(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          final jars = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // ===== HEADER =====
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tổng số tiền ###',
                        style: TextStyle(
                          fontSize: 22,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ),
              ),

              // ===== BUTTON =====
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const JarAddPage()),
                      );

                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm hũ mới'),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ===== LIST =====
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final jar = jars[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text(
                        jar.name.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${jar.balance.toStringAsFixed(0)} đ'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // mở chi tiết
                      },
                    ),
                  );
                }, childCount: jars.length),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }
}
