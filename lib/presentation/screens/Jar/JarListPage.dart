import 'package:flutter/material.dart';

import '../../../controllers/JarController.dart';
import '../../../controllers/SavingController.dart';
import '../../../db/app_state.dart';

import '../../../models/Jar.dart';
import '../../../models/Saving.dart';

import 'JarAddPage.dart';
import 'JarHistoryPage.dart';
import 'SavingAddPage.dart';
import 'UpdateJarPage.dart';

class JarListPage extends StatefulWidget {
  final VoidCallback onChanged;

  const JarListPage({super.key, required this.onChanged});

  @override
  State<JarListPage> createState() => _JarListPageState();
}

class _JarListPageState extends State<JarListPage> {
  final _jarController = JarController();
  final _savingController = SavingController();

  /// ===== BottomSheet Jar =====
  void _showJarOptions(BuildContext context, Jar jar) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

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
                leading: const Icon(Icons.edit),
                title: const Text("Sửa tên hũ"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateJarPage(jar: jar),
                    ),
                  ).then((_) {
                    widget.onChanged();
                  });
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "Xóa hũ",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  if (jar.id != null) {
                    _jarController.deleteJar(jar.id!);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// ===== UI Saving Item =====
  Widget savingItem(Saving saving) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.savings,
              color: Colors.orange,
            ),
          ),
          title: Text(
            saving.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            "${saving.principal.toStringAsFixed(0)} đ",
          ),
          trailing: Text(
            "${saving.interestRate ?? 0}%",
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  /// ===== UI Jar Item =====
  Widget jarItem(Jar jar) {
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
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text("${jar.balance.toStringAsFixed(0)} đ"),
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
                builder: (_) => JarHistoryPage(jarId: jar.id),
              ),
            );
          },
        ),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[100],

        /// ===== FAB =====
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JarAddPage()),
            );
          },
          child: const Icon(Icons.add),
        ),

        body: ValueListenableBuilder(
          valueListenable: AppState.jarChanged,
          builder: (context, value, child) {
            return Column(
              children: [

                /// ===== HEADER =====
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 10),
                  child: Column(
                    children: [

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

                /// ===== BODY =====
                Expanded(
                  child: TabBarView(
                    children: [

                      /// ===== TAB 1 JAR =====
                      FutureBuilder<List<Jar>>(
                        future: _jarController.getJar(),
                        builder: (context, snapshot) {

                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final jars = snapshot.data!;

                          return ListView.builder(
                            itemCount: jars.length,
                            itemBuilder: (context, index) {
                              return jarItem(jars[index]);
                            },
                          );
                        },
                      ),

                      /// ===== TAB 2 SAVING =====
                      Column(
                        children: [

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SavingAddPage(),
                                  ),
                                );
                              },
                              child: const Text("Thêm sổ tiết kiệm"),
                            ),
                          ),

                          Expanded(
                            child: FutureBuilder<List<Saving>>(
                              future: _savingController.getSaving(),
                              builder: (context, snapshot) {

                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final savings = snapshot.data!;

                                if (savings.isEmpty) {
                                  return const Center(
                                    child: Text("Chưa có sổ tiết kiệm"),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: savings.length,
                                  itemBuilder: (context, index) {
                                    return savingItem(savings[index]);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      /// ===== TAB 3 =====
                      const Center(
                        child: Text("Danh sách mục tiêu tích lũy"),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}