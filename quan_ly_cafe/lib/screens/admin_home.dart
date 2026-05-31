import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Import cấu hình các trang theo đúng cấu trúc thư mục của bạn
import 'screens/room_management.dart';
import 'order_list_screen.dart';
import 'order_history_screen.dart';
import 'profile_screen.dart';
import 'staff_management_screen.dart';
import 'welcome_screen.dart';

// Ghi chú: Nếu bạn đã có file api_constants.dart riêng ở bên ngoài,
// bạn nên xóa class này đi và import file đó vào để tránh lặp code nhé.
class ApiConstants {
  static String get baseUrl =>
      kIsWeb ? 'http://127.0.0.1:8000/api' : 'http://10.0.2.2:8000/api';
}

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  // Hàm hiển thị Dialog thông báo tính năng đang phát triển
  void _showDevelopingDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            featureName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: const Text("Tính năng này đang được cập nhật."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Đóng",
                style: TextStyle(color: Color(0xFF3B67D9)),
              ),
            ),
          ],
        );
      },
    );
  }

  // ĐÂY LÀ HÀM BỊ THIẾU MÌNH ĐÃ VIẾT BỔ SUNG CHO BẠN
  Widget _buildMenuItem(
    IconData icon,
    String title, {
    bool isSelected = false,
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout
            ? Colors.red
            : (isSelected ? Colors.blue : Colors.grey.shade700),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout
              ? Colors.red
              : (isSelected ? Colors.blue : Colors.black87),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FE),

      // Thêm AppBar để có nút 3 gạch mở Drawer
      appBar: AppBar(
        title: const Text("Tổng quan doanh thu"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      // Thêm Body tạm thời để màn hình không bị trống
      body: const Center(
        child: Text(
          "Biểu đồ doanh thu sẽ hiển thị ở đây",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),

      // --- MENU ĐIỀU HƯỚNG DRAWER CỦA BẠN ---
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 60, left: 20, bottom: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Chủ Quán",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Thông tin cá nhân >",
                        style: TextStyle(color: Colors.blue, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuItem(
                      Icons.account_balance_wallet_outlined,
                      "Tổng quan doanh thu",
                      isSelected: true,
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildMenuItem(
                      Icons.grid_view,
                      "Phòng bàn",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RoomManagementScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      Icons.assignment_outlined,
                      "Danh sách đơn hàng",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderListScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      Icons.history,
                      "Lịch sử bàn giao ca",
                      onTap: () {
                        Navigator.pop(context);
                        _showDevelopingDialog(context, "Lịch sử bàn giao ca");
                      },
                    ),
                    _buildMenuItem(
                      Icons.history_edu,
                      "Lịch sử đơn hàng",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderHistoryScreen(),
                          ), // Đã thêm const
                        );
                      },
                    ),
                    _buildMenuItem(
                      Icons.people_outline,
                      "Nhân viên",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StaffManagementScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      Icons.admin_panel_settings_outlined,
                      "Vai trò",
                      onTap: () {
                        Navigator.pop(context);
                        _showDevelopingDialog(context, "Vai trò");
                      },
                    ),
                    _buildMenuItem(
                      Icons.lock_reset_outlined,
                      "Đổi mật khẩu",
                      onTap: () {
                        Navigator.pop(context);
                        _showDevelopingDialog(context, "Đổi mật khẩu");
                      },
                    ),
                    const Divider(),
                    _buildMenuItem(
                      Icons.logout,
                      "Đăng xuất",
                      isLogout: true,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WelcomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ), // Đóng Drawer đúng chuẩn
    ); // Đóng Scaffold đúng chuẩn
  }
}
