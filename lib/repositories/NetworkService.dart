import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static Future<bool> isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    // Nếu kết nối là mobile (4G/5G) hoặc wifi thì trả về true
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet)) {
      return true;
    }

    return false; // Không có mạng (none)
  }
}