import 'package:flutter/material.dart';
import 'package:flutter_application_jars/presentation/screens/Jar/UpdateJarPage.dart';

import '../../../controllers/JarController.dart';
import '../../../db/app_state.dart';
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



  void _showJarOptions(BuildContext context, Jar jar) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Thanh nhỏ phía trên (đẹp hơn)
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Sửa tên hũ"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateJarPage(jar: jar),
                    ),
                  ).then((_) {
                    // 🔥 Khi quay lại → reload DB
                    widget.onChanged(); // báo MainPage nếu cần
                  });


                },
              ),

              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  "Xóa hũ",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {

                  if (jar.id != null) {
                    _controller.deleteJar(jar.id!);
                  }

                  Navigator.pop(context);
                  // xử lý xóa
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditNameDialog(Jar jar) {
    TextEditingController controller =
    TextEditingController(text: jar.nameJar);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Sửa tên hũ"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Nhập tên mới",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {


                print(controller.text);
                Navigator.pop(context);
              },
              child: Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[100],

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const JarAddPage(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),

        body: ValueListenableBuilder(
          valueListenable: AppState.jarChanged,
          builder: (context, value, child) {
            return FutureBuilder<List<Jar>>(
              future: _controller.getJar(),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                final jars = snapshot.data!;
                final totalMoney = _controller.calTotalMoney(jars);

                return Column(
                  children: [

                    /// ===== HEADER TRẮNG =====
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 50, 16, 10),
                      child: Column(
                        children: [

                          /// Title + icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              SizedBox(width: 24),
                              Text(
                                "Tài khoản",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.search),
                                  SizedBox(width: 16),
                                  Icon(Icons.tune),
                                ],
                              )
                            ],
                          ),

                          const SizedBox(height: 16),

                          /// TAB BAR
                          const TabBar(
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.black54,
                            indicatorColor: Colors.blue,
                            tabs: [
                              Tab(text: "Tài khoản"),
                              Tab(text: "Sổ tiết kiệm"),
                              Tab(text: "Tích lũy"),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// ===== PHẦN NỀN VÀNG =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFE7B0),
                            Color(0xFFFFD580),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tổng tiền",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "${totalMoney.toStringAsFixed(0)} đ",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// ===== ĐANG SỬ DỤNG =====
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Đang sử dụng (${totalMoney.toStringAsFixed(0)} đ)",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_up),
                        ],
                      ),
                    ),

                    /// ===== LIST =====
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: jars.length,
                        itemBuilder: (context, index) {
                          final jar = jars[index];

                          return Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.blue,
                                  ),
                                ),
                                title: Text(
                                  jar.nameJar,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  "${jar.balance.toStringAsFixed(0)} đ",
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () {
                                    _showJarOptions(context, jar);
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          JarHistoryPage(jarId: jar.id),
                                    ),
                                  );
                                },
                              ),
                              const Divider(height: 1),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
