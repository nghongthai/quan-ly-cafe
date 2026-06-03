import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quan_ly_cafe/screens/api_constants.dart';

class ProductPerformanceScreen extends StatefulWidget {
  const ProductPerformanceScreen({super.key});

  @override
  State<ProductPerformanceScreen> createState() => _ProductPerformanceScreenState();
}

class _ProductPerformanceScreenState extends State<ProductPerformanceScreen> {
  String selectedFilter = 'Ngày'; // Bộ lọc mặc định: Ngày, Tuần, Tháng
  bool isLoading = true;
  List<dynamic> productList = []; // Danh sách toàn bộ sản phẩm nhận từ API

  @override
  void initState() {
    super.initState();
    fetchProductPerformance();
  }

  // Hàm gọi API lấy dữ liệu hiệu suất sản phẩm từ Laravel Backend
  Future<void> fetchProductPerformance() async {
    setState(() => isLoading = true);

    // Chuyển đổi chữ có dấu sang chữ thường để gửi lên API đúng chuẩn Laravel nhận
    String typeParam = 'ngày';
    if (selectedFilter == 'Tuần') typeParam = 'tuần';
    if (selectedFilter == 'Tháng') typeParam = 'tháng';

    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/dashboard/product-performance?type=$typeParam"),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (mounted) {
          setState(() {
            productList = jsonResponse['data'] ?? [];
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => isLoading = false);
          _showErrorSnackBar("Không thể tải dữ liệu từ máy chủ");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showErrorSnackBar("Lỗi kết nối mạng mạng, vui lòng thử lại!");
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Chi tiết hiệu suất sản phẩm",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF3B67D1)),
            onPressed: fetchProductPerformance,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. THANH BỘ LỌC (NGÀY, TUẦN, THÁNG)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterTab('Ngày'),
                _buildFilterTab('Tuần'),
                _buildFilterTab('Tháng'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 2. DANH SÁCH SẢN PHẨM HIỂN THỊ
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B67D1)),
            )
                : productList.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    "Không có sản phẩm nào được bán\ntrong khoảng thời gian này",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: productList.length,
              itemBuilder: (context, index) {
                final product = productList[index];

                // Thiết lập màu sắc huy hiệu thứ hạng (Top 1, 2, 3) cho sinh động
                Color rankColor = Colors.grey[400]!;
                if (index == 0) rankColor = const Color(0xFFFFD700); // Vàng - Top 1
                if (index == 1) rankColor = const Color(0xFFC0C0C0); // Bạc - Top 2
                if (index == 2) rankColor = const Color(0xFFCD7F32); // Đồng - Top 3

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Hiển thị số thứ hạng bán chạy
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: rankColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              color: index < 3 ? rankColor : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Ảnh / Icon đại diện món ăn thức uống
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          "assets/images/${product['image'] ?? ''}",
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.local_drink,
                                color: Color(0xFF3B67D1),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Tên sản phẩm và Số lượng bán ra tương ứng
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] ?? "Sản phẩm",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Đã bán: ${product['sold']} ly/phần",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Hỗ trợ dựng Widget nút bấm chuyển nhanh Tab bộ lọc thời gian
  Widget _buildFilterTab(String title) {
    bool isSelected = selectedFilter == title;
    return GestureDetector(
      onTap: () {
        if (selectedFilter != title) {
          setState(() {
            selectedFilter = title;
          });
          fetchProductPerformance(); // Tải lại dữ liệu tương ứng ngay khi bấm
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B67D1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}