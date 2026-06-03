import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quan_ly_cafe/screens/api_constants.dart';

class PaymentStaffScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const PaymentStaffScreen({super.key, required this.orderData});

  @override
  State<PaymentStaffScreen> createState() => _PaymentStaffScreenState();
}

class _PaymentStaffScreenState extends State<PaymentStaffScreen> {
  final TextEditingController _receivedMoneyController = TextEditingController();

  final String bankId = 'BIDV';
  final String accountNo = '4880687152';
  final String accountName = 'NGUYEN HONG THAI';

  bool isProcessing = false;
  bool isQrGenerated = false;
  bool isWaitingSepay = false;
  bool hasShownAutoSuccess = false;
  int receivedMoney = 0;
  String selectedPaymentMethod = 'Tiền mặt';
  String qrUrl = '';
  Timer? _paymentStatusTimer;

  String get paymentCode => 'CAFE${widget.orderData['id']}';

  Future<void> processPayment() async {
    setState(() => isProcessing = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/order/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id': widget.orderData['id'],
          'table_id': widget.orderData['table']['id'],
          'status': 'completed',
          'payment_method': selectedPaymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        _handlePaymentSuccess('Thanh toán thành công và đã cập nhật hệ thống!');
      } else {
        throw Exception('Máy chủ trả về mã ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi thanh toán: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  Future<void> _checkSepayPaymentStatus() async {
    if (hasShownAutoSuccess) return;

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/order/${widget.orderData['id']}/payment-status'),
      );

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] == 'completed') {
        hasShownAutoSuccess = true;
        _paymentStatusTimer?.cancel();
        _handlePaymentSuccess('Đã nhận chuyển khoản Sepay. Hóa đơn hoàn tất!');
      }
    } catch (_) {
      // Polling sẽ thử lại ở lượt kế tiếp.
    }
  }

  void _generateSepayQr() {
    final amount = double.parse(widget.orderData['total_amount'].toString()).toInt();
    final query = Uri(queryParameters: {
      'acc': accountNo,
      'bank': bankId,
      'amount': amount.toString(),
      'des': paymentCode,
    }).query;

    setState(() {
      qrUrl = 'https://qr.sepay.vn/img?$query';
      isQrGenerated = true;
      isWaitingSepay = true;
    });

    _paymentStatusTimer?.cancel();
    _paymentStatusTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkSepayPaymentStatus(),
    );
    _checkSepayPaymentStatus();
  }

  void _handlePaymentSuccess(String message) {
    if (!mounted) return;

    _paymentStatusTimer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
    Navigator.pop(context, 'checkout');
  }

  String formatMoney(dynamic amount) {
    return NumberFormat('###,###', 'vi_VN').format(double.parse(amount.toString()));
  }

  @override
  void dispose() {
    _paymentStatusTimer?.cancel();
    _receivedMoneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderData;
    final totalAmount = double.parse(order['total_amount'].toString());
    var change = receivedMoney - totalAmount;
    if (change < 0) change = 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thanh toán - ${order['table']['name']}',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order['table']['name'].toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B67D9),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'MÃ HÓA ĐƠN',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          Text(
                            '#${order['id']}',
                            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  const Text(
                    'Chi tiết món đã gọi',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order['order_details'].length,
                    itemBuilder: (context, index) {
                      final item = order['order_details'][index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item['product']['name']}  x${item['quantity']}',
                              style: const TextStyle(fontSize: 15),
                            ),
                            Text(
                              '${formatMoney(item['price'])}đ',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${formatMoney(order['total_amount'])}đ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Color(0xFF3B67D9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Phương thức thanh toán',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildPaymentMethodOption('Tiền mặt', Icons.payments_outlined),
                      const SizedBox(width: 12),
                      _buildPaymentMethodOption('Chuyển khoản', Icons.qr_code_2),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (selectedPaymentMethod == 'Tiền mặt')
                    _buildCashPayment(change)
                  else
                    _buildSepayPayment(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B67D9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          selectedPaymentMethod == 'Chuyển khoản'
                              ? 'XÁC NHẬN THỦ CÔNG'
                              : 'HOÀN TẤT THANH TOÁN',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashPayment(double change) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiền khách đưa (VNĐ)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _receivedMoneyController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            hintText: 'Nhập số tiền...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onChanged: (value) {
            setState(() {
              receivedMoney = int.tryParse(value) ?? 0;
            });
          },
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tiền thừa trả khách:', style: TextStyle(fontSize: 15)),
            Text(
              '${formatMoney(change)}đ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSepayPayment() {
    return Column(
      children: [
        Center(
          child: Container(
            height: 210,
            width: 210,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: isQrGenerated
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      qrUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF3B67D9)));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Text('Không tải được mã QR', style: TextStyle(fontSize: 12)));
                      },
                    ),
                  )
                : const Center(child: CircularProgressIndicator(color: Color(0xFF3B67D9))),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildTransferInfo('Ngân hàng', bankId),
              _buildTransferInfo('Số tài khoản', accountNo),
              _buildTransferInfo('Chủ tài khoản', accountName),
              _buildTransferInfo('Nội dung', paymentCode),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: isWaitingSepay
                  ? const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B67D9))
                  : const Icon(Icons.check_circle, color: Colors.green, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'Đang chờ Sepay xác nhận chuyển khoản',
              style: TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransferInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(String method, IconData icon) {
    final isSelected = selectedPaymentMethod == method;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPaymentMethod = method;
            hasShownAutoSuccess = false;

            if (method == 'Chuyển khoản') {
              _receivedMoneyController.clear();
              receivedMoney = 0;
            } else {
              isQrGenerated = false;
              isWaitingSepay = false;
              qrUrl = '';
              _paymentStatusTimer?.cancel();
            }
          });

          if (method == 'Chuyển khoản') {
            _generateSepayQr();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B67D9) : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF3B67D9) : Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                method,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF3B67D9) : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
