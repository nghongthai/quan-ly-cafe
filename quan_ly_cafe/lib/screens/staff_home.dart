import 'package:flutter/material.dart';
import 'table_map_screen.dart'; // 🌟 BƯỚC 1: Import file sơ đồ bàn để lấy hàm phucVuBan

class OrderMenuScreen extends StatefulWidget {
  final String tableName; // Nhận tên bàn từ màn hình trước truyền sang

  const OrderMenuScreen({super.key, required this.tableName});

  @override
  State<OrderMenuScreen> createState() => _OrderMenuScreenState();
}

class _OrderMenuScreenState extends State<OrderMenuScreen> {
  String selectedCategory = 'Cà phê'; // Danh mục đang chọn

  // Dữ liệu mẫu (Mock data) cho danh sách món
  final List<Map<String, dynamic>> menuItems = [
    {'name': 'Cà phê đen đá', 'category': 'Cà phê', 'price': 25000},
    {'name': 'Cà phê sữa đá', 'category': 'Cà phê', 'price': 30000},
    {'name': 'Bạc xỉu', 'category': 'Cà phê', 'price': 35000},
    {'name': 'Trà đào cam sả', 'category': 'Trà', 'price': 45000},
    {'name': 'Trà vải', 'category': 'Trà', 'price': 40000},
    {'name': 'Sinh tố bơ', 'category': 'Sinh tố', 'price': 50000},
  ];

  int totalAmount = 0;
  int totalItems = 0;

  // Hàm tiện ích để format số tiền (VD: 100000 -> 100,000)
  String formatCurrency(int amount) {
    String result = amount.toString();
    if (result.length > 3) {
      result = result.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Lọc món theo danh mục
    List<Map<String, dynamic>> filteredItems = menuItems
        .where((item) => item['category'] == selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Gọi món - ${widget.tableName}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Column(
        children: [
          // 1. Thanh cuộn danh mục
          Container(
            height: 60,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                _buildCategoryChip('Cà phê'),
                const SizedBox(width: 10),
                _buildCategoryChip('Trà'),
                const SizedBox(width: 10),
                _buildCategoryChip('Sinh tố'),
                const SizedBox(width: 10),
                _buildCategoryChip('Đồ ăn vặt'),
              ],
            ),
          ),

          // 2. Lưới hiển thị món
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return _buildMenuItemCard(item);
              },
            ),
          ),

          // 3. Thanh giỏ hàng dưới cùng (Bottom Cart Bar)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12), // withOpacity(0.05)
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Đã chọn: $totalItems món',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '${formatCurrency(totalAmount)} đ',
                      style: const TextStyle(
                        color: Color(0xFF1A237E),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: totalItems > 0
                      ? () {
                    // 🌟 BƯỚC 2: GỌI HÀM CẬP NHẬT TRẠNG THÁI BÀN
                    // Cập nhật bàn thành 'isUsed = true' và gán tổng tiền
                    phucVuBan(
                      widget.tableName,
                      '${formatCurrency(totalAmount)}đ',
                    );

                    // Quay trở về màn hình Sơ đồ bàn (Bàn lúc này sẽ chuyển sang màu xanh)
                    Navigator.pop(context);
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'LƯU BÀN', // Đổi text thành LƯU BÀN cho sát nghĩa
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị nút Danh mục
  Widget _buildCategoryChip(String title) {
    bool isSelected = selectedCategory == title;
    return ChoiceChip(
      label: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF2196F3),
      backgroundColor: Colors.grey[200],
      showCheckmark: false,
      onSelected: (bool selected) {
        setState(() {
          selectedCategory = title;
        });
      },
    );
  }

  // Widget hiển thị Thẻ món ăn
  Widget _buildMenuItemCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: const Icon(
                Icons.local_cafe,
                size: 40,
                color: Colors.grey,
              ), // Hình ảnh placeholder
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${formatCurrency(item['price'])}đ',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          totalItems++;
                          totalAmount += item['price'] as int;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2196F3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
