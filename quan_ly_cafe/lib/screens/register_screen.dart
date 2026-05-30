import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:quan_ly_cafe/screens/api_constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Cần thêm Controller cho Họ tên (Name) vì Login chỉ có username/pass
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final String apiUrl = "${ApiConstants.baseUrl}/register";
    if (_nameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar("Vui lòng điền đầy đủ thông tin");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Accept": "application/json"},
        body: {
          'name': _nameController.text,
          'username': _usernameController.text,
          'password': _passwordController.text,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 || data['status'] == 'success') {
        _showSnackBar("Đăng ký thành công! Hãy đăng nhập.");
        // Đăng ký xong thì quay lại màn hình Đăng nhập
        if (mounted) Navigator.pop(context);
      } else {
        _showSnackBar(data['message'] ?? "Đăng ký thất bại");
      }
    } catch (e) {
      _showSnackBar("Lỗi kết nối server");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tạo tài khoản của bạn",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Ô nhập Tên hiển thị
            _buildTextField(_nameController, "Họ và tên", Icons.face_outlined),
            const SizedBox(height: 16),

            // Ô nhập Username
            _buildTextField(
              _usernameController,
              "Tên đăng nhập (Username)",
              Icons.person_outline,
            ),
            const SizedBox(height: 16),

            // Ô nhập Mật khẩu
            _buildTextField(
              _passwordController,
              "Mật khẩu",
              Icons.lock_outline,
              isPassword: true,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF1A237E,
                  ), // Màu xanh Navy chuẩn Figma
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Tạo tài khoản",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Bạn đã có tài khoản?"),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Đăng nhập",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
