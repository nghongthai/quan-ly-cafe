import 'package:flutter/material.dart';
import 'order_menu_screen.dart';
import 'order_summary_screen.dart';

// 🌟 BƯỚC 1: ĐƯA DANH SÁCH BÀN RA NGOÀI THÀNH BIẾN TOÀN CỤC
final ValueNotifier<List<Map<String, dynamic>>>
tableDataNotifier = ValueNotifier([
  {
    'name': 'Bàn 1',
    'area': 'Cafe Bên Trong',
    'isUsed': true,
    'amount': '100,000đ',
  },
  {
    'name': 'Bàn 2',
    'area': 'Cafe Bên Trong',
    'isUsed': true,
    'amount': '100,000đ',
  },
  {'name': 'Bàn 3', 'area': 'Cafe Bên Trong', 'isUsed': false, 'amount': ''},
  {
    'name': 'Bàn 4',
    'area': 'Cafe Bên Trong',
    'isUsed': true,
    'amount': '100,000đ',
  },
  {
    'name': 'Bàn 5',
    'area': 'Cafe Bên Trong',
    'isUsed': true,
    'amount': '100,000đ',
  },
  {'name': 'Bàn 6', 'area': 'Cafe Bên Trong', 'isUsed': false, 'amount': ''},
  {
    'name': 'Bàn 7',
    'area': 'Cafe Bên Trong',
    'isUsed': true,
    'amount': '100,000đ',
  },
  {'name': 'Bàn 8', 'area': 'Cafe Bên Trong', 'isUsed': false, 'amount': ''},
  {
    'name': 'Bàn 9',
    'area': 'Cafe Bên Trong',
    'isUsed': true,
    'amount': '200,000đ',
  },
  {
    'name': 'Bàn 10',
    'area': 'Cafe Bên Trong',
    'isUsed': true,
    'amount': '430,000đ',
  },
  {
    'name': 'Bàn 11',
    'area': 'Cafe Bên Ngoài',
    'isUsed': true,
    'amount': '150,000đ',
  },
  {'name': 'Bàn 12', 'area': 'Cafe Bên Ngoài', 'isUsed': false, 'amount': ''},
  {'name': 'Mang Đi 1', 'area': 'Mang Đi', 'isUsed': true, 'amount': '65,000đ'},
]);

// 🌟 BƯỚC 2: THÊM CÁC HÀM XỬ LÝ TRẠNG THÁI BÀN (GLOBAL FUNCTIONS)

/// Gọi hàm này khi LƯU BÀN (từ màn hình OrderMenuScreen)
void phucVuBan(String tableName, String totalAmount) {
  tableDataNotifier.value = tableDataNotifier.value.map(
    (table) {
      if (table['name'] == tableName) {
        return {...table, 'isUsed': true, 'amount': totalAmount};
      }
      return table;
    },
  ).toList(); // Cần .toList() để tạo List mới giúp ValueNotifier nhận diện thay đổi
}

/// Gọi hàm này khi THANH TOÁN XONG (từ màn hình PaymentStaffScreen)
void giaiPhongBan(String tableName) {
  tableDataNotifier.value = tableDataNotifier.value.map((table) {
    if (table['name'] == tableName) {
      return {...table, 'isUsed': false, 'amount': ''};
    }
    return table;
  }).toList();
}

class TableMapScreen extends StatefulWidget {
  const TableMapScreen({super.key});

  @override
  State<TableMapScreen> createState() => _TableMapScreenState();
}

class _TableMapScreenState extends State<TableMapScreen> {
  String selectedArea = 'Cafe Bên Trong';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          elevation: 0,
          title: const Text(
            'Sơ đồ bàn',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black87),
              onPressed: () {},
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.black87,
                  ),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF2196F3),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF2196F3),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: [
              Tab(text: 'Tất cả'),
              Tab(text: 'Sử dụng'),
              Tab(text: 'Còn trống'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAreaButton('Cafe Bên Trong'),
                  _buildAreaButton('Cafe Bên Ngoài'),
                  _buildAreaButton('Mang Đi'),
                ],
              ),
            ),

            // BỌC BẰNG VALUELISTENABLEBUILDER
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: tableDataNotifier,
                builder: (context, currentTables, child) {
                  return TabBarView(
                    children: [
                      // Truyền danh sách currentTables vào hàm build
                      _buildTableGrid(
                        filterStatus: 'all',
                        currentTableList: currentTables,
                      ),
                      _buildTableGrid(
                        filterStatus: 'used',
                        currentTableList: currentTables,
                      ),
                      _buildTableGrid(
                        filterStatus: 'empty',
                        currentTableList: currentTables,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaButton(String areaName) {
    bool isSelected = selectedArea == areaName;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedArea = areaName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          areaName,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1E88E5) : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTableGrid({
    required String filterStatus,
    required List<Map<String, dynamic>> currentTableList,
  }) {
    List<Map<String, dynamic>> filteredList = currentTableList
        .where((t) => t['area'] == selectedArea)
        .toList();

    if (filterStatus == 'used') {
      filteredList = filteredList.where((t) => t['isUsed'] == true).toList();
    } else if (filterStatus == 'empty') {
      filteredList = filteredList.where((t) => t['isUsed'] == false).toList();
    }

    if (filteredList.isEmpty) {
      return Center(
        child: Text(
          'Trống lịch hiển thị',
          style: TextStyle(color: Colors.grey[400], fontSize: 15),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.4,
      ),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final table = filteredList[index];
        bool isUsed = table['isUsed'];

        return GestureDetector(
          onTap: () {
            if (isUsed) {
              // 1. Nếu bàn ĐANG SỬ DỤNG (isUsed == true)
              // Chuyển sang màn hình xem chi tiết và thanh toán
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OrderSummaryScreen(tableName: table['name']),
                ),
              );
            } else {
              // 2. Nếu bàn TRỐNG (isUsed == false)
              // Chuyển sang màn hình gọi món mới
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OrderMenuScreen(tableName: table['name']),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isUsed ? const Color(0xFFE3F2FD) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10), // Tối ưu withOpacity
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: isUsed ? const Color(0xFF90CAF9) : Colors.grey[200]!,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  table['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isUsed ? const Color(0xFF0D47A1) : Colors.black87,
                  ),
                ),
                if (isUsed) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      Text(
                        table['amount'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'Trống',
                      style: TextStyle(color: Colors.black38, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
