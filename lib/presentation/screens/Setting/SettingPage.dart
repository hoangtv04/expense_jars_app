import 'package:flutter/material.dart';
import 'SpendingLimt/SpendingLimitPage.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// ===== HEADER XANH =====
            Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Avatar + Name
                      Row(
                        children: [
                          CircleAvatar(
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
                            children: const [
                              Text(
                                "Xin chào!",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "duc cuong",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      /// Icons bên phải
                      Row(
                        children: [
                          Stack(
                            children: [
                              const Icon(Icons.refresh, color: Colors.white),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    "3",
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                          ),
                        ],
                      ),
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
                      "long ăn shit ",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "100 xu",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Mã: 123456",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ===== TÍNH NĂNG =====
            _buildSectionTitle("Tính năng"),
            _buildGrid(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final List<Map<String, dynamic>> items = [
      {"label": "aa", "icon": Icons.star, "color": Colors.blue},
      {
        "label": "Hạn mức chi",
        "isCustom": true,
        "color": const Color(0xFFFFA500),
      },
      {"label": "cc", "icon": Icons.star, "color": Colors.blue},
      {"label": "dd", "icon": Icons.star, "color": Colors.blue},
      {"label": "ee", "icon": Icons.star, "color": Colors.blue},
      {"label": "ff", "icon": Icons.star, "color": Colors.blue},
      {"label": "gg", "icon": Icons.star, "color": Colors.blue},
      {"label": "hh", "icon": Icons.star, "color": Colors.blue},
      {"label": "ii", "icon": Icons.star, "color": Colors.blue},
      {"label": "jj", "icon": Icons.star, "color": Colors.blue},
      {"label": "kk", "icon": Icons.star, "color": Colors.blue},
      {"label": "ll", "icon": Icons.star, "color": Colors.blue},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 20,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final isCustomIcon = item["isCustom"] == true;

          return GestureDetector(
            onTap: () {
              if (item["label"] == "Hạn mức chi") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SpendingLimitPage(),
                  ),
                );
              }
            },
            child: Column(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: item["color"].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: isCustomIcon
                      ? _buildHandMoneyIcon()
                      : Icon(item["icon"], color: item["color"]),
                ),
                const SizedBox(height: 8),
                Text(
                  item["label"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHandMoneyIcon() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Image.asset(
        'lib/assets/income.png',
        width: 40,
        height: 40,
        fit: BoxFit.contain,
      ),
    );
  }
}
