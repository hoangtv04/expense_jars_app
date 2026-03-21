import 'package:flutter/material.dart';
import 'package:flutter_application_jars/repositories/SyncService.dart';
import 'package:intl/intl.dart'; // Nhớ thêm intl: ^0.19.0 vào pubspec.yaml
import 'package:flutter_application_jars/presentation/screens/Setting/profile.dart';
import 'package:flutter_application_jars/presentation/screens/Report/Report.dart';
import '../Transaction/periodic_transaction_add_page.dart';
import 'SpendingLimt/SpendingLimitPage.dart';
import '../Category/EditCategoryPage.dart';

// Import Service của bạn
// import 'package:flutter_application_jars/services/sync_service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isSyncing = false;
  String _lastSyncTime = "21/03/2026 14:00:32";

  final _controllerJar = SyncService();

  // Hàm xử lý đồng bộ dữ liệu
  Future<void> _handleSync() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);

    try {
      // await SyncService().syncAll();
      await _controllerJar.syncAll();

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _lastSyncTime = DateFormat(
          'dd/MM/yyyy HH:mm:ss',
        ).format(DateTime.now());
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Đồng bộ dữ liệu thành công!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Nền xám nhạt như ảnh mẫu
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// ===== HEADER GRADIENT =====
            _buildHeader(context),

            const SizedBox(height: 16),

            /// ===== TÍNH NĂNG =====
            _buildSectionTitle("Tính năng"),
            _buildGrid(context, "Feature"),

            const SizedBox(height: 20),

            /// ===== TIỆN ÍCH =====
            _buildSectionTitle("Tiện ích"),
            _buildGrid(context, "Utility"),

            const SizedBox(height: 20),

            /// ===== DANH SÁCH CÀI ĐẶT (LIST VIEW STYLE) =====
            _buildListSetting(Icons.settings, "Cài đặt chung"),
            _buildListSetting(Icons.storage, "Cài đặt dữ liệu"),
            _buildListSetting(Icons.reply, "Giới thiệu cho bạn"),
            _buildListSetting(Icons.star, "Bạn thích ứng dụng này?"),
            _buildListSetting(Icons.mail, "Góp ý với nhà phát triển"),
            _buildListSetting(Icons.info, "Trợ giúp & thông tin"),

            const SizedBox(height: 30),

            /// ===== NÚT ĐỒNG BỘ DỮ LIỆU (GIỐNG ẢNH MẪU) =====
            _buildSyncButton(),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Widget Header
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E86DE), Color(0xFF48C9B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profile()),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Text(
                        "DC",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Xin chào!",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          "duc cuong",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.notifications_none, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text(
              "Nâng cấp Vip",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Tiêu đề mục
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget Grid danh mục
  Widget _buildGrid(BuildContext context, String type) {
    final List<Map<String, dynamic>> items = [
      {"label": "Báo cáo", "icon": Icons.bar_chart, "color": Colors.green},
      {
        "label": "Hạn mức chi",
        "icon": Icons.speed,
        "color": Colors.orange,
        "isCustom": true,
      },
      {
        "label": "Hạng mục      chi/tiêu",
        "icon": Icons.eleven_mp,
        "color": Colors.orange,
        "isCustom": true,
      },
      {
        "label": "Xuất dữ liệu",
        "icon": Icons.upload_file,
        "color": Colors.blue,
      },
      {
        "label": "Thu/Chi Định kỳ",
        "icon": Icons.upload_file,
        "color": Colors.blue,
      },
      {"label": "Tiết kiệm", "icon": Icons.savings, "color": Colors.pink},
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            if (item["label"] == "Hạn mức chi") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SpendingLimitPage(),
                ),
              );
            } else if (item["label"] == "Hạng mục      chi/tiêu") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const EditCategoryPage(customTitle: 'Hạng mục thu/chi'),
                ),
              );
            }
            if (item["label"] == "Báo cáo") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportScreen(userId: ''),
                ),
              );
            }

            if (item["label"] == "Thu/Chi Định kỳ") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PeriodicTransactionAddPage(),
                ),
              );
            }
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item["color"].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item["icon"], color: item["color"]),
              ),
              const SizedBox(height: 4),
              Text(
                item["label"],
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget Danh sách cài đặt (Icon xanh bên trái)
  Widget _buildListSetting(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E86DE)),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: () {},
    );
  }

  Widget _buildSyncButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _handleSync,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2E86DE), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF2E86DE),
                          ),
                        )
                      : const Icon(
                          Icons.sync,
                          color: Color(0xFF2E86DE),
                          size: 20,
                        ),
                  const SizedBox(width: 8),
                  Text(
                    _isSyncing ? "Đang đồng bộ..." : "Đồng bộ dữ liệu",
                    style: const TextStyle(
                      color: Color(0xFF2E86DE),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Đồng bộ lần cuối lúc: $_lastSyncTime",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
