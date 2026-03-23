import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/session_services.dart';
import '../../../repositories/user_repository.dart';
import '../../../repositories/SyncService.dart';
import '../Transaction/periodic_transaction_add_page.dart';
import '../Report/Report.dart';
import '../Category/EditCategoryPage.dart';
import '../Setting/ExportPage.dart';
import '../Setting/SpendingLimt/SpendingLimitPage.dart';
import '../Setting/SpendingLimt/Information.dart';
import '../Setting/Feedback.dart' as CustomFeedback;
import '../Setting/profile.dart';
import '../Setting/Feedback.dart' as Feedback;
import 'SendingStar.dart';
// Import Service của bạn
// import 'package:flutter_application_jars/services/sync_service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isSyncing = false;
  String _lastSyncTime = "Chưa đồng bộ";
  String name = "Người dùng";
  final _syncService = SyncService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Format tên từ email nếu fullName trống
  String _formatName(String raw) {
    return raw
        .replaceAll(RegExp(r'[0-9]'), '')
        .replaceAll(RegExp(r'[._]'), ' ')
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() + e.substring(1) : '')
        .join(' ');
  }

  Future<void> _loadUser() async {
    final userId = await SessionService.getUserId();
    if (userId == null) return;

    final user = await UserRepository().getUserById(userId);
    if (!mounted) return;

    if (user != null) {
      setState(() {
        name = (user.fullName != null && user.fullName!.isNotEmpty)
            ? user.fullName!
            : _formatName(user.email.split('@')[0]);
      });
    }
  }

  Future<void> _handleSync() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);

    try {
      await _syncService.syncAll();
      await Future.delayed(const Duration(seconds: 1)); // Delay nhẹ cho mượt
      setState(() {
        _lastSyncTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Đồng bộ thành công!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Lỗi đồng bộ: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// ===== HEADER GRADIENT =====
            _buildHeader(context),

            const SizedBox(height: 16),

            /// ===== TÍNH NĂNG =====
            _buildSectionTitle("Tính năng"),
            _buildGrid(context, "Feature"),
            const SizedBox(height: 16),
            _buildSectionTitle("Tiện ích"),
            _buildGrid(context, "Utility"),

            const SizedBox(height: 20),

            /// ===== DANH SÁCH CÀI ĐẶT (LIST VIEW STYLE) =====
            _buildListSetting(Icons.settings, "Cài đặt chung"),
            _buildListSetting(Icons.storage, "Cài đặt dữ liệu"),
            _buildListSetting(Icons.reply, "Giới thiệu cho bạn"),
            _buildListSetting(Icons.star, "Bạn thích ứng dụng này?"),
            _buildListSetting(Icons.mail, "Góp ý với nhà phát triển"),
            _buildListSetting(Icons.info, "Thông tin"),

            const SizedBox(height: 30),

            /// ===== NÚT ĐỒNG BỘ DỮ LIỆU (GIỐNG ẢNH MẪU) =====
            _buildSyncButton(),
            const SizedBox(height: 40),
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
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Profile())).then((_) => _loadUser()),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Xin chào!", style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.notifications_none, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          _buildVipBanner(),
        ],
      ),
    );
  }

  Widget _buildVipBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      child: const Text("Nâng cấp Vip", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  // Widget Tiêu đề mục
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, String type) {
    final List<Map<String, dynamic>> items = type == "Feature" ? [
      {"label": "Báo cáo", "icon": Icons.bar_chart, "color": Colors.green, "asset": "lib/assets/report.png", "page": ReportScreen()},
            {"label": "Hạn mức chi", "icon": Icons.speed, "color": Colors.orange, "asset": "lib/assets/income.png", "page": const SpendingLimitPage()},
            {"label": "Hạng mục", "icon": Icons.category, "color": Colors.blueAccent, "asset": "lib/assets/price-list.png", "page": const EditCategoryPage(customTitle: 'Hạng mục thu/chi')},
            {"label": "Xuất Excel", "icon": Icons.description, "color": Colors.blue, "asset": "lib/assets/export.png", "page": const ExportPage()},
    ] : [
            {"label": "Định kỳ", "icon": Icons.update, "color": Colors.purple, "asset": "lib/assets/schedule.png", "page": const PeriodicTransactionAddPage()},
            {"label": "Tiết kiệm", "icon": Icons.savings, "color": Colors.pink, "asset": "lib/assets/piggy-bank.png", "page": null},
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () {
            if (item["page"] != null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => item["page"]));
            }
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: item["color"].withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: item.containsKey('asset') && item['asset'] != null
                    ? Image.asset(
                        item['asset'],
                        width: 44,
                        height: 44,
                        fit: BoxFit.contain,
                      )
                    : Icon(item["icon"], color: item["color"]),
              ),
              const SizedBox(height: 6),
              Text(item["label"], style: const TextStyle(fontSize: 11), textAlign: TextAlign.center, maxLines: 1),
            ],
          ),
        );
      },
    );
  }

  // Widget Danh sách cài đặt (Icon xanh bên trái)
  Widget _buildListSetting(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E86DE), size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      onTap: () {
        if(title == "Thông tin"){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Information(),
            ),
          );
        }
        if(title == "Góp ý với nhà phát triển"){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Feedback.Feedback(),
            ),
          );
        }
        if (title == "Bạn thích ứng dụng này?") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SendingStar(),
            ),
          );
        }
      },
    );
  }

  Widget _buildSyncButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _handleSync,
              icon: _isSyncing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync, size: 20),
              label: Text(_isSyncing ? "ĐANG ĐỒNG BỘ..." : "ĐỒNG BỘ DỮ LIỆU"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E86DE),
                side: const BorderSide(color: Color(0xFF2E86DE)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text("Lần cuối: $_lastSyncTime", style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
