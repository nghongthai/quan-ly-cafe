import 'package:flutter/material.dart';
import 'table_map_screen.dart'; // 🌟 BƯỚC THÊM: Import để gọi biến tableDataNotifier

class PaymentStaffScreen extends StatefulWidget {
  final String tableName;
  final int totalAmount; // Nhận tổng tiền từ màn hình hóa đơn truyền sang

  const PaymentStaffScreen({
    super.key,
    required this.tableName,
    required this.totalAmount,
  });

  @override
  State<PaymentStaffScreen> createState() => _PaymentStaffScreenState();
}

class _PaymentStaffScreenState extends State<PaymentStaffScreen> {
  String selectedPaymentMethod = 'Tiền mặt'; // Mặc định chọn tiền mặt
  final TextEditingController _receivedMoneyController =
      TextEditingController();
  int receivedMoney = 0;

  @override
  void dispose() {
    _receivedMoneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tính tiền thừa trả khách
    int change = receivedMoney - widget.totalAmount;
    if (change < 0) change = 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Thanh toán - ${widget.tableName}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Khối hiển thị Tổng tiền cần thanh toán
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'TỔNG CẦN THANH TOÁN',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.totalAmount}đ',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Khối chọn Phương thức thanh toán
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPaymentMethod('Tiền mặt', Icons.payments_outlined),
                const SizedBox(width: 12),
                _buildPaymentMethod('Chuyển khoản', Icons.qr_code_2),
              ],
            ),
            const SizedBox(height: 24),

            // Khối nhập Tiền khách đưa (Chỉ hiện khi chọn Tiền mặt)
            if (selectedPaymentMethod == 'Tiền mặt') ...[
              const Text(
                'Tiền khách đưa (VNĐ)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _receivedMoneyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Nhập số tiền khách đưa...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1A237E)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    receivedMoney = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tiền thừa trả khách:',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  Text(
                    '${change > 0 ? change : 0}đ',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Nếu chọn chuyển khoản thì hiển thị ảnh mã QR giả lập
              Center(
                child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Mã QR Ngân Hàng',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),

      // Nút xác nhận thanh toán ở cuối màn hình
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // 🌟 1. CẬP NHẬT TRẠNG THÁI BÀN VỀ TRỐNG TRÊN SƠ ĐỒ
              final currentTables = tableDataNotifier.value;

              // Tìm đúng bàn hiện tại dựa vào tên bàn nhận từ widget
              int tableIndex = currentTables.indexWhere(
                (table) => table['name'] == widget.tableName,
              );

              if (tableIndex != -1) {
                currentTables[tableIndex]['isUsed'] =
                    false; // Chuyển về bàn trống
                currentTables[tableIndex]['amount'] =
                    ''; // Xóa số tiền hiển thị cũ

                // Gán danh sách mới để ValueNotifier thông báo vẽ lại màn hình TableMap
                tableDataNotifier.value = List.from(currentTables);
              }

              // 2. Hiển thị thông báo thành công
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 Thanh toán thành công!'),
                  backgroundColor: Colors.green,
                ),
              );

              // 3. Quay trở về màn hình Sơ đồ bàn (Màn hình đầu tiên của nhân viên)
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'HOÀN TẤT THANH TOÁN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm hỗ trợ vẽ nút chọn phương thức thanh toán
  Widget _buildPaymentMethod(String method, IconData icon) {
    bool isSelected = selectedPaymentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          selectedPaymentMethod = method;
          // Reset tiền khách đưa nếu đổi sang chuyển khoản
          if (method == 'Chuyển khoản') {
            _receivedMoneyController.clear();
            receivedMoney = 0;
          }
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE8EAF6) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF3F51B5) : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF3F51B5) : Colors.grey,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                method,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF3F51B5) : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
