import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quan_ly_cafe/screens/api_constants.dart';
// Import file chi tiết
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  String formatMoney(dynamic amount) {
    if (amount == null) return "0đ";
    final formatter = NumberFormat("###,###", "vi_VN");
    return "${formatter.format(double.parse(amount.toString()))}đ";
  }

  Future<List<dynamic>> fetchOrders(String status) async {
    try {
      // URL gọi API lấy danh sách đơn hàng từ Backend Laravel
      final String url =
          "${ApiConstants.baseUrl}/list-orders?status=$status&filter=all";
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      debugPrint("Lỗi kết nối API: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          title: const Text(
            "Đơn hàng",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Tất cả"),
              Tab(text: "Chờ xử lý"),
              Tab(text: "Hoàn thành"),
              Tab(text: "Đã huỷ"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildOrderTab("all"),
            buildOrderTab("pending"),
            buildOrderTab("completed"),
            buildOrderTab("cancelled"),
          ],
        ),
      ),
    );
  }

  Widget buildOrderTab(String status) {
    return FutureBuilder<List<dynamic>>(
      key: ValueKey(status),
      future: fetchOrders(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? [];
        if (orders.isEmpty) return _buildEmptyState();

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) => _buildOrderItem(orders[index]),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 70,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            "Chưa có đơn hàng nào",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(dynamic order) {
    String tableName = order['table'] != null
        ? order['table']['name'].toString()
        : "N/A";

    return GestureDetector(
      onTap: () {
        // Chuyển sang màn hình chi tiết và truyền biến 'order'
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Đơn #${order['id']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Bàn: $tableName",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(order['status'] ?? 'pending'),
                const SizedBox(height: 8),
                Text(
                  formatMoney(order['total_amount']),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'completed'
        ? Colors.green
        : (status == 'pending' ? Colors.orange : Colors.red);
    String text = status == 'completed'
        ? "Hoàn thành"
        : (status == 'pending' ? "Chờ xử lý" : "Đã hủy");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
