import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final int userId; // Nhận ID từ màn hình đăng nhập hoặc từ local storage
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Các controller để hiển thị dữ liệu lên TextField
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController shiftController = TextEditingController();

  String userRole = "";
  bool isEditing = false; // Trạng thái để hiện/ẩn nút Lưu

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  // 1. Lấy thông tin cá nhân từ API
  Future<void> fetchUserProfile() async {
    final response = await http.get(Uri.parse("http://10.0.2.2:8000/api/me/${widget.userId}"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        nameController.text = data['name'] ?? "";
        userRole = data['role'] ?? "Nhân viên";
        // Giả sử database bạn có các trường này, nếu chưa có sẽ để trống
        emailController.text = data['username'] ?? ""; // Tạm dùng username làm email
        phoneController.text = data['phone'] ?? "Chưa cập nhật";
        shiftController.text = data['shift'] ?? "08:00 - 17:00";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Thông tin cá nhân", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Avatar và tên (Giống ảnh image_a11a3d.png)
              const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
              const SizedBox(height: 10),
              Text(nameController.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("Nhân viên $userRole", style: const TextStyle(color: Colors.grey)),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() => isEditing = !isEditing),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Chỉnh sửa"),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
              ),

              _buildInfoField("Họ tên", nameController),
              _buildInfoField("SĐT", phoneController),
              _buildInfoField("Gmail", emailController),
              _buildInfoField("Ca làm", shiftController),

              const SizedBox(height: 30),
              if (isEditing)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                        onPressed: () { /* Logic update API ở đây */ },
                        child: const Text("Lưu thay đổi"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        onPressed: () => setState(() => isEditing = false),
                        child: const Text("Hủy"),
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

  Widget _buildInfoField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            enabled: isEditing, // Chỉ cho sửa khi nhấn nút Chỉnh sửa
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}