import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quan_ly_cafe/screens/api_constants.dart';

class ProductListScreen extends StatefulWidget {
  final int tableId;
  const ProductListScreen({super.key, required this.tableId});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      // Lưu ý: Đảm bảo server Laravel của bạn đang chạy (php artisan serve)
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/products"),
      );
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Lỗi tải sản phẩm: $e");
    }
  }

  Future<void> addToOrder(int productId) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/order/add-product"),
        body: {
          'table_id': widget.tableId.toString(),
          'product_id': productId.toString(),
          'quantity': '1',
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đã thêm món vào bàn"),
            duration: Duration(milliseconds: 500),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Lỗi thêm món: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Màu nền nhạt cho hiện đại
      appBar: AppBar(
        title: Text("Bàn ${widget.tableId} - Chọn món"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                // Lấy tên file ảnh từ JSON Laravel trả về
                String imageName = p['image'] ?? 'cafe_den.png';

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    // THAY ĐỔI TẠI ĐÂY: Hiển thị ảnh thay vì Icon
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/$imageName',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        // Nếu không tìm thấy file ảnh trong assets thì hiện icon thay thế
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.coffee, color: Colors.brown),
                        ),
                      ),
                    ),
                    title: Text(
                      p['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "${double.parse(p['price'].toString()).toStringAsFixed(0)}đ",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Color(0xFFB3CFFF),
                        size: 36,
                      ),
                      onPressed: () => addToOrder(p['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
