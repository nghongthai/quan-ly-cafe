import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'register_screen.dart';
import 'admin/admin_home.dart';
import 'order_list_screen.dart';
import 'staff_room_screen.dart'; // 🌟 Đã sửa: Import đúng file sơ đồ bàn mới của nhân viên

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  Future<void> _handleLogin() async {
    const String apiUrl = "http://10.0.2.2:8000/api/login";

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Vui lòng nhập đầy đủ thông tin");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'email': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        String role = data['data']['role']?.toString().toLowerCase() ?? 'nhân viên';

        _showSnackBar("Đăng nhập thành công!");

        if (role == 'admin' || role == 'quản lý' || role == 'quan ly') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
                (route) => false,
          );
        } else {
          // 🌟 ĐÃ SỬA TẠI ĐÂY: Bóc tách id và name từ API để truyền sang StaffRoomScreen
          int userId = int.tryParse(data['data']['id'].toString()) ?? 0;
          String staffName = data['data']['name'] ?? "Nhân viên phục vụ";

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => StaffRoomScreen(
                userId: userId,
                staffName: staffName,
              ),
            ),
                (route) => false,
          );
        }
      } else {
        _showSnackBar(data['message'] ?? "Tài khoản hoặc mật khẩu không đúng");
      }
    } catch (e) {
      _showSnackBar("Không thể kết nối đến máy chủ: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8EAF6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront, size: 80, color: Color(0xFF1A237E)),
              ),
              const SizedBox(height: 20),
              const Text(
                "Chào Mừng Trở Lại",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
              ),
              const SizedBox(height: 5),
              const Text("Đăng nhập để tiếp tục quản lý quán cafe của bạn", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              _buildTextField(_usernameController, "Tài khoản (Email)", Icons.person),
              const SizedBox(height: 15),
              _buildTextField(_passwordController, "Mật khẩu", Icons.lock, isPassword: true),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF1A237E),
                      ),
                      const Text("Ghi nhớ tôi"),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Quên mật khẩu?", style: TextStyle(color: Color(0xFF1A237E))),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Đăng Nhập", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("Hoặc đăng nhập với", style: TextStyle(color: Colors.grey))),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon(Icons.g_mobiledata),
                  const SizedBox(width: 20),
                  _socialIcon(Icons.facebook),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Bạn chưa có tài khoản? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    },
                    child: const Text(
                      "Đăng kí",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _socialIcon(IconData backupIcon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(backupIcon, size: 30, color: const Color(0xFF1A237E)),
    );
  }
}