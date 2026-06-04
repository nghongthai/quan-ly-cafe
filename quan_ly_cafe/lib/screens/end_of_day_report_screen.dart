import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quan_ly_cafe/screens/api_constants.dart';

class EndOfDayReportScreen extends StatefulWidget {
  final int userId;

  const EndOfDayReportScreen({super.key, required this.userId});

  @override
  State<EndOfDayReportScreen> createState() => _EndOfDayReportScreenState();
}

class _EndOfDayReportScreenState extends State<EndOfDayReportScreen> {
  bool isLoading = true;
  bool isClosingShift = false;
  bool hasOpenShift = false;
  Map<String, dynamic> reportData = {};

  @override
  void initState() {
    super.initState();
    fetchEndOfDayReport();
  }

  Future<void> fetchEndOfDayReport() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/shifts/daily-report?user_id=${widget.userId}"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          hasOpenShift = data['has_open_shift'] == true;
          reportData = Map<String, dynamic>.from(data['data'] ?? {});
        });
      } else {
        resetReport();
      }
    } catch (e) {
      debugPrint('Loi tai bao cao ca: $e');
      resetReport();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void resetReport() {
    reportData = {
      'opening_cash': 1000000,
      'cash_revenue': 0,
      'bank_revenue': 0,
      'total_revenue': 0,
      'closing_cash': 1000000,
      'total_orders': 0,
      'total_products': 0,
    };
    hasOpenShift = false;
  }

  String formatMoney(dynamic amount) {
    return NumberFormat("###,###", "vi_VN").format(double.tryParse(amount.toString()) ?? 0);
  }

  Future<void> closeShift() async {
    if (!hasOpenShift) {
      _showSnackBar('Ch\u01b0a c\u00f3 ca \u0111ang m\u1edf');
      return;
    }

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
        final shift = Map<String, dynamic>.from(data['data']);
        setState(() {
          resetReport();
        });
        showClosedShiftResult(shift);
      } else {
        _showSnackBar(data['message'] ?? 'Kh\u00f4ng th\u1ec3 \u0111\u00f3ng ca');
      }
    } catch (_) {
      _showSnackBar('Kh\u00f4ng th\u1ec3 k\u1ebft n\u1ed1i \u0111\u1ebfn m\u00e1y ch\u1ee7');
    } finally {
      if (mounted) setState(() => isClosingShift = false);
    }
  }

  Future<void> openNewShift(String openingCash) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/shifts/open"),
        headers: {"Accept": "application/json"},
        body: {
          'user_id': widget.userId.toString(),
          'opening_cash': openingCash.replaceAll('.', '').replaceAll(',', ''),
        },
      );

      final data = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) && data['status'] == 'success') {
        _showSnackBar('M\u1edf ca m\u1edbi th\u00e0nh c\u00f4ng');
        fetchEndOfDayReport();
      } else {
        _showSnackBar(data['message'] ?? 'Kh\u00f4ng th\u1ec3 m\u1edf ca m\u1edbi');
        showOpenNewShiftDialog();
      }
    } catch (_) {
      _showSnackBar('Kh\u00f4ng th\u1ec3 k\u1ebft n\u1ed1i \u0111\u1ebfn m\u00e1y ch\u1ee7');
      showOpenNewShiftDialog();
    }
  }

  void showOpenNewShiftDialog() {
    final openingCashController = TextEditingController(text: '1000000');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('M\u1edf ca m\u1edbi'),
        content: TextField(
          controller: openingCashController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Ti\u1ec1n \u0111\u1ea7u ca',
            prefixIcon: Icon(Icons.payments_outlined),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openNewShift(openingCashController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E46A3)),
            child: const Text('M\u1edf ca', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void confirmCloseShift() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('\u0110\u00f3ng ca cu\u1ed1i ng\u00e0y'),
        content: const Text('H\u1ec7 th\u1ed1ng s\u1ebd l\u01b0u phi\u1ebfu b\u00e0n giao ca v\u00e0 kh\u00f3a doanh thu ca n\u00e0y.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('H\u1ee7y')),
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
          children: [
            _dialogRow('Ti\u1ec1n \u0111\u1ea7u ca', '${formatMoney(shift['opening_cash'])}\u0111'),
            _dialogRow('Ti\u1ec1n m\u1eb7t', '${formatMoney(shift['cash_revenue'])}\u0111'),
            _dialogRow('Chuy\u1ec3n kho\u1ea3n', '${formatMoney(shift['bank_revenue'])}\u0111'),
            _dialogRow('T\u1ed5ng doanh thu', '${formatMoney(shift['total_revenue'])}\u0111'),
            _dialogRow('Ti\u1ec1n m\u1eb7t cu\u1ed1i ca', '${formatMoney(shift['closing_cash'])}\u0111'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) showOpenNewShiftDialog();
              });
            },
            child: const Text('\u0110\u00f3ng'),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          const SizedBox(width: 16),
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
    final todayStr = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text('B\u00e1o C\u00e1o Cu\u1ed1i Ng\u00e0y', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1E46A3),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E46A3)))
          : RefreshIndicator(
              onRefresh: fetchEndOfDayReport,
              color: const Color(0xFF1E46A3),
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                    child: Text(
                      'Ng\u00e0y b\u00e1o c\u00e1o: $todayStr',
                      style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildReportSection(
                    title: 'B\u00e0n giao ca',
                    items: [
                      _buildReportRow('Ti\u1ec1n \u0111\u1ea7u ca', '${formatMoney(reportData['opening_cash'])}\u0111'),
                      _buildReportRow('Doanh thu ti\u1ec1n m\u1eb7t', '${formatMoney(reportData['cash_revenue'])}\u0111'),
                      _buildReportRow('Doanh thu chuy\u1ec3n kho\u1ea3n', '${formatMoney(reportData['bank_revenue'])}\u0111'),
                      _buildReportRow('T\u1ed5ng doanh thu', '${formatMoney(reportData['total_revenue'])}\u0111', isBold: true, valueColor: const Color(0xFF1E46A3)),
                      _buildReportRow('S\u1ed1 h\u00f3a \u0111\u01a1n', '${reportData['total_orders'] ?? 0} \u0111\u01a1n'),
                      _buildReportRow('S\u1ed1 s\u1ea3n ph\u1ea9m b\u00e1n ra', '${reportData['total_products'] ?? 0} m\u00f3n'),
                      _buildReportRow('Ti\u1ec1n m\u1eb7t cu\u1ed1i ca', '${formatMoney(reportData['closing_cash'])}\u0111', isBold: true),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isClosingShift ? null : confirmCloseShift,
                      icon: isClosingShift
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.lock, color: Colors.white),
                      label: Text(
                        isClosingShift ? '\u0110ang \u0111\u00f3ng ca...' : '\u0110\u00f3ng ca',
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

  Widget _buildReportRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }
}
