import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:quan_ly_cafe/screens/api_constants.dart';

class PaymentStaffScreen extends StatefulWidget {
  final Map<String, dynamic>
  orderData; // Nhận toàn bộ cục dữ liệu đơn hàng từ Laravel truyền sang

  const PaymentStaffScreen({super.key, required this.orderData});

  @override
  State<PaymentStaffScreen> createState() => _PaymentStaffScreenState();
}

class _PaymentStaffScreenState extends State<PaymentStaffScreen> {
  bool isProcessing = false;
  String selectedPaymentMethod = 'Tiền mặt'; // Mặc định chọn tiền mặt
  final TextEditingController _receivedMoneyController =
      TextEditingController();
  int receivedMoney = 0;

  // Hàm xử lý thanh toán thực tế gọi tới Laravel Backend
  Future<void> processPayment() async {
    setState(() => isProcessing = true);

    try {
      // 10.0.2.2 là localhost dành cho máy ảo Android.
      // Nếu test máy thật, hãy đổi thành IP máy tính của bạn (Ví dụ: 192.168.1.X)
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/checkout"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "order_id": widget.orderData['id'],
          "table_id": widget.orderData['table']['id'],
          "status": "completed", // Gửi trạng thái hoàn thành để lưu doanh thu
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 Thanh toán thành công và đã cập nhật hệ thống!"),
            backgroundColor: Colors.green,
          ),
        );

        // Quay thẳng về màn hình chính đầu tiên (Sơ đồ bàn ăn đã được cập nhật trống)
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        throw Exception("Không thể cập nhật hóa đơn lên hệ thống.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Lỗi thanh toán: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  // Hàm format định dạng tiền tệ Việt Nam (VD: 150,000đ)
  String formatMoney(dynamic amount) {
    return NumberFormat(
      "###,###",
      "vi_VN",
    ).format(double.parse(amount.toString()));
  }

  @override
  void dispose() {
    _receivedMoneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderData;
    // Chuyển tổng số tiền sang kiểu int/double để tính toán tiền thừa
    double totalAmount = double.parse(order['total_amount'].toString());
    double change = receivedMoney - totalAmount;
    if (change < 0) change = 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Thanh toán - ${order['table']['name']}",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Khối tiêu đề hóa đơn
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order['table']['name'].toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B67D9),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "MÃ HÓA ĐƠN",
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          Text(
                            "#${order['id']}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  // Danh sách món ăn
                  const Text(
                    "Chi tiết món đã gọi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order['order_details'].length,
                    itemBuilder: (context, index) {
                      final item = order['order_details'][index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${item['product']['name']}  x${item['quantity']}",
                              style: const TextStyle(fontSize: 15),
                            ),
                            Text(
                              "${formatMoney(item['price'])}đ",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 30),

                  // Tổng tiền cần thu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tổng cộng:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${formatMoney(order['total_amount'])}đ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Color(0xFF3B67D9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Khối lựa chọn phương thức thanh toán
                  const Text(
                    'Phương thức thanh toán',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildPaymentMethodOption(
                        'Tiền mặt',
                        Icons.payments_outlined,
                      ),
                      const SizedBox(width: 12),
                      _buildPaymentMethodOption(
                        'Chuyển khoản',
                        Icons.qr_code_2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Xử lý giao diện động theo từng phương thức
                  if (selectedPaymentMethod == 'Tiền mặt') ...[
                    const Text(
                      'Tiền khách đưa (VNĐ)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _receivedMoneyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        hintText: 'Nhập số tiền...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          receivedMoney = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tiền thừa trả khách:',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          '${formatMoney(change)}đ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Nếu chọn chuyển khoản hiển thị khung quét mã QR
                    Center(
                      child: Container(
                        height: 160,
                        width: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_scanner,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'QUÉT MÃ QR',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Nút bấm hành động xác nhận thanh toán cuối trang
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B67D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'HOÀN TẤT THANH TOÁN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget vẽ các ô chọn phương thức thanh toán dạng nút nhấn tab
  Widget _buildPaymentMethodOption(String method, IconData icon) {
    bool isSelected = selectedPaymentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          selectedPaymentMethod = method;
          if (method == 'Chuyển khoản') {
            _receivedMoneyController.clear();
            receivedMoney = 0;
          }
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B67D9) : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF3B67D9) : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                method,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF3B67D9) : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
