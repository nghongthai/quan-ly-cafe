import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quan_ly_cafe/screens/api_constants.dart';
import 'product_list_screen.dart'; // ✅ ĐÃ QUAY LẠI FILE GỐC CỦA BẠN
import 'order_detail_editable.dart';

class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({super.key});

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  List<dynamic> allTables = [];
  List<dynamic> filteredTables = [];

  String selectedArea = 'Tất cả'; // Bộ lọc khu vực đẹp từ table_map
  String filterStatus =
      'Tất cả'; // Bộ lọc trạng thái cũ của bạn ("Tất cả", "Còn trống", "Đang dùng")

  bool isLoading = true;
  final String baseUrl = "${ApiConstants.baseUrl}";

  @override
  void initState() {
    super.initState();
    fetchTables();
  }

  // Hàm định dạng tiền tệ của bạn
  String formatMoney(dynamic amount) {
    return NumberFormat(
      "###,###",
      "vi_VN",
    ).format(double.tryParse(amount.toString()) ?? 0);
  }

  // API lấy danh sách bàn gốc của bạn
  Future<void> fetchTables() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$baseUrl/tables"));
      if (response.statusCode == 200) {
        setState(() {
          allTables = json.decode(response.body);
          applyFilter(filterStatus); // Chạy bộ lọc kết hợp
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải danh sách bàn: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Gộp logic lọc trạng thái của bạn với lọc Khu Vực đẹp
  void applyFilter(String status) {
    setState(() {
      filterStatus = status;
      filteredTables = allTables.where((table) {
        // 1. Kiểm tra trạng thái giống file cũ của bạn
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

        // 2. Kiểm tra khu vực
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
      backgroundColor: const Color(0xFFF4F6F9), // Màu nền xám nhẹ hiện đại
      appBar: AppBar(
        title: const Text(
          'Quản lý bàn ăn',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: fetchTables,
          ),
        ],
      ),
      body: Column(
        children: [
          // KHỐI 1: Thanh chọn KHU VỰC giao diện Tab ngang
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

          // KHỐI 2: Thanh lọc TRẠNG THÁI
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

          // KHỐI 3: Lưới danh sách các bàn
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
                          crossAxisCount: 2, // Chia làm 2 cột
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio:
                              1.25, // Tỉ lệ ô vuông chữ nhật nằm ngang vừa vặn
                        ),
                    itemCount: filteredTables.length,
                    itemBuilder: (context, index) {
                      final table = filteredTables[index];

                      // Kiểm tra trạng thái từ dữ liệu của bạn
                      bool isOccupied =
                          table['status'] == 'occupied' ||
                          table['status'] == '1' ||
                          table['status'] == 1;

                      // Lấy tổng tiền đơn hàng đang hoạt động của bạn
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
                          // LUỒNG ĐIỀU HƯỚNG GỐC CHUẨN CỦA BẠN:
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
                                // ✅ ĐÃ SỬA GỌI ĐÚNG PRODUCTLISTSCREEN VÀ ÉP KIỂU INT CHO TABLEID
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

  // Giao diện vẽ ô Tab chọn khu vực ngang
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

  // Giao diện nút lọc trạng thái bo góc thay thế Dropdown cũ
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
