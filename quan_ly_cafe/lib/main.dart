import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart'; // Thêm import này
import 'screens/admin/admin_home.dart'; // Thêm import này
import 'screens/welcome_screen.dart';
import 'package:quan_ly_cafe/screens/staff/table_map_screen.dart';

void main() {
  runApp(const CafeApp());
}

class CafeApp extends StatelessWidget {
  const CafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản Lý Quán Cafe',
      theme: ThemeData(
        // Chỉnh tông màu xanh Navy chủ đạo theo bản thiết kế image_7578f7.png
        primaryColor: const Color(0xFF1A237E),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
        fontFamily: 'Roboto', // Bạn có thể đổi font nếu đã cài đặt
      ),

      // Màn hình bắt đầu của App
      home: const WelcomeScreen(),

      // Khai báo các Route để dùng Navigator.pushNamed nếu cần
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin_home': (context) => const AdminHomeScreen(),
      },
    );
  }
}
