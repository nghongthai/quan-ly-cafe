import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class OrderScreen extends StatelessWidget {
  final List<CartItem> cart;
  final int tableId;

  const OrderScreen({super.key, required this.cart, required this.tableId});

  @override
  Widget build(BuildContext context) {
    double total = cart.fold(0, (sum, item) => sum + (item.price * item.quantity));

    return Scaffold(
      appBar: AppBar(title: Text("Giỏ hàng - Bàn $tableId")),
      body: cart.isEmpty
          ? const Center(child: Text("Giỏ hàng đang trống"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(cart[index].name),
                subtitle: Text("${cart[index].price}đ x ${cart[index].quantity}"),
                trailing: Text("${cart[index].price * cart[index].quantity}đ"),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey[100]),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tổng cộng:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("${total.toStringAsFixed(0)}đ", style: const TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  onPressed: () {
                    // Logic gọi API thanh toán ở đây
                  },
                  child: const Text("XÁC NHẬN GỬI ĐƠN"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}