import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../controllers/TransactionController.dart';
import '../../../models/Reponse/TransactionWithCategory.dart';
import '../../../models/Category.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final _transactionController = TransactionController();

  // Mặc định xuất dữ liệu trong 30 ngày gần nhất
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;

  // Hàm chọn ngày để người dùng lọc dữ liệu trước khi xuất
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) _startDate = picked; else _endDate = picked;
      });
    }
  }

  Future<void> _generateExcel() async {
    setState(() => _isLoading = true);
    try {
      // 1. Lấy dữ liệu từ Controller (Hàm này phải trả về List)
      // Cường kiểm tra lại tên hàm trong Controller nhé, nên dùng hàm trả về List
      final List<TransactionWithCategory> data =
      await _transactionController.getAllTransactionForExport();

      // 2. Lọc dữ liệu theo khoảng ngày đã chọn
      final filtered = data.where((t) {
        if (t.date == null) return false;
        DateTime date = DateTime.parse(t.date!);
        return date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
            date.isBefore(_endDate.add(const Duration(days: 1)));
      }).toList();

      if (filtered.isEmpty) throw "Không có dữ liệu trong khoảng thời gian này";

      // 3. Khởi tạo Excel
      var excel = Excel.createExcel();
      excel.rename('Sheet1', 'Bao_Cao_Chi_Tieu');
      Sheet sheet = excel['Bao_Cao_Chi_Tieu'];

      // Header chuẩn CellValue cho bản Excel 4.0+
      List<CellValue> headers = [
        TextCellValue("NGÀY"),
        TextCellValue("HẠNG MỤC"),
        TextCellValue("LOẠI"),
        TextCellValue("SỐ TIỀN"),
        TextCellValue("GHI CHÚ")
      ];
      sheet.appendRow(headers);

      // 4. Đổ dữ liệu
      for (var item in filtered) {
        String dateStr = item.date != null
            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(item.date!))
            : "N/A";

        String categoryName = item.categoryName ?? "Không tên";
        String noteStr = item.note ?? "";

        // Kiểm tra enum hoặc String để hiển thị loại
        String typeStr = (item.type == CategoryType.income || item.type.toString().contains("income"))
            ? "Thu nhập"
            : "Chi tiêu";

        sheet.appendRow([
          TextCellValue(dateStr),
          TextCellValue(categoryName),
          TextCellValue(typeStr),
          DoubleCellValue(item.amount.toDouble()), // Ép kiểu double cho chắc chắn
          TextCellValue(noteStr),
        ]);
      }

      // 5. Lưu và chia sẻ file
      var fileBytes = excel.save();
      final directory = await getTemporaryDirectory();
      final fileName = "BaoCao_TaiChinh_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      final path = "${directory.path}/$fileName";

      final file = File(path);
      await file.writeAsBytes(fileBytes!);

      if (await file.exists()) {
        await Share.shareXFiles(
            [XFile(path)],
            text: 'Báo cáo tài chính từ ứng dụng của Cường'
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xuất dữ liệu Excel"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.table_view_rounded, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              "Tùy chọn xuất báo cáo",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Widget chọn khoảng ngày
            Row(
              children: [
                Expanded(
                  child: _buildDateTile("Từ ngày", _startDate, () => _selectDate(context, true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateTile("Đến ngày", _endDate, () => _selectDate(context, false)),
                ),
              ],
            ),

            const Spacer(),

            // Nút bấm xuất file
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateExcel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.file_download_outlined),
                label: Text(
                  _isLoading ? "ĐANG XỬ LÝ..." : "XUẤT FILE EXCEL",
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text("File sẽ được lưu vào thư mục tạm và sẵn sàng chia sẻ",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // Widget phụ để hiển thị ô chọn ngày cho đẹp
  Widget _buildDateTile(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(DateFormat('dd/MM/yyyy').format(date),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}