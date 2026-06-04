import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quan_ly_cafe/screens/api_constants.dart';
import 'package:quan_ly_cafe/screens/shift_detail_screen.dart';

class ShiftHistoryScreen extends StatefulWidget {
  const ShiftHistoryScreen({super.key});

  @override
  State<ShiftHistoryScreen> createState() => _ShiftHistoryScreenState();
}

class _ShiftHistoryScreenState extends State<ShiftHistoryScreen> {
  bool isLoading = true;
  List<dynamic> shifts = [];

  @override
  void initState() {
    super.initState();
    fetchShiftHistory();
  }

  Future<void> fetchShiftHistory() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("${ApiConstants.baseUrl}/shifts/history"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) setState(() => shifts = data['data'] ?? []);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String formatMoney(dynamic amount) => NumberFormat("###,###", "vi_VN").format(double.tryParse(amount.toString()) ?? 0);

  String formatDate(dynamic raw) {
    if (raw == null) return '--';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(raw.toString()).toLocal());
    } catch (_) {
      return raw.toString();
    }
  }

  String userName(dynamic shift) {
    final user = shift['user'];
    if (user is Map && user['name'] != null) return user['name'].toString();
    return 'Nh\u00e2n vi\u00ean #${shift['user_id'] ?? '--'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('L\u1ecbch s\u1eed giao ca', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [IconButton(onPressed: fetchShiftHistory, icon: const Icon(Icons.refresh, color: Color(0xFF1A237E)))],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
          : shifts.isEmpty
              ? const Center(child: Text('Ch\u01b0a c\u00f3 phi\u1ebfu giao ca'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: shifts.length,
                  itemBuilder: (context, index) {
                    final shift = shifts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE7EAF0))),
                      child: ListTile(
                        leading: const Icon(Icons.assignment_turned_in, color: Color(0xFF1A237E)),
                        title: Text('${formatDate(shift['end_time'])} - ${userName(shift)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${formatMoney(shift['total_revenue'])}\u0111 - \u0110\u00e3 \u0111\u00f3ng'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShiftDetailScreen(
                                shiftId: int.tryParse(shift['id'].toString()),
                                shiftData: Map<String, dynamic>.from(shift),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
