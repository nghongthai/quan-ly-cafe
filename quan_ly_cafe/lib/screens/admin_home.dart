import 'package:flutter/material.dart';

// Import cấu hình các trang theo đúng cấu trúc thư mục của bạn
import 'room_management.dart';
import 'order_list_screen.dart';
import 'order_history_screen.dart';
import 'profile_screen.dart';
import 'staff_management_screen.dart';
import 'welcome_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FE),

      // --- MENU ĐIỀU HƯỚNG DRAWER NGUYÊN BẢN ---
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
                            builder: (context) => OrderHistoryScreen(),
                          ),
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
      ),

      appBar: AppBar(
        title: const Text(
          "Tổng quan doanh thu",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black, size: 26),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRevenueCard(), // Trả về giao diện viết cứng ban đầu
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSmallCard(
                    "Số đơn hàng",
                    "120",
                    Icons.shopping_bag_outlined,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildSmallCard(
                    "Phòng bàn",
                    "5/15",
                    Icons.table_restaurant,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            const Text(
              "Sản phẩm bán chạy",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Danh sách sản phẩm viết cứng ban đầu
            _buildProductItem(
              "Nước cam",
              "Đã bán: 50",
              Colors.orange[50]!,
              Colors.orange,
            ),
            _buildProductItem(
              "Cà phê sữa",
              "Đã bán: 45",
              Colors.blue[50]!,
              Colors.blue,
            ),
            _buildProductItem(
              "Trà đào",
              "Đã bán: 30",
              Colors.purple[50]!,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    required VoidCallback onTap,
    bool isSelected = false,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout
            ? Colors.red
            : (isSelected ? Colors.black : Colors.black87),
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildRevenueCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B67D9), Color(0xFF5E81F4)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tổng thu nhập",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            "15.000.000 đ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, color: Colors.white, size: 16),
                SizedBox(width: 5),
                Text(
                  "Tăng trưởng: 12.5%",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(
    String name,
    String sold,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.coffee_outlined, color: iconColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  sold,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
        ],
      ),
    );
  }
}
