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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(featureName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: const Text("Tính năng này đang được cập nhật."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Đóng", style: TextStyle(color: Color(0xFF3B67D9))),
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
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Chủ Quán",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
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
                          MaterialPageRoute(builder: (context) => const RoomManagementScreen()),
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
                          MaterialPageRoute(builder: (context) => const OrderListScreen()),
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
                          MaterialPageRoute(builder: (context) =>  OrderHistoryScreen()),
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
                          MaterialPageRoute(builder: (context) => const StaffManagementScreen()),
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
                          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
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
      ).