import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailEditableScreen extends StatefulWidget {
  final dynamic order;
  const OrderDetailEditableScreen({super.key, required this.order});

  @override
  State<OrderDetailEditableScreen> createState() => _OrderDetailEditableScreenState();
}

class _OrderDetailEditableScreenState extends State<OrderDetailEditableScreen> {
  List<dynamic> orderItems = [];

  @override
  void initState() {
    super.initState();
    // Lấy đúng mảng order_details
    var details = widget.order['order_details'];
    if (details != null && details is List) {
      orderItems = List.from(details);
    }
  }

  String formatMoney(dynamic amount) => NumberFormat("###,###", "vi_VN").format(double.tryParse(amount.toString()) ?? 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa đơn hàng")),
      body: ListView.builder(
        itemCount: orderItems.length,
        itemBuilder: (context, index) {
          final item = orderItems[index];
          // SỬA Ở ĐÂY: Lấy tên từ quan hệ product
          String name = (item['product'] != null) ? item['product']['name'] : "Món ăn";
          return ListTile(
            title: Text(name),
            subtitle: Text("${formatMoney(item['price'])}đ"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() { if(item['quantity'] > 1) item['quantity']--; })),
                Text("${item['quantity']}"),
                IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => item['quantity']++)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Lưu thay đổi"),
      ),
    );
  }
}