import 'package:flutter/foundation.dart';

class ApiConstants {
  // Hàm này sẽ tự động trả về đúng Base URL tùy theo môi trường đang chạy
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api"; // Cho Web
    } else {
      return "http://10.0.2.2:8000/api"; // ✨ ĐÃ SỬA: Địa chỉ IP chuẩn của máy ảo Android để kết nối với Laravel Backend
    }
  }
}