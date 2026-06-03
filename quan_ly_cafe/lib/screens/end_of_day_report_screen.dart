import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quan_ly_cafe/screens/api_constants.dart';

class EndOfDayReportScreen extends StatefulWidget {
  final int userId;

  const EndOfDayReportScreen({super.key, required this.userId});

  @override
  State<EndOfDayReportScreen> createState() => _EndOfDayReportScreenState();
}

class _EndOfDayReportScreenState extends State<EndOfDayReportScreen> {
  bool isLoading = true;
  Map<String, dynamic> reportData = {};
  bool isClosingShift = false;

  @override
  void initState() {
    super.initState();
    fetchEndOfDayReport();
  }

  // Hàm bốc số liệu thực tế theo thời gian thực từ API Laravel Backend
  Future<void> fetchEndOfDayReport() async {
    try {
      final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/dashboard/end-of-day-report"));
      if (response.statusCode == 200) {
        setState(() {
          reportData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        _loadMockData();
      }
    } catch (e) {
      debugPrint("Lỗi nạp số liệu thực từ hệ thống: $e");
      _loadMockData();
    }
  }

  // Dữ liệu mẫu dự phòng khi mất kết nối mạng hoặc server Laravel chưa bật
  void _loadMockData() {
    setState(() {
      reportData = {
        'tien_mat': 0,
        'chuyen_khoan': 0,
        'the': 0,
        'vi_dien_tu': 0,
        'diem': 0,
        'so_luong_hoa_don': 0,
        'so_luong_san_pham': 0,
        'so_khach': 0,
        'doanh_thu_uoc_tinh': 0
      };
      isLoading = false;
    });
  }

  String formatMoney(dynamic amount) {
    return NumberFormat("###,###", "vi_VN").format(double.tryParse(amount.toString()) ?? 0);
  }

  Future<void> closeShift() async {
    setState(() => isClosingShift = true);
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/shifts/close"),
        headers: {"Accept": "application/json"},
        body: {'user_id': widget.userId.toString()},
      );

      final data = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) && data['status'] == 'success') {
        if (!mounted) return;
        _loadMockData();
        showClosedShiftResult(Map<String, dynamic>.from(data['data']));
      } else {
        _showSnackBar(data['message'] ?? 'Kh\u00f4ng th\u1ec3 \u0111\u00f3ng ca');
      }
    } catch (_) {
      _showSnackBar('Kh\u00f4ng th\u1ec3 k\u1ebft n\u1ed1i \u0111\u1ebfn m\u00e1y ch\u1ee7');
    } finally {
      if (mounted) setState(() => isClosingShift = false);
    }
  }

  void confirmCloseShift() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('\u0110\u00f3ng ca cu\u1ed1i ng\u00e0y'),
        content: const Text(
          'H\u1ec7 th\u1ed1ng s\u1ebd t\u1ef1 t\u00ednh ti\u1ec1n \u0111\u1ea7u ca, doanh thu h\u00f4m nay, t\u1ed5ng \u0111\u01a1n v\u00e0 ti\u1ec1n cu\u1ed1i ca.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('H\u1ee7y'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              closeShift();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E46A3)),
            child: const Text('\u0110\u00f3ng ca', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void showClosedShiftResult(Map<String, dynamic> shift) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('\u0110\u00f3ng ca th\u00e0nh c\u00f4ng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('Ti\u1ec1n \u0111\u1ea7u ca', '${formatMoney(shift['opening_cash'])}\u0111'),
            _buildDialogRow('Doanh thu', '${formatMoney(shift['total_revenue'])}\u0111'),
            _buildDialogRow('T\u1ed5ng \u0111\u01a1n', '${shift['total_orders'] ?? 0} \u0111\u01a1n'),
            _buildDialogRow('Ti\u1ec1n cu\u1ed1i ca', '${formatMoney(shift['closing_cash'])}\u0111'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('\u0110\u00f3ng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          const SizedBox(width: 20),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    String todayStr = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text("Báo Cáo Cuối Ngày", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1E46A3),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E46A3)))
          : RefreshIndicator(
        onRefresh: fetchEndOfDayReport, // Vuốt màn hình từ trên xuống để làm mới số liệu thực tế
        color: const Color(0xFF1E46A3),
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Center(
              child: Text(
                "Ngày báo cáo: $todayStr",
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // 🌟 KHỐI 1: PHƯƠNG THỨC THANH TOÁN (SỐ LIỆU THỰC)
            _buildReportSection(
              title: "Phương thức thanh toán",
              items: [
                _buildReportRow("Tiền mặt", "${formatMoney(reportData['tien_mat'])}đ"),
                _buildReportRow("Chuyển khoản", "${formatMoney(reportData['chuyen_khoan'])}đ"),
                _buildReportRow("Thẻ", "${formatMoney(reportData['the'])}đ"),
                _buildReportRow("Ví điện tử", "${formatMoney(reportData['vi_dien_tu'])}đ"),
                _buildReportRow("Điểm", "${formatMoney(reportData['diem'])}đ"),
              ],
            ),

            // 🌟 KHỐI 2: TỔNG KẾT BÁN HÀNG (SỐ LIỆU THỰC)
            _buildReportSection(
              title: "Tổng kết bán hàng",
              items: [
                _buildReportRow("Hóa đơn", "${reportData['so_luong_hoa_don'] ?? 0} đơn"),
                _buildReportRow("Số lượng sản phẩm", "${reportData['so_luong_san_pham'] ?? 0} món"),
                _buildReportRow("Số khách", "${reportData['so_khach'] ?? 0} lượt"),
                _buildReportRow(
                    "Doanh thu ước tính",
                    "${formatMoney(reportData['doanh_thu_uoc_tinh'])}đ",
                    isBold: true,
                    valueColor: const Color(0xFF1E46A3)
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isClosingShift ? null : confirmCloseShift,
                icon: isClosingShift
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.lock, color: Colors.white),
                label: Text(
                  isClosingShift ? '\u0110ang \u0111\u00f3ng ca...' : '\u0110\u00f3ng ca cu\u1ed1i ng\u00e0y',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E46A3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Khung bo góc trang trí chung
  Widget _buildReportSection({required String title, required List<Widget> items}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E46A3))),
          const Divider(height: 24, thickness: 0.8),
          ...items,
        ],
      ),
    );
  }

  // Dòng thông tin chi tiết (Đã dọn sạch lỗi chính tả màu sắc hệ thống)
  Widget _buildReportRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? Colors.black : Colors.black87
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor ?? (isBold ? Colors.black : Colors.black87), // 🌟 ĐA SỬA LỖI: Trả về màu chữ chuẩn, loại bỏ mã lỗi gây crash ngầm
            ),
          ),
        ],
      ),
    );
  }
}
