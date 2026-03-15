import 'package:flutter/material.dart';
import 'package:flutter_application_jars/presentation/screens/Setting/profile.dart';

import 'SpendingLimt/SpendingLimitPage.dart';
import '../Category/EditCategoryPage.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,



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
                      /// Avatar + Name (Click để sang Profile)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Profile(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              child: Text(
                                "DC",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Xin chào!",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "duc cuong",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /// Icons bên phải
                      Row(
                        children: [
                          Stack(
                            children: [
                              Icon(Icons.refresh, color: Theme.of(context).colorScheme.onPrimary),
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
                          Icon(
                            Icons.notifications_none,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ],
                      )
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
                      "Nâng cấp Vip ",
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
                          child: Text(
                            "100 xu",
                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
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
                          child: Text(
                            "Mã: 123456",
                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
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

            const SizedBox(height: 20),

            /// ===== TIỆN ÍCH =====
            _buildSectionTitle("Tiện ích"),
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
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final List<Map<String, dynamic>> items = [
      {"label": "aa", "icon": Icons.star, "color": Colors.blue},
      {"label": "Hạn mức chi", "isCustom": true, "color": const Color(0xFFFFA500)},
      {
        "label": "Hạng mục   chi/tiêu",
        "asset": 'lib/assets/category_icon/57.png',
        "color": const Color(0xFFFFA500)
      },
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
              } else if (item["label"] == "Hạng mục   chi/tiêu") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditCategoryPage(
                      customTitle: 'Hạng mục thu/chi',
                    ),
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
                  child: item.containsKey("asset")
                      ? Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Image.asset(
                            item["asset"],
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        )
                      : isCustomIcon
                          ? _buildHandMoneyIcon()
                          : Icon(item["icon"], color: item["color"]),
                ),
                const SizedBox(height: 8),
                Text(
                  item["label"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
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