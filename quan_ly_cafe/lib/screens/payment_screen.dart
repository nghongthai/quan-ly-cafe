import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:quan_ly_cafe/screens/api_constants.dart';

class PaymentStaffScreen extends StatefulWidget {
  final Map<String, dynamic> orderData; // Nhận toàn bộ cục dữ liệu đơn hàng từ Laravel truyền sang

  const PaymentStaffScreen({super.key, required this.orderData});

  @override
  State<PaymentStaffScreen> createState() => _PaymentStaffScreenState();
}

class _PaymentStaffScreenState extends State<PaymentStaffScreen> {
  bool isProcessing = false;
  String selectedPaymentMethod = 'Tiền mặt'; // Mặc định chọn tiền mặt
  final TextEditingController _receivedMoneyController = TextEditingController();
  int receivedMoney = 0;

  // 🌟 ĐÃ ĐỒNG BỘ: Cấu hình thông tin tài khoản VietQR của bạn
  final String bankId = "BIDV";
  final String accountNo = "4880687152";
  final String accountName = "NGUYEN HONG THAI";

  bool isQrGenerated = false;
  String qrUrl = "";

  // Hàm xử lý thanh toán thực tế gọi tới Laravel Backend
  Future<void> processPayment() async {
    setState(() => isProcessing = true);

    try {
      // 🌟 ĐÃ SỬA: Đổi URL thành /order/checkout để khớp hoàn toàn với Backend Laravel
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/order/checkout"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "order_id": widget.orderData['id'],
          "table_id": widget.orderData['table']['id'],
          "status": "completed",
          "payment_method": selectedPaymentMethod, // 🌟 ĐÃ BỔ SUNG: Truyền phương thức thanh toán lên Backend
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

        // Quay lại màn hình trước đó (Sơ đồ phòng bàn)
        Navigator.pop(context);
      } else {
        throw Exception("Mã phản hồi từ máy chủ: ${response.statusCode}. Không thể cập nhật hóa đơn.");
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
    return NumberFormat("###,###", "vi_VN").format(double.parse(amount.toString()));
  }

  @override
  void dispose() {
    _receivedMoneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderData;
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              style: const TextStyle(fontWeight: FontWeight.w500),
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
                      _buildPaymentMethodOption('Tiền mặt', Icons.payments_outlined),
                      const SizedBox(width: 12),
                      _buildPaymentMethodOption('Chuyển khoản', Icons.qr_code_2),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Hiển thị form động tùy theo phương thức chọn lựa
                  if (selectedPaymentMethod == 'Tiền mặt') ...[
                    const Text(
                      'Tiền khách đưa (VNĐ)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _receivedMoneyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        hintText: 'Nhập số tiền...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        const Text('Tiền thừa trả khách:', style: TextStyle(fontSize: 15)),
                        Text(
                          '${formatMoney(change)}đ',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Hiển thị ô quét mã VietQR động
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          final String orderId = order['id'].toString();
                          final int amount = totalAmount.toInt();
                          final String description = Uri.encodeComponent("Thanh toan don hang $orderId");
                          final String encodedName = Uri.encodeComponent(accountName);

                          setState(() {
                            qrUrl = "https://img.vietqr.io/image/$bankId-$accountNo-qr_only.jpg?amount=$amount&addInfo=$description&accountName=$encodedName";
                            isQrGenerated = true;
                          });
                        },
                        child: Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.grey[300]!, width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: isQrGenerated
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              qrUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(color: Color(0xFF3B67D9)),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Text("Lỗi kết nối ảnh QR", style: TextStyle(fontSize: 12)),
                                );
                              },
                            ),
                          )
                              : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_scanner, size: 44, color: Colors.grey[600]),
                              const SizedBox(height: 10),
                              const Text(
                                'ẤN ĐỂ TẠO MÃ QR',
                                style: TextStyle(
                                  color: Color(0xFF3B67D9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
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

            // Nút bấm xác nhận thanh toán thủ công luôn mở rộng ở dưới cùng màn hình
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B67D9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'HOÀN TẤT THANH TOÁN',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị tab chọn phương thức thanh toán dạng nút bấm nhấn tab
  Widget _buildPaymentMethodOption(String method, IconData icon) {
    bool isSelected = selectedPaymentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          selectedPaymentMethod = method;
          if (method == 'Chuyển khoản') {
            _receivedMoneyController.clear();
            receivedMoney = 0;
          } else {
            isQrGenerated = false;
            qrUrl = "";
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
              Icon(icon, color: isSelected ? const Color(0xFF3B67D9) : Colors.grey, size: 20),
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