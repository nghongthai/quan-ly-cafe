import 'package:flutter/material.dart';
import 'payment_staff_screen.dart';

class OrderSummaryScreen extends StatefulWidget {
  final String tableName;

  const OrderSummaryScreen({super.key, required this.tableName});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  // Mock data danh sách các món nhân viên đã chọn từ màn hình trước chuyển sang
  final List<Map<String, dynamic>> selectedItems = [
    {
      'name': 'Cà phê sữa đá',
      'price': 30000,
      'quantity': 2,
      'note': 'Ít sữa, nhiều đá',
    },
    {'name': 'Bạc xỉu', 'price': 35000, 'quantity': 1, 'note': ''},
    {
      'name': 'Trà đào cam sả',
      'price': 45000,
      'quantity': 1,
      'note': 'Không lấy đào',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Tính toán tổng tiền hóa đơn
    int subTotal = selectedItems.fold(
      0,
      (sum, item) => sum + (item['price'] as int) * (item['quantity'] as int),
    );
    int tax = (subTotal * 0.08)
        .round(); // Giả định VAT 8% theo chuẩn hóa đơn Figma
    int totalAmount = subTotal + tax;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Xác nhận - ${widget.tableName}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // 1. Danh sách món ăn đã chọn
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: selectedItems.length,
              itemBuilder: (context, index) {
                final item = selectedItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            '${item['price'] * item['quantity']}đ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Đơn giá: ${item['price']}đ',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      // Thanh điều chỉnh số lượng và ghi chú bám sát giao diện Figma
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.edit_note,
                                color: Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['note'].isEmpty
                                    ? 'Thêm ghi chú...'
                                    : item['note'],
                                style: TextStyle(
                                  color: item['note'].isEmpty
                                      ? Colors.grey[400]
                                      : Colors.amber[800],
                                  fontSize: 13,
                                  fontStyle: item['note'].isEmpty
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildQuantityButton(Icons.remove, () {
                                setState(() {
                                  if (item['quantity'] > 1) item['quantity']--;
                                });
                              }),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  '${item['quantity']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              _buildQuantityButton(Icons.add, () {
                                setState(() {
                                  item['quantity']++;
                                });
                              }),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 2. Khối tính toán tổng tiền (Phần Bottom Sheet cố định)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tạm tính',
                      style: TextStyle(color: Colors.black54),
                    ),
                    Text(
                      '$subTotalđ',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Thuế VAT (8%)',
                      style: TextStyle(color: Colors.black54),
                    ),
                    Text(
                      '$taxđ',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TỔNG CỘNG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '$totalAmountđ',
                      style: const TextStyle(
                        color: Color(0xFF1A237E),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Nút hành động gửi thông tin xuống bếp hành động nhanh
                // Chia làm 2 nút: Lưu bàn và Thanh toán
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã gửi đơn xuống bếp!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF1A237E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'LƯU BÀN',
                          style: TextStyle(
                            color: Color(0xFF1A237E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Điều hướng sang màn hình Thanh toán, truyền tên bàn và tổng tiền sang
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentStaffScreen(
                                tableName: widget.tableName,
                                totalAmount: totalAmount,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'THANH TOÁN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.black54),
      ),
    );
  }
}
