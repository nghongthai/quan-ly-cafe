import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:quan_ly_cafe/screens/api_constants.dart';

class OrderDetailScreen extends StatelessWidget {
  final dynamic order;
  const OrderDetailScreen({super.key, required this.order});

  // Hàm định dạng tiền tệ Việt Nam
  String formatMoney(dynamic amount) {
    if (amount == null) return "0đ";
    try {
      final formatter = NumberFormat("###,###", "vi_VN");
      return "${formatter.format(double.parse(amount.toString()))}đ";
    } catch (e) {
      return "0đ";
    }
  }

  // --- HÀM XỬ LÝ THANH TOÁN (ĐÃ SỬA LỖI) ---
  Future<void> _handleCheckout(BuildContext context) async {
    try {
      // Hiện loading khi đang xử lý
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/order/checkout"),
        headers: {
          "Content-Type":
              "application/json", // Bắt buộc để Laravel nhận diện JSON
        },
        body: jsonEncode({
          'table_id': order['table_id'], // Gửi trực tiếp table_id
        }),
      );

      // Đóng loading
      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Thanh toán thành công! Doanh thu đã cập nhật."),
                backgroundColor: Colors.green,
              ),
            );
            // Trả về giá trị true để màn hình danh sách bàn biết cần cập nhật lại
            Navigator.pop(context, true);
          }
        }
      } else {
        throw Exception("Lỗi từ máy chủ: ${response.statusCode}");
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Đóng loading nếu lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi thanh toán: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List details = order['order_details'] ?? [];
    String tableName = order['table'] != null
        ? order['table']['name'].toString()
        : "Bàn ${order['table_id']}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Chi tiết đơn #${order['id'] ?? 0}",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.brown.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Vị trí bàn",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              tableName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        _buildStatusBadge(order['status'] ?? 'pending'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "DANH SÁCH MÓN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Divider(height: 30),

                  details.isEmpty
                      ? const Center(child: Text("Chưa có món nào được chọn"))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: details.length,
                          itemBuilder: (context, index) {
                            final item = details[index];
                            String productName = item['product'] != null
                                ? item['product']['name']
                                : "Sản phẩm";
                            String productImage = item['product'] != null
                                ? item['product']['image']
                                : "cafe_den.png";

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      'assets/images/$productImage',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.coffee,
                                                  color: Colors.brown,
                                                ),
                                              ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          productName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "Số lượng: x${item['quantity']}",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    formatMoney(
                                      double.parse(item['price'].toString()) *
                                          item['quantity'],
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                  const Divider(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TỔNG CỘNG",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatMoney(order['total_amount']),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // --- NÚT THANH TOÁN ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: order['status'] == 'completed'
                    ? null // Nếu đã thanh toán rồi thì khóa nút
                    : () => _handleCheckout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[600],
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  order['status'] == 'completed'
                      ? "ĐÃ THANH TOÁN"
                      : "THANH TOÁN",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'completed'
        ? Colors.green
        : (status == 'pending' ? Colors.orange : Colors.red);
    String text = status == 'completed'
        ? "Hoàn thành"
        : (status == 'pending' ? "Chờ xử lý" : "Đã hủy");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
