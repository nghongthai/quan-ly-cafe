import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'payment_screen.dart'; // ✅ THÊM ĐÚNG FILE THANH TOÁN ĐỂ ĐIỀU HƯỚNG

class OrderDetailEditableScreen extends StatefulWidget {
  final dynamic order;

  const OrderDetailEditableScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailEditableScreen> createState() => _OrderDetailEditableScreenState();
}

class _OrderDetailEditableScreenState extends State<OrderDetailEditableScreen> {
  List<dynamic> orderItems = [];
  bool isLoading = false;
  late int tableId;

  // URL API của Laravel Backend
  final String baseUrl = "http://10.0.2.2:8000/api";

  @override
  void initState() {
    super.initState();
    debugPrint("FULL ORDER DATA: ${widget.order}");

    tableId = widget.order['table_id'] ?? 0;

    // Đọc danh sách món ăn từ đơn hàng
    final rawItems = widget.order['order_details'] ?? widget.order['orderDetails'];
    if (rawItems != null) {
      setState(() {
        orderItems = List<dynamic>.from(rawItems);
      });
    } else {
      debugPrint("CẢNH BÁO: Không tìm thấy order_details.");
    }
  }

  String formatMoney(dynamic amount) {
    return NumberFormat("###,###", "vi_VN").format(double.tryParse(amount.toString()) ?? 0);
  }

  double get totalAmount {
    double total = 0;
    for (var item in orderItems) {
      total += (double.tryParse(item['price'].toString()) ?? 0) *
          (int.tryParse(item['quantity'].toString()) ?? 0);
    }
    return total;
  }

  // Gọi API cập nhật tăng/giảm/xóa món lên Server (GIỮ NGUYÊN)
  Future<void> updateItem(int index, String action) async {
    final item = orderItems[index];
    final productId = item['product_id'];

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/order/update-item"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "table_id": tableId,
          "product_id": productId,
          "action": action,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            if (action == 'increment') {
              orderItems[index]['quantity'] = (orderItems[index]['quantity'] ?? 0) + 1;
            } else if (action == 'decrement') {
              if ((orderItems[index]['quantity'] ?? 1) > 1) {
                orderItems[index]['quantity']--;
              } else {
                orderItems.removeAt(index);
              }
            } else if (action == 'delete') {
              orderItems.removeAt(index);
            }
          });

          if (orderItems.isEmpty) {
            if (mounted) Navigator.pop(context, 'refreshed');
          }
        }
      } else {
        _showError("Lỗi cập nhật: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Không thể kết nối server: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // 🌟 CHỈ THAY ĐỔI NỘI DUNG HÀM NÀY: Chuyển hướng sang màn hình PaymentStaffScreen
  void checkout() {
    if (widget.order == null) return;

    // Chuẩn bị map dữ liệu orderData để truyền sang màn hình thanh toán
    Map<String, dynamic> orderDataForPayment = Map<String, dynamic>.from(widget.order);

    // Đồng bộ lại tổng tiền mới nhất nhỡ có tăng/giảm số lượng món ăn ở trên
    orderDataForPayment['total_amount'] = totalAmount;

    // Đảm bảo cấu trúc map có object 'table' chứa ID bàn giống hệt backend để payment_screen không lỗi
    if (!orderDataForPayment.containsKey('table')) {
      orderDataForPayment['table'] = {
        'id': tableId,
        'name': widget.order['table']?['name'] ?? widget.order['table_name'] ?? 'Bàn $tableId',
      };
    }

    // Thực hiện chuyển hướng sang trang thanh toán của bạn
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentStaffScreen(
          orderData: orderDataForPayment, // Truyền dữ liệu sang constructor nhận dạng Map
        ),
      ),
    ).then((value) {
      // Sau khi xử lý thanh toán xong và back về, đóng luôn màn hình chi tiết này
      if (mounted) {
        Navigator.pop(context, 'checkout');
      }
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Bàn ${widget.order['table']?['name'] ?? tableId}",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          orderItems.isEmpty
              ? const Center(child: Text("Không có sản phẩm nào trong đơn hàng", style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 140),
            itemCount: orderItems.length,
            itemBuilder: (context, index) {
              final item = orderItems[index];
              final product = item['product'];

              String productName = product != null ? (product['name'] ?? "Sản phẩm") : "Sản phẩm";
              double itemTotal = (double.tryParse(item['price'].toString()) ?? 0) * (int.tryParse(item['quantity'].toString()) ?? 0);

              String imageName = product != null ? (product['image'] ?? product['image_url'] ?? "") : "";
              String productId = product != null ? product['id'].toString() : "default";
              String assetPath = "assets/images/default.png";

              if (imageName.isNotEmpty) {
                assetPath = imageName.contains("assets/") ? imageName : "assets/images/$imageName";
              } else {
                assetPath = "assets/images/$productId.png";
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          assetPath,
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 65,
                              height: 65,
                              color: Colors.brown[50],
                              child: Icon(Icons.coffee, color: Colors.brown[400], size: 30),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${formatMoney(item['price'])} đ",
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${formatMoney(itemTotal)} đ",
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: isLoading ? null : () => updateItem(index, 'decrement'),
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 26),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "${item['quantity'] ?? 0}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: isLoading ? null : () => updateItem(index, 'increment'),
                            icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 26),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: isLoading ? null : () => updateItem(index, 'delete'),
                            icon: Icon(Icons.delete_sweep, color: Colors.grey[600], size: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tổng thanh toán:", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(
                      "${formatMoney(totalAmount)} đ",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: (isLoading || orderItems.isEmpty) ? null : checkout,
                icon: const Icon(Icons.payment, size: 20),
                label: const Text("Thanh toán", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  elevation: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}