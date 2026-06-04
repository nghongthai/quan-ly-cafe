import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quan_ly_cafe/screens/api_constants.dart';

class ShiftDetailScreen extends StatefulWidget {
  final int? shiftId;
  final Map<String, dynamic>? shiftData;

  const ShiftDetailScreen({super.key, this.shiftId, this.shiftData});

  @override
  State<ShiftDetailScreen> createState() => _ShiftDetailScreenState();
}

class _ShiftDetailScreenState extends State<ShiftDetailScreen> {
  Map<String, dynamic>? shift;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    shift = widget.shiftData;
    if (shift == null && widget.shiftId != null) fetchShiftDetail();
  }

  Future<void> fetchShiftDetail() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/shifts/${widget.shiftId}"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) setState(() => shift = Map<String, dynamic>.from(data['data']));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String formatMoney(dynamic amount) => NumberFormat("###,###", "vi_VN").format(double.tryParse(amount.toString()) ?? 0);

  String formatTime(dynamic raw) {
    if (raw == null) return '--';
    try {
      return DateFormat('HH:mm - dd/MM/yyyy').format(DateTime.parse(raw.toString()).toLocal());
    } catch (_) {
      return raw.toString();
    }
  }

  String userName() {
    final user = shift?['user'];
    if (user is Map && user['name'] != null) return user['name'].toString();
    return 'Nh\u00e2n vi\u00ean #${shift?['user_id'] ?? '--'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text('Phi\u1ebfu giao ca #${shift?['id'] ?? widget.shiftId ?? ''}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
          : shift == null
              ? const Center(child: Text('Kh\u00f4ng c\u00f3 d\u1eef li\u1ec7u ca'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _card(Icons.person_outline, 'Nh\u00e2n vi\u00ean', userName()),
                    _card(Icons.play_circle_outline, 'M\u1edf ca', formatTime(shift!['start_time'])),
                    _card(Icons.stop_circle_outlined, '\u0110\u00f3ng ca', formatTime(shift!['end_time'])),
                    _card(Icons.payments_outlined, 'Ti\u1ec1n \u0111\u1ea7u ca', '${formatMoney(shift!['opening_cash'])}\u0111'),
                    _card(Icons.money, 'Doanh thu ti\u1ec1n m\u1eb7t', '${formatMoney(shift!['cash_revenue'])}\u0111'),
                    _card(Icons.account_balance, 'Doanh thu chuy\u1ec3n kho\u1ea3n', '${formatMoney(shift!['bank_revenue'])}\u0111'),
                    _card(Icons.trending_up, 'T\u1ed5ng doanh thu', '${formatMoney(shift!['total_revenue'])}\u0111'),
                    _card(Icons.account_balance_wallet_outlined, 'Ti\u1ec1n m\u1eb7t cu\u1ed1i ca', '${formatMoney(shift!['closing_cash'])}\u0111'),
                    _card(Icons.receipt_long_outlined, 'S\u1ed1 h\u00f3a \u0111\u01a1n', '${shift!['total_orders'] ?? 0} \u0111\u01a1n'),
                    _card(Icons.local_cafe_outlined, 'S\u1ed1 s\u1ea3n ph\u1ea9m', '${shift!['total_products'] ?? 0} m\u00f3n'),
                  ],
                ),
    );
  }

  Widget _card(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE7EAF0))),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1A237E)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.grey))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
