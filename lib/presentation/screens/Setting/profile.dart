import 'package:flutter/material.dart';
import 'package:flutter_application_jars/presentation/screens/login.dart';
import 'package:flutter_application_jars/presentation/screens/Setting/account.dart';
import 'package:flutter_application_jars/presentation/screens/Setting/EditProfile.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.qr_code, color: Colors.black),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.blue,
                  child: Text(
                    "DC",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "duc cuong",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "chuoidocchoduoi7c@gmail.com",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// CẬP NHẬT HỒ SƠ
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfile()),
              );
            },
            child: Container(
              width: double.infinity,
              color: Colors.orange[100],
              padding: const EdgeInsets.all(16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cập nhật hồ sơ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Hoàn thiện hồ sơ của bạn để bảo vệ tài khoản và trải nghiệm tốt hơn",
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// DANH SÁCH
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _ProfileItem(
                  title: "Liên kết tài khoản",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Account()),
                    );
                  },
                ),

                const Divider(height: 1),

                _ProfileItem(
                  title: "Đặt mật khẩu",
                  onTap: () {
                    // TODO: thêm màn đổi mật khẩu sau
                  },
                ),

                const Divider(height: 1),

                _LogoutItem(),
              ],
            ),
          ),
        ],
      ),

      /// 👇 Bottom Navigation thêm trực tiếp tại đây
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Hũ tiền",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40),
            label: "Ghi chép",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Thống kê",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Khác"),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _ProfileItem({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class _LogoutItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      },
    );
  }
}
