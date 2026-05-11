import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class OrderDetailScreen extends StatelessWidget {
  final dynamic order;
  const OrderDetailScreen({super.key, required this.order});

  // Hàm định dạng tiền tệ
  String formatMoney(dynamic amount) {
    if (amount == null) return "0đ";
    try {
      final formatter = NumberFormat("###,###", "vi_VN");
      return "${formatter.format(double.parse(amount.toString()))}đ";
    } catch (e) {
      return "0đ";
    }
  }

  // Hàm xử lý thanh toán
  Future<void> _handleCheckout(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/order/checkout"),
        body: {'table_id': order['table_id'].toString()},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thanh toán thành công!")),
        );
        Navigator.pop(context); // Quay về sơ đồ bàn
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi kết nối khi thanh toán")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dữ liệu từ API trả về có cấu trúc order_details nằm trong order
    List details = order['order_details'] ?? [];
    String tableName = order['table'] != null ? order['table']['name'].toString() : "Bàn ${order['table_id']}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Chi tiết đơn #${order['id'] ?? 0}",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                  // Thông tin Bàn
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Vị trí bàn", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(tableName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        _buildStatusBadge(order['status'] ?? 'pending'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text("DANH SÁCH MÓN",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1.1)),
                  const Divider(height: 30),

                  // Hiển thị danh sách món
                  details.isEmpty
                      ? const Center(child: Text("Chưa có món nào được chọn"))
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: details.length,
                    itemBuilder: (context, index) {
                      final item = details[index];
                      String productName = item['product'] != null ? item['product']['name'] : "Sản phẩm";
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(productName,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  Text("Số lượng: x${item['quantity']}",
                                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ),
                            Text(formatMoney(double.parse(item['price'].toString()) * item['quantity']),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      );
                    },
                  ),

                  const Divider(height: 40),

                  // Tổng cộng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("TỔNG CỘNG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(formatMoney(order['total_amount']),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // NÚT THANH TOÁN DƯỚI CÙNG
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _handleCheckout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text("THANH TOÁN",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'completed' ? Colors.green : (status == 'pending' ? Colors.orange : Colors.red);
    String text = status == 'completed' ? "Hoàn thành" : (status == 'pending' ? "Chờ xử lý" : "Đã hủy");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}