import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quan_ly_cafe/screens/api_constants.dart';
import 'product_list_screen.dart';
import 'order_detail_editable.dart';
import 'order_list_screen.dart';
import 'profile_screen.dart'; // 🌟 Đã thêm import trang thông tin cá nhân
import 'login_screen.dart';
import 'end_of_day_report_screen.dart';

class StaffRoomScreen extends StatefulWidget {
  final int userId; // 🌟 Nhận ID nhân viên truyền từ LoginScreen
  final String staffName; // 🌟 Nhận Tên nhân viên truyền từ LoginScreen

  const StaffRoomScreen({
    super.key,
    required this.userId,
    required this.staffName,
  });

  @override
  State<StaffRoomScreen> createState() => _StaffRoomScreenState();
}

class _StaffRoomScreenState extends State<StaffRoomScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> allTables = [];
  List<dynamic> filteredTables = [];

  String selectedArea = 'Tất cả';
  String filterStatus = 'Tất cả';

  bool isLoading = true;
  final String baseUrl = "${ApiConstants.baseUrl}";

  @override
  void initState() {
    super.initState();
    fetchTables();
  }

  String formatMoney(dynamic amount) {
    return NumberFormat(
      "###,###",
      "vi_VN",
    ).format(double.tryParse(amount.toString()) ?? 0);
  }

  Future<void> fetchTables() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$baseUrl/tables"));
      if (response.statusCode == 200) {
        setState(() {
          allTables = json.decode(response.body);
          applyFilter(filterStatus);
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải danh sách bàn: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void applyFilter(String status) {
    setState(() {
      filterStatus = status;
      filteredTables = allTables.where((table) {
        bool isOccupied =
            table['status'] == 'occupied' ||
            table['status'] == '1' ||
            table['status'] == 1;

        bool matchStatus = true;
        if (filterStatus == "Còn trống") {
          matchStatus = !isOccupied;
        } else if (filterStatus == "Đang dùng") {
          matchStatus = isOccupied;
        }

        bool matchArea = true;
        if (selectedArea != 'Tất cả') {
          String tableArea = (table['area'] ?? table['location'] ?? 'Trong nhà')
              .toString();
          matchArea = tableArea.contains(selectedArea);
        }

        return matchStatus && matchArea;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Quản lý mở đóng Drawer menu bằng nút 3 gạch
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Sơ đồ phòng bàn',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: fetchTables,
          ),
        ],
      ),

      // 🌟 ĐÃ CẬP NHẬT: Giao diện Drawer Menu 3 gạch chứa các danh mục
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B67D9), Color(0xFF1E88E5)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 32, color: Colors.blue),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget
                        .staffName, // Hiển thị chuẩn tên nhân viên đang đăng nhập
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Nhân viên phục vụ',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.table_restaurant, color: Colors.blue),
              title: const Text(
                'Sơ đồ phòng bàn',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.orange),
              title: const Text('Lịch sử đơn hàng'),
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
            ListTile(
              leading: const Icon(Icons.lock_clock, color: Colors.teal),
              title: const Text('Báo cáo cuối ngày'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EndOfDayReportScreen(),
                  ),
                );
              }, // 🌟 ĐÃ SỬA: Chỗ này phải là }, chứ không phải là )
            ),
            // 🌟 ĐÃ CẬP NHẬT: Nhấn vào thông tin cá nhân sẽ chuyển hướng vào ProfileScreen cùng userId
            ListTile(
              leading: const Icon(Icons.badge, color: Colors.purple),
              title: const Text('Thông tin cá nhân'),
              onTap: () {
                Navigator.pop(context); // Đóng menu hông
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: widget.userId),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Container(
            color: Colors.white,
            height: 55,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildAreaTab('Tất cả'),
                _buildAreaTab('Trong nhà'),
                _buildAreaTab('Ngoài trời'),
                _buildAreaTab('Phòng VIP'),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildStatusButton('Tất cả', Icons.border_all, Colors.grey),
                const SizedBox(width: 8),
                _buildStatusButton(
                  'Còn trống',
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildStatusButton('Đang dùng', Icons.local_cafe, Colors.blue),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTables.isEmpty
                ? const Center(
                    child: Text(
                      "Không có bàn nào phù hợp",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(14),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.25,
                        ),
                    itemCount: filteredTables.length,
                    itemBuilder: (context, index) {
                      final table = filteredTables[index];

                      bool isOccupied =
                          table['status'] == 'occupied' ||
                          table['status'] == '1' ||
                          table['status'] == 1;

                      double totalAmount = 0;
                      final activeOrder =
                          table['active_order'] ?? table['current_order'];
                      if (activeOrder != null) {
                        totalAmount =
                            double.tryParse(
                              activeOrder['total_amount'].toString(),
                            ) ??
                            0;
                      }

                      return InkWell(
                        onTap: () async {
                          if (isOccupied) {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailEditableScreen(
                                  order: activeOrder,
                                ),
                              ),
                            );
                            if (result != null) fetchTables();
                          } else {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductListScreen(
                                  tableId: int.parse(table['id'].toString()),
                                ),
                              ),
                            );
                            if (result != null) fetchTables();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            color: isOccupied
                                ? const Color(0xFFE3F2FD)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isOccupied
                                  ? const Color(0xFF1E88E5)
                                  : Colors.grey[200]!,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Bàn ${table['name'] ?? table['id']}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isOccupied
                                          ? const Color(0xFF0D47A1)
                                          : Colors.black87,
                                    ),
                                  ),
                                  Icon(
                                    isOccupied
                                        ? Icons.local_cafe
                                        : Icons.check_circle,
                                    color: isOccupied
                                        ? Colors.blue
                                        : Colors.green,
                                    size: 20,
                                  ),
                                ],
                              ),
                              if (isOccupied && totalAmount > 0) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(
                                      Icons.receipt_long,
                                      color: Colors.redAccent,
                                      size: 16,
                                    ),
                                    Text(
                                      "${formatMoney(totalAmount)}đ",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                const Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    'Còn trống',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaTab(String areaName) {
    bool isSelected = selectedArea == areaName;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedArea = areaName;
          applyFilter(filterStatus);
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B67D9) : Colors.grey[100],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            areaName,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(String statusName, IconData icon, Color color) {
    bool isSelected = filterStatus == statusName;
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => applyFilter(statusName),
        icon: Icon(icon, size: 14, color: isSelected ? Colors.white : color),
        label: Text(
          statusName,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.grey[300]!,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
