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

  /// ===== 1. DIALOG NẠP/RÚT TIẾT KIỆM (Tối giản) =====
  void _showSavingActionDialog(BuildContext context, Saving saving, bool isDeposit) {
    final TextEditingController amountController = TextEditingController();
    String? selectedJarId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isDeposit ? "Gửi thêm" : "Rút tiền"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Số tiền (đ)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Jar>>(
              future: _jarController.getJar(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                final jars = snapshot.data!;
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Chọn hũ trích/nhận", border: OutlineInputBorder()),
                  items: jars.map((j) => DropdownMenuItem(value: j.id, child: Text(j.nameJar))).toList(),
                  onChanged: (val) => selectedJarId = val,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (amountController.text.isEmpty || selectedJarId == null) return;
              try {
                if (isDeposit) {
                  await _savingController.depositToSaving(
                    savingId: saving.id!,
                    amount: double.parse(amountController.text),
                    fromJarId: selectedJarId!,
                  );
                } else {

                  await _savingController.withdrawFromSaving(
                    savingId: saving.id!,
                    amount: double.parse(amountController.text),
                    toJarId: selectedJarId!,
                  );


                }
                if (context.mounted) Navigator.pop(context);
                AppState.jarChanged.value++;
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
              }
            },
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }

  /// ===== 2. OPTIONS CHO CẢ HŨ VÀ SỔ (SỬA/XÓA) =====
  void _showOptions(BuildContext context, {Jar? jar, Saving? saving}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (jar != null) ...[
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text("Sửa tên hũ"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => UpdateJarPage(jar: jar)));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Xóa hũ", style: TextStyle(color: Colors.red)),
                  onTap: () {
                    _jarController.deleteJar(jar.id!);
                    Navigator.pop(context);
                  },
                ),
              ],
              if (saving != null) ...[
                ListTile(
                  leading: const Icon(Icons.add_circle_outline, color: Colors.green),
                  title: const Text("Gửi thêm tiền"),
                  onTap: () {
                    Navigator.pop(context);
                    _showSavingActionDialog(context, saving, true);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                  title: const Text("Rút tiền"),
                  onTap: () {
                    Navigator.pop(context);
                    _showSavingActionDialog(context, saving, false);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Xóa sổ", style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteSaving(context, saving);
                  },
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  /// ===== 3. UI ITEM TỐI GIẢN (Dùng chung style ListTile) =====
  Widget _buildSimpleItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    required VoidCallback onMore,
  }) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle),
          trailing: IconButton(icon: const Icon(Icons.more_vert), onPressed: onMore),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  void _confirmDeleteSaving(BuildContext context, Saving saving) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Xóa sổ '${saving.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              await _savingController.deleteSaving(saving.id!);
              if (context.mounted) Navigator.pop(context);
              AppState.jarChanged.value++;
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JarAddPage())),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: ValueListenableBuilder(
          valueListenable: AppState.jarChanged,
          builder: (context, value, child) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                  child: Column(
                    children: [
                      const Text("Tài khoản", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      const TabBar(
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.black54,
                        indicatorColor: Colors.blue,
                        tabs: [Tab(text: "Hũ tiền"), Tab(text: "Sổ tiết kiệm"), Tab(text: "Tích lũy")],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab 1: Hũ tiền
                      FutureBuilder<List<Jar>>(
                        future: _jarController.getJar(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final jar = snapshot.data![index];
                              return _buildSimpleItem(
                                title: jar.nameJar,
                                subtitle: "${jar.balance.toStringAsFixed(0)} đ",
                                icon: Icons.account_balance_wallet,
                                iconColor: Colors.blue,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JarHistoryPage(jarId: jar.id))),
                                onMore: () => _showOptions(context, jar: jar),
                              );
                            },
                          );
                        },
                      ),
                      // Tab 2: Sổ tiết kiệm
                      FutureBuilder<List<Saving>>(
                        future: _savingController.getSaving(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          if (snapshot.data!.isEmpty) return const Center(child: Text("Chưa có sổ tiết kiệm"));
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final sv = snapshot.data![index];
                              return _buildSimpleItem(
                                title: sv.name,
                                subtitle: "Số dư: ${sv.principal.toStringAsFixed(0)} đ",
                                icon: Icons.savings,
                                iconColor: Colors.orange,
                                onTap: () {}, // Có thể mở trang chi tiết sổ nếu muốn
                                onMore: () => _showOptions(context, saving: sv),
                              );
                            },
                          );
                        },
                      ),
                      // Tab 3: Tích lũy (Đang phát triển)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.construction, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text("Tính năng đang phát triển", style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
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