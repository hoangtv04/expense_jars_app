import 'package:flutter/material.dart';
import '../../../models/Category.dart';
import '../../../repositories/CategoryRepository.dart';
import 'CategoryListPage.dart';

class TransferCategoryPage extends StatefulWidget {
  final CategoryType type;

  const TransferCategoryPage({super.key, required this.type});

  @override
  State<TransferCategoryPage> createState() => _TransferCategoryPageState();
}

class _TransferCategoryPageState extends State<TransferCategoryPage>
    with SingleTickerProviderStateMixin {
  final CategoryRepository _cateRepo = CategoryRepository();

  Category? _fromCategory;
  Category? _toCategory;
  bool _deleteAfter = false;
  bool _isProcessing = false;

  Future<void> _performTransfer() async {
    if (_fromCategory == null || _toCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hạng mục nguồn và đích')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final count = await _cateRepo.transferTransactions(_fromCategory!.id!, _toCategory!.id!);
      if (_deleteAfter) {
        await _cateRepo.deleteCategory(_fromCategory!.id!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã chuyển $count giao dịch')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Widget _buildSelector(String title, Category? cat, bool isFrom) {
    return ListTile(
      title: Text(title),
      subtitle: Text(cat?.name ?? 'Chọn hạng mục'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const _CategorySelectorWrapper()),
        );
        if (result != null && result is Category) {
          setState(() {
            if (isFrom) _fromCategory = result;
            else _toCategory = result;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chuyển hạng mục chi'),
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _buildSelector('Từ hạng mục', _fromCategory, true),
                const Divider(),
                Row(
                  children: [
                    Checkbox(
                      value: _deleteAfter,
                      onChanged: (v) => setState(() => _deleteAfter = v ?? false),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Xóa hạng mục sau khi chuyển')),
                  ],
                ),
                const Divider(),
                _buildSelector('Sang hạng mục', _toCategory, false),
              ],
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
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _performTransfer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Lưu lại',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Simple wrapper to reuse existing CategoryListPage in selection mode.
class _CategorySelectorWrapper extends StatelessWidget {
  const _CategorySelectorWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CategoryListPage(isSelectionMode: true, customTitle: 'Chọn hạng mục');
  }
}
