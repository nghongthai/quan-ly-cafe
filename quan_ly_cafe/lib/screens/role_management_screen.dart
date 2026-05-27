import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  List<dynamic> allStaff = [];
  List<dynamic> filteredStaff = [];
  bool isLoading = true;

  // Danh mục bộ lọc vai trò
  List<String> rolesList = ['Tất cả', 'Thu ngân', 'Phục vụ', 'Pha chế', 'Admin'];
  String selectedRoleTab = 'Tất cả';

  final String apiUrl = "http://10.0.2.2:8000/api/users";

  @override
  void initState() {
    super.initState();
    fetchAllStaffData();
  }

  // 1. Lấy dữ liệu nhân viên từ API Laravel
  Future<void> fetchAllStaffData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          allStaff = json.decode(response.body);
          _filterStaffByRole(selectedRoleTab);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Lỗi kết nối API danh sách nhân viên", Colors.red);
    }
  }

  // Lọc dữ liệu theo tab đang chọn
  void _filterStaffByRole(String role) {
    setState(() {
      selectedRoleTab = role;
      if (role == 'Tất cả') {
        filteredStaff = allStaff;
      } else {
        filteredStaff = allStaff.where((staff) =>
        staff['role'].toString().toLowerCase() == role.toLowerCase()
        ).toList();
      }
    });
  }

  // 2. Gọi API để cập nhật vai trò mới lên Laravel Database
  Future<void> _updateStaffRole(int staffId, String newRole) async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/$staffId"),
        headers: {"Accept": "application/json"},
        body: {
          "role": newRole,
        },
      );

      if (response.statusCode == 200) {
        _showSnackBar("Thay đổi vai trò thành công!", Colors.green);
        fetchAllStaffData(); // Tải lại danh sách mới
      } else {
        _showSnackBar("Cập nhật thất bại. Lỗi phía máy chủ!", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Lỗi kết nối mạng!", Colors.red);
    }
  }

  // 3. Hộp thoại THÊM VAI TRÒ MỚI (Kích hoạt từ dấu cộng trên AppBar)
  void _showAddRoleDialog() {
    final roleNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm vai trò mới", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: roleNameController,
          decoration: const InputDecoration(
            labelText: "Tên vai trò mới",
            hintText: "Ví dụ: Quản lý, Bảo vệ...",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              if (roleNameController.text.isNotEmpty) {
                setState(() {
                  rolesList.add(roleNameController.text.trim());
                });
                Navigator.pop(context);
                _showSnackBar("Đã thêm vai trò mới thành công!", Colors.green);
              }
            },
            child: const Text("Thêm", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // 4. Hộp thoại ĐỔI VAI TRÒ (Kích hoạt từ menu dấu 3 chấm)
  void _showChangeRoleDialog(dynamic staff) {
    String currentRole = staff['role'] ?? 'Phục vụ';
    List<String> availableRoles = rolesList.where((r) => r != 'Tất cả').toList();

    if (!availableRoles.contains(currentRole)) {
      availableRoles.add(currentRole);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Thay đổi vai trò của:\n${staff['name']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Chọn chức vụ mới:", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: currentRole,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: availableRoles.map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (val) {
                currentRole = val!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              Navigator.pop(context);
              _updateStaffRole(staff['id'], currentRole);
            },
            child: const Text("Lưu thay đổi", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      // MÃ CẤU TRÚC APPBAR GIỐNG HỆT FILE NHÂN VIÊN CỦA BẠN
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Vai trò", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          // 🌟 Dấu cộng góc trên bên phải để thêm vai trò đúng thiết kế bạn yêu cầu
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 28),
            onPressed: _showAddRoleDialog,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // THANH CHỌN BỘ LỌC VAI TRÒ
          Container(
            height: 60,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: rolesList.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                String role = rolesList[index];
                bool isSelected = selectedRoleTab == role;
                return GestureDetector(
                  onTap: () => _filterStaffByRole(role),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[600] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        role,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // DANH SÁCH HIỂN THỊ ITEM (THIẾT KẾ GIỐNG TRANG NHÂN VIÊN)
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredStaff.isEmpty
                ? const Center(child: Text("Không có nhân viên thuộc nhóm vai trò này"))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredStaff.length,
              itemBuilder: (context, index) {
                final staff = filteredStaff[index];
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
                            Text("Chức vụ: ${staff['role'] ?? 'Chưa rõ'}",
                                style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ),
                      // 🌟 MENU DẤU 3 CHẤM Ở CẠNH PHẢI ĐỂ THAY ĐỔI VAI TRÒ NHƯ BẠN CẦN
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        onSelected: (value) {
                          if (value == 'change_role') {
                            _showChangeRoleDialog(staff);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'change_role',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue, size: 20),
                                const SizedBox(width: 10),
                                Text("Thay đổi vai trò", style: TextStyle(color: Colors.blue)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}