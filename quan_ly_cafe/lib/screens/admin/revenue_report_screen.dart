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
  String selectedFilter = 'Ngày'; // Bộ lọc chính: Ngày, Tuần, Tháng
  String selectedSubWeek = 'Tuần 1'; // Bộ lọc phụ khi chọn chế độ Tháng

  bool isLoading = false;
  double totalRevenue = 0;
  int totalOrders = 0;
  List<dynamic> detailedReportList = []; // Danh sách thống kê chi tiết phía dưới

  @override
  void initState() {
    super.initState();
    fetchRevenueReport();
  }

  // Hàm định dạng tiền tệ Việt Nam nhanh
  String formatMoney(dynamic amount) {
    return NumberFormat("###,###", "vi_VN")
        .format(double.tryParse(amount.toString()) ?? 0);
  }

  // Hàm gọi API lấy dữ liệu báo cáo doanh thu theo bộ lọc từ Laravel Backend
  Future<void> fetchRevenueReport() async {
    setState(() => isLoading = true);

    String filterType = selectedFilter.toLowerCase(); // 'ngày', 'tuần', 'tháng'
    String subWeekParam = selectedFilter == 'Tháng' ? selectedSubWeek : '';

    try {
      // Đường dẫn API kết nối tới Laravel Backend
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
      // Tự động sinh dữ liệu mẫu để test giao diện nếu backend chưa kịp xử lý trả dữ liệu
      _generateMockData();
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Tạo dữ liệu giả lập đồng bộ theo từng bộ lọc để test giao diện
  void _generateMockData() {
    setState(() {
      if (selectedFilter == 'Ngày') {
        totalRevenue = 1450000; totalOrders = 24;
        detailedReportList = [
          {'time': '08:00 - 10:00', 'revenue': 450000, 'orders': 8},
          {'time': '11:00 - 13:00', 'revenue': 620000, 'orders': 11},
          {'time': '17:00 - 21:00', 'revenue': 380000, 'orders': 5},
        ];
      } else if (selectedFilter == 'Tuần') {
        totalRevenue = 12800000; totalOrders = 185;
        detailedReportList = [
          {'time': 'Thứ Hai', 'revenue': 1800000, 'orders': 25},
          {'time': 'Thứ Ba', 'revenue': 1500000, 'orders': 22},
          {'time': 'Thứ Tư', 'revenue': 1650000, 'orders': 24},
          {'time': 'Thứ Năm', 'revenue': 1400000, 'orders': 20},
          {'time': 'Thứ Sáu', 'revenue': 2100000, 'orders': 31},
          {'time': 'Thứ Bảy', 'revenue': 2450000, 'orders': 38},
          {'time': 'Chủ Nhật', 'revenue': 1900000, 'orders': 25},
        ];
      } else if (selectedFilter == 'Tháng') {
        totalRevenue = 54200000; totalOrders = 740;
        detailedReportList = [
          {'time': 'Ngày 01/05 - 07/05 ($selectedSubWeek)', 'revenue': 13500000, 'orders': 190},
          {'time': 'Ngày 08/05 - 14/05', 'revenue': 14200000, 'orders': 201},
          {'time': 'Ngày 15/05 - 21/05', 'revenue': 12800000, 'orders': 174},
          {'time': 'Ngày 22/05 - 31/05', 'revenue': 13700000, 'orders': 175},
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          "Báo Cáo Doanh Thu",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 1. THANH BỘ LỌC THỜI GIAN (Ngày, Tuần, Tháng) theo hình vẽ phác thảo
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMainFilterTab('Ngày'),
                    _buildMainFilterTab('Tuần'),
                    _buildMainFilterTab('Tháng'),
                  ],
                ),

                // Nếu chọn Bộ lọc là THÁNG -> Hiện thêm thanh chọn các Tuần con (Tuần 1 -> Tuần 4)
                if (selectedFilter == 'Tháng') ...[
                  const Divider(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Tuần 1', 'Tuần 2', 'Tuần 3', 'Tuần 4'].map((week) {
                        bool isSubSelected = selectedSubWeek == week;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSubWeek = week;
                              fetchRevenueReport();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSubSelected ? const Color(0xFF1A237E).withOpacity(0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSubSelected ? const Color(0xFF1A237E) : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              week,
                              style: TextStyle(
                                color: isSubSelected ? const Color(0xFF1A237E) : Colors.black,
                                fontWeight: isSubSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ]
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 2. KHU VỰC HIỂN THỊ TỔNG DOANH THU & SỐ ĐƠN HÀNG
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tổng Doanh Thu ($selectedFilter)",
                        style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${formatMoney(totalRevenue)} đ",
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const Divider(color: Colors.white24, height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Tổng số đơn hàng", style: TextStyle(color: Colors.white60, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text("$totalOrders đơn", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.trending_up, color: Colors.greenAccent, size: 24),
                          )
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. DANH SÁCH CHI TIẾT BIẾN ĐỘNG DOANH THU
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Chi Tiết Theo Thời Gian",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800]),
                    ),
                    const Icon(Icons.bar_chart, color: Color(0xFF1A237E)),
                  ],
                ),
                const SizedBox(height: 12),

                detailedReportList.isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Không có dữ liệu thống kê"),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: detailedReportList.length,
                  itemBuilder: (context, index) {
                    final item = detailedReportList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['time'].toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${item['orders']} đơn hàng",
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                          Text(
                            "+${formatMoney(item['revenue'])}đ",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
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

  // Widget hiển thị nút chọn bộ lọc chính (Ngày, Tuần, Tháng)
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
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A237E) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}