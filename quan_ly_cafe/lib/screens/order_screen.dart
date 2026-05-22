import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class OrderScreen extends StatelessWidget {
  final List<CartItem> cart;
  final int tableId;

  const OrderScreen({super.key, required this.cart, required this.tableId});

  @override
  Widget build(BuildContext context) {
    // Tính tổng tiền dựa trên số lượng và giá của từng món
    double total = cart.fold(0, (sum, item) => sum + (item.price * item.quantity));

    return Scaffold(
      appBar: AppBar(
        title: Text("Giỏ hàng - Bàn $tableId"),
        backgroundColor: Colors.brown[400], // Màu cafe cho chuyên nghiệp
        foregroundColor: Colors.white,
      ),
      body: cart.isEmpty
          ? const Center(
        child: Text(
          "Giỏ hàng đang trống",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    // HIỂN THỊ ẢNH TỪ ASSETS
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/${item.image}',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        // Xử lý lỗi nếu tên file từ Laravel không khớp với assets
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${item.price.toStringAsFixed(0)}đ x ${item.quantity}",
                      style: const TextStyle(color: Colors.brown),
                    ),
                    trailing: Text(
                      "${(item.price * item.quantity).toStringAsFixed(0)}đ",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.redAccent
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Phần tổng thanh toán phía dưới
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tổng cộng:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${total.toStringAsFixed(0)}đ",
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[600],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Gửi dữ liệu đơn hàng sang Laravel API
                    print("Xác nhận đơn hàng cho bàn $tableId");
                  },
                  child: const Text(
                    "XÁC NHẬN GỬI ĐƠN",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}