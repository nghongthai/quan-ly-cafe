import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  List<dynamic> staffList = [];
  bool isLoading = true;
  // URL cho máy ảo Android (10.0.2.2 trỏ về localhost của máy tính)
  final String apiUrl = "http://10.0.2.2:8000/api/users";

  @override
  void initState() {
    super.initState();
    fetchStaff();
  }

  // 1. Lấy danh sách nhân viên từ API
  Future<void> fetchStaff() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          staffList = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Lỗi lấy danh sách: $e");
    }
  }

  // 2. Xóa nhân viên
  Future<void> deleteStaff(int id) async {
    try {
      final response = await http.delete(Uri.parse("$apiUrl/$id"));
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Đã xóa nhân viên thành công"))
          );
        }
        fetchStaff();
      }
    } catch (e) {
      debugPrint("Lỗi xóa: $e");
    }
  }

  // 3. Thêm nhân viên mới (Đã thêm LOG để kiểm tra lỗi)
  Future<void> addStaff(String name, String username, String password, String role) async {
    try {
      print("--- Đang gửi yêu cầu lưu nhân viên ---");
      print("Dữ liệu: Name: $name, User: $username, Role: $role");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Accept": "application/json", // Yêu cầu Laravel trả về lỗi cụ thể dạng JSON
        },
        body: {
          'name': name,
          'username': username,
          'password': password,
          'role': role,
        },
      );

      // KIỂM TRA LỖI TẠI ĐÂY (Xem trong Debug Console của VS Code)
      print("Mã trạng thái trả về: ${response.statusCode}");
      print("Nội dung phản hồi: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("LƯU THÀNH CÔNG!");
        fetchStaff(); // Reload lại danh sách
        if (mounted) Navigator.pop(context); // Đóng dialog

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Thêm nhân viên thành công!"))
        );
      } else {
        print("LƯU THẤT BẠI. Kiểm tra lại Route hoặc dữ liệu trùng.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Lỗi ${response.statusCode}: Không thể lưu dữ liệu!"))
          );
        }
      }
    } catch (e) {
      print("LỖI KẾT NỐI API: $e");
    }
  }

  // Hàm hiển thị Dialog thêm nhân viên
  void _showAddStaffDialog() {
    final nameController = TextEditingController();
    final userController = TextEditingController();
    final passController = TextEditingController();
    String selectedRole = 'Phục vụ';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm nhân viên mới", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Họ và tên")),
              TextField(controller: userController, decoration: const InputDecoration(labelText: "Tên đăng nhập")),
              TextField(controller: passController, decoration: const InputDecoration(labelText: "Mật khẩu"), obscureText: true),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: "Vai trò/Chức vụ", border: OutlineInputBorder()),
                items: ['Thu ngân', 'Phục vụ', 'Pha chế'].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (val) => selectedRole = val!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              if (nameController.text.isNotEmpty && userController.text.isNotEmpty && passController.text.isNotEmpty) {
                addStaff(nameController.text, userController.text, passController.text, selectedRole);
              } else {
                print("Vui lòng nhập đầy đủ thông tin!");
              }
            },
            child: const Text("Lưu Nhân Viên", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Nhân viên", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 28),
            onPressed: _showAddStaffDialog,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm nhân viên",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                final staff = staffList[index];
                return _buildStaffItem(staff);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffItem(dynamic staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFFEEEEEE),
            child: Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(staff['name'] ?? "Không tên",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(staff['role'] ?? "Nhân viên",
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog(staff['id'], staff['name']);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Text("Xóa nhân viên", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc chắn muốn xóa nhân viên $name không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteStaff(id);
              },
              child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}