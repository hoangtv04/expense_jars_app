import 'package:flutter/material.dart';

import '../../../controllers/JarController.dart';
import '../../../models/Jar.dart';
import 'JarAddPage.dart';
import 'JarHistoryPage.dart';







class JarListPage extends StatefulWidget {
  final VoidCallback onChanged;

  const JarListPage({
    super.key,
    required this.onChanged,
  });

  @override
  State<JarListPage> createState() => _JarListPageState();
}

class _JarListPageState extends State<JarListPage> {
  final _controller = JarController();

  // 🔹 Lưu Future để FutureBuilder theo dõi
  late Future<List<Jar>> _futureJars;

  @override
  void initState() {
    super.initState();
    // 🔹 Chỉ gọi DB 1 lần khi page được tạo
    _futureJars = _controller.getJar();
  }

  // 🔹 Reload dữ liệu khi có thay đổi
  void _reload() {
    setState(() {
      _futureJars = _controller.getJar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hũ của bạn')),
      body: FutureBuilder<List<Jar>>(
        future: _futureJars,
        builder: (context, snapshot) {
          // ⏳ Đang load
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Không có dữ liệu
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Không có dữ liệu'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const JarAddPage(),
                        ),
                      ).then((_) {
                        // 🔥 Khi quay lại → reload DB
                        _reload();
                        widget.onChanged(); // báo MainPage nếu cần
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm hũ mới'),
                  ),
                ],
              ),
            );
          }

          // ✅ Có dữ liệu
          final jars = snapshot.data!;
          final totalMoney = _controller.calTotalMoney(jars);

          return CustomScrollView(
            slivers: [
              // ===== TỔNG TIỀN =====
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Tổng số tiền ${totalMoney.toStringAsFixed(0)} đ',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // ===== NÚT THÊM =====
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const JarAddPage(),
                        ),
                      ).then((_) {
                        _reload(); // 🔥 reload sau khi thêm
                        widget.onChanged();
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm hũ mới'),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ===== DANH SÁCH HŨ =====
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final jar = jars[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.account_balance_wallet),
                        title: Text(
                          jar.name.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                        Text('${jar.balance.toStringAsFixed(0)} đ'),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JarHistoryPage(jarId: jar.id),
                            ),
                          );
                        },

                      )
                    );
                  },
                  childCount: jars.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }
}
