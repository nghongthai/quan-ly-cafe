import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quan_ly_cafe/screens/api_constants.dart';
import 'package:quan_ly_cafe/screens/order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final formatter = NumberFormat("###,###", "vi_VN");
  String selectedTab = "today";
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders("today");
  }

  Future<void> fetchOrders(String filterType) async {
    setState(() {
      isLoading = true;
      selectedTab = filterType;
    });

    try {
      final String url = "${ApiConstants.baseUrl}/list-orders?status=completed&filter=$filterType";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          orders = responseData['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Lịch sử đơn hàng", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton("Hôm nay", "today"),
                _buildFilterButton("Tuần này", "week"),
                _buildFilterButton("Tất cả", "all"),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: () => fetchOrders(selectedTab),
              child: orders.isEmpty
                  ? const Center(child: Text("Không có đơn hàng nào"))
                  : ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: orders.length,
                itemBuilder: (context, index) => _buildOrderItem(orders[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(dynamic order) {
    DateTime createdAt = order['created_at'] != null ? DateTime.parse(order['created_at']).toLocal() : DateTime.now();
    String formattedTime = DateFormat('HH:mm - dd/MM').format(createdAt);
    String tableName = order['table'] != null ? order['table']['name'].toString() : "N/A";

    // 🌟 PHƯƠNG THỨC THANH TOÁN (Giữ nguyên logic cũ, thêm hiển thị)
    final isPaid = (order['status'] ?? '').toString().trim().toLowerCase() == 'completed';
    final paymentMethod = isPaid
        ? (order['payment_method'] ?? 'Ti\u1ec1n m\u1eb7t').toString()
        : 'Ch\u01b0a thanh to\u00e1n';

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailScreen(order: order)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$tableName - #${order['id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(formattedTime, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 5),
                // 🌟 HIỂN THỊ PHƯƠNG THỨC Ở ĐÂY
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                  child: Text(paymentMethod, style: TextStyle(color: Colors.blue.shade800, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${formatter.format(num.parse(order['total_amount'].toString()))}đ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16)),
                const SizedBox(height: 5),
                const Text("Hoàn thành", style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String title, String type) {
    bool isActive = selectedTab == type;
    return GestureDetector(
      onTap: () => fetchOrders(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? Colors.blue : Colors.transparent),
        ),
        child: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}

// 🌟 MÀN HÌNH CHI TIẾT ĐƠN HÀNG (Giữ nguyên cấu trúc)
