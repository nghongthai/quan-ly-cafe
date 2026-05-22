import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product_list_screen.dart';
import 'order_detail_editable.dart';

class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({super.key});
  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  List<dynamic> allTables = [];
  List<dynamic> filteredTables = []; // Danh sách hiển thị sau khi lọc
  String filterStatus = "Tất cả";
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
          allTables = json.decode(response.body);
          applyFilter(filterStatus); // Lọc lại theo trạng thái hiện tại
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void applyFilter(String status) {
    setState(() {
      filterStatus = status;
      if (status == "Tất cả") {
        filteredTables = allTables;
      } else if (status == "Sử dụng") {
        filteredTables = allTables.where((t) => t['status'].toString() == "1" || t['status'].toString() == "Sử dụng").toList();
      } else {
        filteredTables = allTables.where((t) => t['status'].toString() == "0" || t['status'].toString() == "Trống").toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text("Sơ đồ bàn", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.blue), onPressed: fetchTables)
        ],
      ),
      body: Column(
        children: [
          // Thanh lọc bàn
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["Tất cả", "Sử dụng", "Còn trống"].map((status) {
                bool isSelected = filterStatus == status;
                return InkWell(
                  onTap: () => applyFilter(status),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(status, style: TextStyle(color: isSelected ? Colors.white : Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ),
          ),

          // Danh sách bàn
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.2,
              ),
              itemCount: filteredTables.length,
              itemBuilder: (context, index) {
                final table = filteredTables[index];
                bool isOccupied = table['status'].toString() == "1" || table['status'].toString() == "Sử dụng";
                double totalAmount = double.tryParse(table['total_amount'].toString()) ?? 0;

                return GestureDetector(
                  onTap: () async {
                    if (isOccupied) {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailEditableScreen(order: table)));
                    } else {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen(tableId: table['id'])));
                    }
                    fetchTables();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isOccupied ? const Color(0xFFD1E2FF) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isOccupied ? Colors.blue : Colors.grey[200]!, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.table_restaurant, color: isOccupied ? Colors.blue : Colors.grey, size: 30),
                        const SizedBox(height: 8),
                        Text("Bàn ${table['name'] ?? table['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (isOccupied)
                          Text("${totalAmount.toInt()}đ", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        Text(isOccupied ? "Đang dùng" : "Còn trống", style: TextStyle(fontSize: 12, color: isOccupied ? Colors.blue : Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}