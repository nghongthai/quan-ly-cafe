import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quan_ly_cafe/screens/api_constants.dart';

// Import chuẩn xác theo cấu trúc dự án của bạn
import 'package:quan_ly_cafe/screens/order_history_screen.dart';
import 'package:quan_ly_cafe/screens/profile_screen.dart';
import 'package:quan_ly_cafe/screens/admin/revenue_report_screen.dart';
import 'package:quan_ly_cafe/screens/admin/product_performance_screen.dart'; // 🌟 Đã thêm import màn hình chi tiết hiệu suất sản phẩm mới
import '../room_management.dart';
import '../order_list_screen.dart';
import '../staff_management_screen.dart';
import '../role_management_screen.dart';
import '../login_screen.dart';

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
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/dashboard/stats"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            revenue = double.tryParse(data['revenue'].toString()) ?? 0.0;
            ordersCount = int.tryParse(data['orders_count'].toString()) ?? 0;
            activeTablesCount =
                int.tryParse(data['active_tables'].toString()) ?? 0;
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

  // HỘP THOẠI XÁC NHẬN ĐĂNG XUẤT 2 BƯỚC
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text("Xác nhận", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Hủy",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              },
              child: const Text(
                "Đăng xuất",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Tổng quan doanh thu",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: fetchDashboardStats,
            icon: const Icon(Icons.refresh, color: Color(0xFF3B67D1)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
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
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  "Thông tin cá nhân >",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    Icons.account_balance_wallet_outlined,
                    "Tổng quan doanh thu",
                    onTap: () {
                      Navigator.pop(context);
                    },
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
                  _buildMenuItem(Icons.history, "Lịch sử bàn giao ca"),
                  _buildMenuItem(
                    Icons.update,
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
                    Icons.security,
                    ' vai trò',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoleManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(Icons.lock_reset, "Đổi mật khẩu"),
                  const Divider(),
                  _buildMenuItem(
                    Icons.logout,
                    "Đăng xuất",
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutConfirmation();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF3B67D1)),
      )
          : RefreshIndicator(
        onRefresh: fetchDashboardStats,
        color: const Color(0xFF3B67D1),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RevenueReportScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B67D1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Doanh thu tích lũy",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${formatMoney(revenue)} đ",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Cập nhật theo thời gian thực",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStatCard(
                    "Số đơn hàng",
                    ordersCount.toString(),
                    Icons.arrow_upward,
                    Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderListScreen(),
                        ),
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

              // 🌟 ĐÃ SỬA TẠI ĐÂY: Thêm hàng Row và nút bấm mũi tên ">" chuyển trang chi tiết
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Hiệu suất sản phẩm",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductPerformanceScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10), // Giảm bớt khoảng cách một chút cho cân đối

              topProducts.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "Chưa có sản phẩm nào được bán",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
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
                    index == 0
                        ? Colors.brown
                        : (index == 1
                        ? Colors.orange
                        : Colors.blue),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title,
      String value,
      IconData? icon,
      Color iconColor, {
        String? subTitle,
        VoidCallback? onTap,
      }) {
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
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (icon != null) Icon(icon, color: iconColor, size: 18),
                ],
              ),
              if (subTitle != null)
                Text(
                  subTitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBgColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.local_drink, color: iconBgColor),
          ),
          const SizedBox(width: 15),
          Column(
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
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      IconData icon,
      String title, {
        Color color = Colors.black,
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}