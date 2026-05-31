import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      // Dành cho trình duyệt Web
      return "http://127.0.0.1:8000/api";
    } else {
      // Dành cho máy ảo Android
      return "http://10.0.2.2:8000/api";
    }
  }
}
