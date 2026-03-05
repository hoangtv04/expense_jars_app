import 'package:flutter/material.dart';
import '../../../../controllers/JarController.dart';
import '../../../../models/Jar.dart';

class SelectAccountForLimitPage extends StatefulWidget {
  final String selectedAccount;

  const SelectAccountForLimitPage({super.key, required this.selectedAccount});

  @override
  State<SelectAccountForLimitPage> createState() =>
      _SelectAccountForLimitPageState();
}

class _SelectAccountForLimitPageState extends State<SelectAccountForLimitPage> {
  late TextEditingController _searchController;
  late JarController _jarController;
  List<Jar> _filteredJars = [];
  List<Jar> _allJars = [];
  late Set<String> _selectedJars;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _jarController = JarController();
    _selectedJars = {};
    _loadJars();
  }

  Future<void> _loadJars() async {
    try {
      // Load all jars
      final jars = await _jarController.getJar();

      setState(() {
        _allJars = jars;
        _filteredJars = jars;
      });

      // Mặc định chọn tất cả tài khoản
      setState(() {
        _selectedJars = jars.map((jar) => jar.nameJar ?? '').toSet();
      });
    } catch (e) {
      print('Error loading jars: $e');
    }
  }

  void _filterJars(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredJars = _allJars;
      });
    } else {
      setState(() {
        _filteredJars = _allJars
            .where(
              (jar) => (jar.nameJar ?? '').toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      });
    }
  }

  void _toggleJar(String jarName, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedJars.add(jarName);
      } else {
        _selectedJars.remove(jarName);
      }
    });
  }

  void _selectAll() {
    setState(() {
      final allJarNames = _filteredJars.map((jar) => jar.nameJar ?? '').toSet();

      // Nếu tất cả đều đã được chọn, thì bỏ chọn tất cả
      if (_selectedJars.containsAll(allJarNames) &&
          _selectedJars.length == allJarNames.length) {
        _selectedJars.clear();
      } else {
        // Nếu không, chọn tất cả
        _selectedJars.clear();
        _selectedJars.addAll(allJarNames);
      }
    });
  }

  bool _isAllSelected() {
    final allJarNames = _filteredJars.map((jar) => jar.nameJar ?? '').toSet();

    if (allJarNames.isEmpty) return false;

    return _selectedJars.containsAll(allJarNames) &&
        _selectedJars.length == allJarNames.length;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chọn tài khoản',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE3F2FD),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterJars,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên tài khoản...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Account count and select all
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_allJars.length} tài khoản',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: _selectAll,
                  child: Row(
                    children: [
                      const Text(
                        'Chọn tất cả',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0288D1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isAllSelected()
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: _selectedJars.isEmpty
                            ? Colors.grey[400]
                            : const Color(0xFF0288D1),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Accounts list
          Expanded(
            child: _filteredJars.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy tài khoản',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredJars.length,
                    itemBuilder: (context, index) {
                      final jar = _filteredJars[index];
                      final jarName = jar.nameJar ?? 'Không có tên';
                      final isSelected = _selectedJars.contains(jarName);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            jarName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Số dư: ${jar.balance?.toStringAsFixed(0) ?? '0'} đ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              _toggleJar(jarName, value ?? false);
                            },
                            activeColor: const Color(0xFF0288D1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onTap: () {
                            _toggleJar(jarName, !isSelected);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              final selectedList = _selectedJars.toList();
              Navigator.pop(
                context,
                selectedList.isNotEmpty ? selectedList : ['Tất cả tài khoản'],
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0288D1),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Xác nhận',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
