import 'package:flutter/material.dart';
// 1. Import các trang cần thiết
import 'package:quan_ly_cafe/screens/order_history_screen.dart';
import 'package:quan_ly_cafe/screens/profile_screen.dart'; // Đảm bảo bạn đã có file này

import '../room_management.dart';
import '../order_list_screen.dart';
import '../staff_management_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Tổng quan doanh thu",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // SỬA TẠI ĐÂY: Bọc toàn bộ Header để ấn vào là chuyển sang Profile
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Đóng drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Truyền userId (tạm thời để là 1 hoặc lấy từ biến đăng nhập)
                    builder: (context) => const ProfileScreen(userId: 1),
                  ),
                );
              },
              child: const UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.white),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                accountName: Text(
                  "Chủ Quán",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  "Thông tin cá nhân >",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(Icons.account_balance_wallet_outlined, "Tổng quan doanh thu", onTap: () {
                    Navigator.pop(context);
                  }),
                  _buildMenuItem(Icons.grid_view, "Phòng ban", onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  const RoomManagementScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.assignment_outlined, "Danh sách đơn hàng", onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderListScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.history, "Lịch sử bàn giao ca"),

                  _buildMenuItem(Icons.update, "Lịch sử đơn hàng", onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  OrderHistoryScreen()),
                    );
                  }),

                  _buildMenuItem(Icons.people_outline, "Nhân viên", onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  const StaffManagementScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.admin_panel_settings_outlined, "Vai trò"),
                  _buildMenuItem(Icons.lock_reset, "Đổi mật khẩu"),
                  const Divider(),
                  _buildMenuItem(Icons.logout, "Đăng xuất", color: Colors.red, onTap: () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF3B67D1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Doanh thu hôm nay", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 8),
                  Text("15.000.000 đ",
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("↗ 20% so với hôm qua", style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildStatCard("Số đơn hàng", "120", Icons.arrow_upward, Colors.green),
                const SizedBox(width: 15),
                _buildStatCard("Phòng ban", "2", null, Colors.black, subTitle: "Đang hoạt động"),
              ],
            ),
            const SizedBox(height: 25),
            const Text("Hiệu suất sản phẩm",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildProductItem("Nước cam", "Đã bán: 50", Colors.orange),
            _buildProductItem("Nước dừa", "Đã bán: 50", Colors.blue),
            _buildProductItem("Cafe đen", "Đã bán: 10", Colors.brown),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData? icon, Color iconColor, {String? subTitle}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                if (icon != null) Icon(icon, color: iconColor, size: 18),
              ],
            ),
            if (subTitle != null)
              Text(subTitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(String name, String sold, Color iconBgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)
            ),
            child: Icon(Icons.local_drink, color: iconBgColor),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(sold, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {Color color = Colors.black, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}