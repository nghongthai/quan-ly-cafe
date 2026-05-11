import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product_list_screen.dart';
import 'order_detail_screen.dart';

class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({super.key});
  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  List<dynamic> tables = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTables();
  }

  Future<void> fetchTables() async {
    try {
      final response = await http.get(Uri.parse("http://10.0.2.2:8000/api/tables"));
      if (response.statusCode == 200) {
        setState(() {
          tables = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text("Sơ đồ bàn",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue),
              onPressed: fetchTables,
            )
          ],
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: "Tất cả"),
              Tab(text: "Sử dụng"),
              Tab(text: "Còn trống"),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.2,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            final table = tables[index];

            // --- SỬA LOGIC KIỂM TRA TRẠNG THÁI ---
            // Kiểm tra cả số 1, chuỗi "1" hoặc chữ "Sử dụng" để đảm bảo luôn nhận diện đúng
            bool isOccupied = table['status'].toString() == "1" || table['status'].toString() == "Sử dụng";

            // --- ÉP KIỂU TIỀN TỆ AN TOÀN ---
            double totalAmount = double.tryParse(table['total_amount'].toString()) ?? 0;

            return GestureDetector(
              onTap: () async {
                if (isOccupied) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailScreen(
                        order: table['active_order'] ?? {
                          'id': table['order_id'] ?? 0,
                          'table': table,
                          'status': 'pending',
                          'total_amount': totalAmount,
                          'order_details': table['order_details'] ?? [],
                        },
                      ),
                    ),
                  );
                } else {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductListScreen(tableId: table['id']),
                    ),
                  );
                }
                fetchTables();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isOccupied ? const Color(0xFFD1E2FF) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isOccupied ? Colors.blue : Colors.grey[200]!,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.table_restaurant,
                      color: isOccupied ? Colors.blue : Colors.grey,
                      size: 30,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Bàn ${table['name'] ?? table['id']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    // --- HIỂN THỊ GIÁ TIỀN ---
                    // Chỉ cần bàn đang sử dụng là hiện tiền, không check > 0 để dễ debug
                    if (isOccupied)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 2),
                        child: Text(
                          "${totalAmount.toInt()}đ", // Dùng toInt() để bỏ số .0
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),

                    Text(
                      isOccupied ? "Đang dùng" : "Còn trống",
                      style: TextStyle(
                        fontSize: 12,
                        color: isOccupied ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}