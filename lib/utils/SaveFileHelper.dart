import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class SaveFileHelper {
  static Future<void> saveAndOpenFile(List<int> bytes) async {
    // 1. Lấy đường dẫn thư mục lưu trữ của ứng dụng trên điện thoại
    Directory? directory = await getExternalStorageDirectory();

    // Nếu là iOS hoặc không tìm thấy thư mục ngoài, dùng thư mục tài liệu ứng dụng
    directory ??= await getApplicationDocumentsDirectory();

    String path = directory.path;
    String fileName = 'Invoice_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    File file = File('$path/$fileName');

    // 2. Ghi mảng bytes vào file vật lý
    await file.writeAsBytes(bytes, flush: true);

    // 3. Mở file bằng ứng dụng đọc Excel có sẵn trên máy (như Google Sheets, Excel...)
    await OpenFilex.open('$path/$fileName');
  }
}