import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const PaymentScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Màu nền xanh nhạt như ảnh
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Thanh toán", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phần thông tin bàn và thời gian
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoBox("Bàn số", orderData['table']['name'].toString()),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("CafeABC", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("Mã đơn: ${orderData['id']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          Text("Ngày: ${DateTime.now().toString().substring(0, 16)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                  const Divider(height: 30),
                  // Danh sách món ăn tóm tắt
                  Expanded(
                    child: ListView.builder(
                      itemCount: orderData['order_details'].length,
                      itemBuilder: (context, index) {
                        final item = orderData['order_details'][index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${item['product']['name']}  x${item['quantity']}"),
                              Text("${item['price']}đ"),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  _buildSummaryRow("Giảm giá", "0%"),
                  _buildSummaryRow("Tổng tiền", "${orderData['total_amount']}đ", isTotal: true),
                  const SizedBox(height: 20),
                  const Text("Phương thức thanh toán", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildPaymentOption("ZaloPay", "assets/zalopay.png"), // Bạn cần thêm ảnh vào assets
                  _buildPaymentOption("MoMo", "assets/momo.png"),
                  _buildPaymentOption("VNPay", "assets/vnpay.png", isSelected: true),
                ],
              ),
            ),
          ),
          // Nút bấm dưới cùng
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("Tiếp tục mua hàng"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Gọi API checkout ở đây để hoàn tất
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[200], padding: const EdgeInsets.all(15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("Thanh toán", style: TextStyle(color: Colors.black)),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10)),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String name, String iconPath, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.payment, color: Colors.blue), // Thay bằng Image.asset nếu có ảnh
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}