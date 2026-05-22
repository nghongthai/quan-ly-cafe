import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Import chuẩn xác theo cấu trúc dự án của bạn
import 'package:quan_ly_cafe/screens/order_history_screen.dart';
import 'package:quan_ly_cafe/screens/profile_screen.dart';
import '../room_management.dart';
import '../order_list_screen.dart';
import '../staff_management_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  double revenue = 0;
  int ordersCount = 0;
  int activeTablesCount = 0;
  List<dynamic> topProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardStats();
  }

  // Hàm gọi API lấy dữ liệu thực từ Laravel
  Future<void> fetchDashboardStats() async {
    try {
      final response = await http.get(Uri.parse("http://10.0.2.2:8000/api/dashboard/stats"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            revenue = double.tryParse(data['revenue'].toString()) ?? 0.0;
            ordersCount = int.tryParse(data['orders_count'].toString()) ?? 0;
            activeTablesCount = int.tryParse(data['active_tables'].toString()) ?? 0;
            topProducts = data['top_products'] ?? [];
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String formatMoney(double amount) {
    return NumberFormat("###,###", "vi_VN").format(amount);
  }

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
          IconButton(
              onPressed: fetchDashboardStats,
              icon: const Icon(Icons.refresh, color: Color(0xFF3B67D1))
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
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
                  _buildMenuItem(Icons.grid_view, "Phòng bàn", onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RoomManagementScreen()),
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
                      MaterialPageRoute(builder: (context) => OrderHistoryScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.people_outline, "Nhân viên", onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StaffManagementScreen()),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B67D1)))
          : RefreshIndicator(
        onRefresh: fetchDashboardStats,
        color: const Color(0xFF3B67D1),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Doanh thu tích lũy", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      "${formatMoney(revenue)} đ",
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text("Cập nhật theo thời gian thực", style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Đã thêm sự kiện onTap: Ấn vào ô Số đơn hàng nhảy sang OrderListScreen
                  _buildStatCard(
                    "Số đơn hàng",
                    ordersCount.toString(),
                    Icons.arrow_upward,
                    Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrderListScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 15),
                  _buildStatCard(
                    "Phòng bàn",
                    activeTablesCount.toString(),
                    null,
                    Colors.black,
                    subTitle: "Đang hoạt động",
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text("Hiệu suất sản phẩm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              topProducts.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("Chưa có sản phẩm nào được bán", style: TextStyle(color: Colors.grey))),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topProducts.length,
                itemBuilder: (context, index) {
                  final item = topProducts[index];
                  return _buildProductItem(
                    item['name'] ?? "Sản phẩm",
                    "Đã bán: ${item['sold']}",
                    index == 0 ? Colors.brown : (index == 1 ? Colors.orange : Colors.blue),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị ô thống kê (Số đơn hàng / Phòng bàn) hỗ trợ sự kiện chạm InkWell
  Widget _buildStatCard(String title, String value, IconData? icon, Color iconColor, {String? subTitle, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
            // Đã bỏ const ở đây để đổi màu icon theo thứ hạng động index
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