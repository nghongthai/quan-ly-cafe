import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController shiftController = TextEditingController();

  String userRole = "Nhân viên";
  bool isEditing = false;
  bool isLoading = true; // Thêm vòng tròn chờ tải tránh việc màn hình bị trống

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  // 🌟 ĐÃ CẬP NHẬT: Lấy thông tin cá nhân thực tế của nhân viên bằng cách gọi API /api/me/$userId
  Future<void> fetchUserProfile() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("http://10.0.2.2:8000/api/me/${widget.userId}"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nameController.text = data['name'] ?? "";
          userRole = data['role'] ?? "Nhân viên";
          emailController.text = data['email'] ?? data['username'] ?? "";
          phoneController.text = data['phone'] ?? "Chưa cập nhật";
          shiftController.text = data['shift'] ?? "Toàn thời gian";
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải thông tin cá nhân: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Thông tin cá nhân", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFE8EAF6),
                child: Icon(Icons.person, size: 45, color: Color(0xFF1A237E)),
              ),
              const SizedBox(height: 10),
              Text(
                nameController.text,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                userRole.toLowerCase().contains("admin") || userRole.toLowerCase().contains("quản lý")
                    ? userRole
                    : "Nhân viên ($userRole)",
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
              ),

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

              const SizedBox(height: 20),
              if (isEditing)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          setState(() => isEditing = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Cập nhật thông tin thành công!")),
                          );
                        },
                        child: const Text("Lưu thay đổi", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => setState(() => isEditing = false),
                        child: const Text("Hủy", style: TextStyle(color: Colors.white)),
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: isEditing,
            decoration: InputDecoration(
              filled: true,
              fillColor: isEditing ? Colors.white : Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}