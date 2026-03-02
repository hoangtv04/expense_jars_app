import 'package:flutter/material.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool isFacebookLinked = false;
  bool isGoogleLinked = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Liên kết tài khoản",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Column(
        children: [
          /// FACEBOOK
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xff1877F2),
                  child: Icon(Icons.facebook, color: Colors.white),
                ),
                const SizedBox(width: 16),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Facebook",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Chưa liên kết",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                Switch(
                  value: isFacebookLinked,
                  onChanged: (value) {
                    setState(() {
                      isFacebookLinked = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          /// GOOGLE
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.red,
                  child: Text(
                    "G",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Google",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "duc_cuong@gmail.com",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                Switch(
                  activeColor: Colors.white,
                  activeTrackColor: Colors.blue,
                  value: isGoogleLinked,
                  onChanged: (value) {
                    setState(() {
                      isGoogleLinked = value;
                    });
                  },
                ),
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
            label: "Báo cáo",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Khác"),
        ],
      ),
    );
  }
}
