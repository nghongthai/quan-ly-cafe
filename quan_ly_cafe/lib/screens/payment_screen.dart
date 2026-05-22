import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const PaymentScreen({super.key, required this.orderData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isProcessing = false;

  // Hàm xử lý thanh toán gọi tới Laravel
  Future<void> processPayment() async {
    setState(() => isProcessing = true);

    try {
      // 10.0.2.2 là localhost dành cho máy ảo Android.
      // Nếu dùng máy thật, thay bằng IP máy tính của bạn (VD: 192.168.1.5)
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/checkout"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "order_id": widget.orderData['id'],
          "table_id": widget.orderData['table']['id'],
          "status": "completed", // Chuyển trạng thái để Dashboard tính tiền
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thanh toán thành công!")),
        );

        // Quay lại màn hình chính (Trang chọn bàn)
        // Dùng popUntil để xóa các màn hình trung gian (OrderDetail, Payment...)
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        throw Exception("Không thể cập nhật hóa đơn");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi thanh toán: $e")),
      );
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  String formatMoney(dynamic amount) {
    return NumberFormat("###,###", "vi_VN").format(double.parse(amount.toString()));
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderData;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Xác nhận thanh toán",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoBox("Bàn số", order['table']['name'].toString()),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("HOÁ ĐƠN", style: TextStyle(fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                          Text("#${order['id']}", style: const TextStyle(color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                  const Divider(height: 40),
                  const Text("Chi tiết món ăn", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: order['order_details'].length,
                      itemBuilder: (context, index) {
                        final item = order['order_details'][index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${item['product']['name']}  x${item['quantity']}", style: const TextStyle(fontSize: 15)),
                              Text("${formatMoney(item['price'])}đ", style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  _buildSummaryRow("Tổng cộng", "${formatMoney(order['total_amount'])}đ", isTotal: true),
                  const SizedBox(height: 20),
                  const Text("Phương thức", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildPaymentOption("VNPay / Chuyển khoản", Icons.qr_code_scanner, isSelected: true),
                  _buildPaymentOption("Tiền mặt", Icons.money, isSelected: false),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: const Text("Quay lại"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : processPayment,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B67D9),
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("XÁC NHẬN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3B67D9))),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
          Text(value, style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 22 : 16,
              color: isTotal ? const Color(0xFF3B67D9) : Colors.black
          )),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String name, IconData icon, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: isSelected ? const Color(0xFF3B67D9) : Colors.grey[300]!, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? const Color(0xFFE3F2FD).withOpacity(0.3) : Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF3B67D9) : Colors.grey),
          const SizedBox(width: 12),
          Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          const Spacer(),
          if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF3B67D9), size: 20),
        ],
      ),
    );
  }
}