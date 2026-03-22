import 'package:flutter/material.dart';

class Information extends StatelessWidget {
  const Information({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF2E86DE),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color.fromARGB(255, 1, 49, 131),
                alignment: Alignment.center,
                child: const Text(
                  'MoneyJar',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),
              ),
              title: const Text(
                'Ứng Dụng quản lý chi tiêu',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              centerTitle: true,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Ứng dụng giúp bạn theo dõi chi tiêu, quản lý ngân sách và tiết kiệm hiệu quả.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Các tính năng chính:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text('- Báo cáo chi tiêu trực quan'),
                  Text('- Hạn mức chi tiêu'),
                  Text('- Xuất dữ liệu'),
                  Text('- Theo dõi tiết kiệm'),
                  Text('- Nhắc nhở thanh toán'),
                  Text('- Hỗ trợ đa nền tảng'),
                  Text('- Thống kê chi tiêu '),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ===== Mục liên hệ / hỗ trợ ở cuối trang =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Divider(thickness: 5.0, color: Colors.lightGreen),
                  SizedBox(height: 10),
                  Text(
                    'Mọi thắc mắc hoặc góp ý vui lòng liên hệ:',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal, color: Colors.amber),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '📧 Email: support@moneyjar.app',
                    style: TextStyle(fontSize: 14, color: Colors.teal),
                  ),
                  Text(
                    '🌐 Website: www.moneyjar.app',
                    style: TextStyle(fontSize: 14, color: Colors.teal),
                  ),
                  Text(
                    '📞 Hotline: 1800-1234',
                    style: TextStyle(fontSize: 14, color: Colors.teal),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
