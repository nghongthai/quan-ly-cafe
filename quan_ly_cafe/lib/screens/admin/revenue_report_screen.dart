import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quan_ly_cafe/screens/api_constants.dart';

class RevenueReportScreen extends StatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  String selectedFilter = 'Ngày';
  String selectedSubWeek = 'Tuần 1';

  bool isLoading = false;
  double totalRevenue = 0;
  int totalOrders = 0;
  List<dynamic> detailedReportList = [];

  @override
  void initState() {
    super.initState();
    fetchRevenueReport();
  }

  String formatMoney(dynamic amount) {
    return NumberFormat("###,###", "vi_VN")
        .format(double.tryParse(amount.toString()) ?? 0);
  }

  Future<void> fetchRevenueReport() async {
    setState(() => isLoading = true);
    String filterType = selectedFilter.toLowerCase();
    String subWeekParam = selectedFilter == 'Tháng' ? selectedSubWeek : '';

    try {
      final url = Uri.parse("${ApiConstants.baseUrl}/dashboard/revenue-report?type=$filterType&sub_week=$subWeekParam");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalRevenue = double.tryParse(data['total_revenue'].toString()) ?? 0;
          totalOrders = int.tryParse(data['total_orders'].toString()) ?? 0;
          detailedReportList = data['details'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải báo cáo doanh thu: $e");
      _generateMockData();
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _generateMockData() {
    String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      if (selectedFilter == 'Ngày') {
        totalRevenue = 1450000; totalOrders = 24;
        detailedReportList = [
          {'time': '08:00 - 10:00', 'revenue': 450000, 'orders': 8, 'date': todayStr},
          {'time': '09:00 - 10:00', 'revenue': 946000, 'orders': 9, 'date': todayStr},
          {'time': '11:00 - 13:00', 'revenue': 620000, 'orders': 11, 'date': todayStr},
        ];
      } else if (selectedFilter == 'Tuần') {
        totalRevenue = 12800000; totalOrders = 185;
        detailedReportList = [
          {'time': 'Thứ Hai', 'revenue': 1800000, 'orders': 25, 'date': '2026-06-01'},
          {'time': 'Thứ Ba', 'revenue': 1500000, 'orders': 22, 'date': '2026-06-02'},
          {'time': 'Thứ Tư', 'revenue': 1650000, 'orders': 24, 'date': '2026-06-03'},
        ];
      } else {
        totalRevenue = 54200000; totalOrders = 740;
        detailedReportList = [
          {'time': 'Thứ Hai (01/06)', 'revenue': 1500000, 'orders': 19, 'date': '2026-06-01'},
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Báo Cáo Doanh Thu", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMainFilterTab('Ngày'),
                _buildMainFilterTab('Tuần'),
                _buildMainFilterTab('Tháng'),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tổng Doanh Thu ($selectedFilter)", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text("${formatMoney(totalRevenue)} đ", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      const Divider(color: Colors.white24, height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tổng số: $totalOrders đơn", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const Icon(Icons.trending_up, color: Colors.greenAccent, size: 24)
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Chi Tiết Theo Thời Gian", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800])),
                    const Icon(Icons.bar_chart, color: Color(0xFF1A237E)),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: detailedReportList.length,
                  itemBuilder: (context, index) {
                    final item = detailedReportList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          String targetDate = item['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
                          Navigator.push(context, MaterialPageRoute(builder: (context) => OrderListByDateScreen(date: targetDate)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['time'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text("${item['orders']} đơn hàng", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("+${formatMoney(item['revenue'])}đ", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFilterTab(String title) {
    bool isSelected = selectedFilter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = title;
          fetchRevenueReport();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF1A237E) : Colors.grey[100], borderRadius: BorderRadius.circular(20)),
        child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}

// ============================================================================
// 🌟 MÀN HÌNH 1: DANH SÁCH ĐƠN HÀNG TRONG NGÀY (ĐÃ SỬA LỖI MÚI GIỜ)
// ============================================================================
class OrderListByDateScreen extends StatefulWidget {
  final String date;
  const OrderListByDateScreen({super.key, required this.date});

  @override
  State<OrderListByDateScreen> createState() => _OrderListByDateScreenState();
}

class _OrderListByDateScreenState extends State<OrderListByDateScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrdersByDate();
  }

  Future<void> fetchOrdersByDate() async {
    try {
      final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/dashboard/orders-by-date?date=${widget.date}"));
      if (response.statusCode == 200) {
        setState(() {
          orders = json.decode(response.body);
          isLoading = false;
        });
      } else {
        _generateMockOrders();
      }
    } catch (e) {
      _generateMockOrders();
    }
  }

  void _generateMockOrders() {
    setState(() {
      orders = [
        {
          "id": 10,
          "total_amount": 20000,
          "payment_method": "Chuyển khoản",
          "updated_at": "${widget.date}T09:56:00.000000Z",
          "table": {"name": "Bàn 4"},
          "order_details": [
            {"product": {"name": "Cafe Đen", "image": "cafe_den.png"}, "quantity": 1, "price": 20000}
          ]
        }
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text("Hóa đơn ngày ${widget.date}"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
          : orders.isEmpty
          ? const Center(child: Text("Không có đơn hàng nào."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          String method = order['payment_method'] ?? 'Tiền mặt';

          // 🌟 SỬA GIỜ TẠI ĐÂY: Thêm .toLocal() để hiển thị chuẩn giờ Việt Nam ngoài danh sách
          String orderTime = "00:00";
          try {
            DateTime parsedTime = DateTime.parse(order['updated_at']).toLocal();
            orderTime = DateFormat('HH:mm').format(parsedTime);
          } catch (_) {}

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailReportScreen(orderData: order)));
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Hóa đơn #${order['id']} ($orderTime)", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("${NumberFormat("###,###", "vi_VN").format(double.parse(order['total_amount'].toString()))}đ", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text("Vị trí: ${order['table']['name']} | $method"),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// 🌟 MÀN HÌNH 2: CHI TIẾT ĐƠN HÀNG (ĐÃ FIX GIỜ + THÊM ẢNH SẢN PHẨM)
// ============================================================================
class OrderDetailReportScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;
  const OrderDetailReportScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    List<dynamic> details = orderData['order_details'] ?? [];
    String paymentMethod = orderData['payment_method'] ?? 'Tiền mặt';

    // 🌟 1. SỬA LỖI SAI GIỜ: Dùng .toLocal() để chuyển đổi giờ máy chủ về đúng giờ điện thoại
    String orderTimeDetail = "00:00 - dd/MM/2026";
    try {
      DateTime parsedTime = DateTime.parse(orderData['updated_at']).toLocal();
      orderTimeDetail = DateFormat('HH:mm - dd/MM/yyyy').format(parsedTime);
    } catch (_) {}

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text("Chi tiết đơn #${orderData['id']}"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Khu vực: ${orderData['table']['name']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text("Giờ hoàn tất: $orderTimeDetail", style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const Divider(height: 30),

              const Text("Danh sách món đã dùng:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: details.length,
                itemBuilder: (context, index) {
                  final item = details[index];
                  double price = double.parse(item['price'].toString());
                  int qty = int.parse(item['quantity'].toString());

                  // Lấy tên ảnh từ DB, nếu không có lấy ảnh mặc định
                  String imgName = item['product']['image'] ?? 'cafe_den.png';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // 🌟 2. SỬA LỖI KHÔNG HIỆN ẢNH: Thêm ô hiển thị hình ảnh thu nhỏ của món ăn ở đây
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            "assets/images/$imgName",
                            width: 40, height: 40, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Nếu lỗi đường dẫn ảnh asset, tự hiện Icon cốc cafe thay thế không sợ crash
                              return Container(
                                width: 40, height: 40, color: Colors.grey[200],
                                child: const Icon(Icons.coffee, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text("${item['product']['name']}  x$qty", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        ),
                        Text("${NumberFormat("###,###", "vi_VN").format(price)}đ"),
                      ],
                    ),
                  );
                },
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tổng doanh thu đơn:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("${NumberFormat("###,###", "vi_VN").format(double.parse(orderData['total_amount'].toString()))}đ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF1A237E))),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Phương thức thanh toán:", style: TextStyle(fontSize: 14)),
                  Chip(
                    avatar: Icon(paymentMethod == 'Tiền mặt' ? Icons.payments : Icons.qr_code, size: 14, color: Colors.white),
                    label: Text(paymentMethod, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    backgroundColor: paymentMethod == 'Tiền mặt' ? Colors.amber[700] : Colors.blue[700],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}