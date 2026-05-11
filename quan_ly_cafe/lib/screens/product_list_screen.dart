import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
      final response = await http.get(Uri.parse("http://10.0.2.2:8000/api/products"));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // Khi ấn nút "+" xanh
  Future<void> addToOrder(int productId) async {
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/order/add-product"),
        body: {
          'table_id': widget.tableId.toString(),
          'product_id': productId.toString(),
          'quantity': '1',
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã thêm món vào bàn"), duration: Duration(milliseconds: 500)),
        );
      }
    } catch (e) {
      print("Lỗi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Bàn ${widget.tableId} - Chọn món"), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const Icon(Icons.coffee_outlined, size: 40),
            title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${p['price']}đ"),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFFB3CFFF), size: 32),
              onPressed: () => addToOrder(p['id']), // Gọi API thêm món
            ),
          );
        },
      ),
    );
  }
}