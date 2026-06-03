import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quan_ly_cafe/screens/api_constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> changePassword() async {
    if (emailController.text.trim().isEmpty ||
        currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showSnackBar('Vui l\u00f2ng nh\u1eadp \u0111\u1ea7y \u0111\u1ee7 th\u00f4ng tin');
      return;
    }

    if (!emailController.text.trim().contains('@')) {
      _showSnackBar('Email kh\u00f4ng h\u1ee3p l\u1ec7');
      return;
    }

    if (newPasswordController.text.length < 6) {
      _showSnackBar('M\u1eadt kh\u1ea9u m\u1edbi ph\u1ea3i c\u00f3 \u00edt nh\u1ea5t 6 k\u00fd t\u1ef1');
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _showSnackBar('M\u1eadt kh\u1ea9u nh\u1eadp l\u1ea1i kh\u00f4ng kh\u1edbp');
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/change-password"),
        headers: {"Accept": "application/json"},
        body: {
          'email': emailController.text.trim(),
          'current_password': currentPasswordController.text,
          'password': newPasswordController.text,
          'password_confirmation': confirmPasswordController.text,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        _showSnackBar('\u0110\u1ed5i m\u1eadt kh\u1ea9u th\u00e0nh c\u00f4ng, vui l\u00f2ng \u0111\u0103ng nh\u1eadp l\u1ea1i');
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        _showSnackBar(data['message'] ?? 'Kh\u00f4ng th\u1ec3 \u0111\u1ed5i m\u1eadt kh\u1ea9u');
      }
    } catch (e) {
      _showSnackBar('Kh\u00f4ng th\u1ec3 k\u1ebft n\u1ed1i \u0111\u1ebfn m\u00e1y ch\u1ee7');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '\u0110\u1ed5i m\u1eadt kh\u1ea9u',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'X\u00e1c nh\u1eadn t\u00e0i kho\u1ea3n',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nh\u1eadp email v\u00e0 m\u1eadt kh\u1ea9u hi\u1ec7n t\u1ea1i \u0111\u1ec3 \u0111\u1ed5i m\u1eadt kh\u1ea9u m\u1edbi',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 28),
            _buildTextField(
              emailController,
              'Email hi\u1ec7n t\u1ea1i',
              Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              currentPasswordController,
              'M\u1eadt kh\u1ea9u hi\u1ec7n t\u1ea1i',
              Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              newPasswordController,
              'M\u1eadt kh\u1ea9u m\u1edbi',
              Icons.lock_reset,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              confirmPasswordController,
              'Nh\u1eadp l\u1ea1i m\u1eadt kh\u1ea9u m\u1edbi',
              Icons.check_circle_outline,
              isPassword: true,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        '\u0110\u1ed5i m\u1eadt kh\u1ea9u',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
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
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
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
