import 'package:flutter/material.dart';
import 'package:flutter_application_jars/presentation/screens/login.dart';
import 'package:flutter_application_jars/presentation/screens/Setting/EditProfile.dart';
import 'package:flutter_application_jars/services/session_services.dart';
import 'package:flutter_application_jars/repositories/user_repository.dart';
import 'package:flutter_application_jars/models/user.dart';
import 'package:flutter_application_jars/presentation/screens/Setting/ChangePassword.dart';
import 'package:flutter_application_jars/controllers/user_controller.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = "Đăng nhập";
  String email = "Đăng nhập";
  bool isLoggedIn = false;

  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final userId = await SessionService.getUserId();

    if (!mounted) return;

    if (userId == null) {
      setState(() {
        name = "Đăng nhập";
        email = "Đăng nhập";
        isLoggedIn = false;
      });
      return;
    }

    final repo = UserRepository();
    final User? user = await repo.getUserById(userId);

    if (!mounted) return;

    if (user != null) {
      setState(() {
        email = user.email;
        name = _userController.getDisplayName(user); // 🔥 gọi controller
        isLoggedIn = true;
      });
    } else {
      setState(() {
        name = "Đăng nhập";
        email = "Đăng nhập";
        isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.more_horiz, color: Colors.black),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          GestureDetector(
            onTap: () {
              if (!isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ).then((result) {
                  if (result == true) {
                    loadUser();
                  }
                });
              }
            },
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blue,
                    child: Text(
                      (name != "Đăng nhập" && name.isNotEmpty)
                          ? name[0].toUpperCase()
                          : "?",
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// CẬP NHẬT HỒ SƠ
          GestureDetector(
            onTap: () {
              if (!isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ).then((result) {
                  if (result == true) loadUser();
                });
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfile()),
              ).then((result) {
                if (result == true) {
                  loadUser();
                }
              });
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

          /// MENU
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _ProfileItem(
                  title: "Đặt mật khẩu",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangePassword()),
                    );
                  },
                ),
                const Divider(height: 1),

                if (isLoggedIn) _LogoutItem(),
              ],
            ),
          ),
        ],
      ),

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
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "Khác"),
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
      onTap: () async {
        await SessionService.logout();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
    );
  }
}
