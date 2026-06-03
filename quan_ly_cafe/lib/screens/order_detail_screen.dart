import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  final dynamic order;

  const OrderDetailScreen({super.key, required this.order});

  String _formatMoney(dynamic amount) {
    final value = double.tryParse(amount.toString()) ?? 0;
    return '${NumberFormat("###,###", "vi_VN").format(value)}\u0111';
  }

  String _formatTime(dynamic rawTime) {
    try {
      final parsed = DateTime.parse(rawTime.toString()).toLocal();
      return DateFormat('HH:mm - dd/MM/yyyy').format(parsed);
    } catch (_) {
      return 'Kh\u00f4ng r\u00f5';
    }
  }

  String _tableName() {
    final table = order['table'];
    if (table is Map && table['name'] != null) return table['name'].toString();
    return 'B\u00e0n ${order['table_id'] ?? '--'}';
  }

  List<dynamic> _details() {
    final data = order['order_details'] ?? order['orderDetails'];
    if (data is List) return data;
    return [];
  }

  String _statusText(dynamic status) {
    final value = (status ?? '').toString().trim().toLowerCase();
    if (value == 'completed') return 'Ho\u00e0n th\u00e0nh';
    if (value == 'pending') return 'Ch\u1edd x\u1eed l\u00fd';
    if (value == 'cancelled') return '\u0110\u00e3 h\u1ee7y';
    return value.isEmpty ? 'Kh\u00f4ng r\u00f5' : value;
  }

  Color _statusColor(dynamic status) {
    final value = (status ?? '').toString().trim().toLowerCase();
    if (value == 'completed') return const Color(0xFF16A34A);
    if (value == 'pending') return const Color(0xFFF59E0B);
    if (value == 'cancelled') return const Color(0xFFEF4444);
    return const Color(0xFF64748B);
  }

  String _productName(dynamic item) {
    final product = item['product'];
    if (product is Map && product['name'] != null) return product['name'].toString();
    return 'S\u1ea3n ph\u1ea9m';
  }

  String _productImage(dynamic item) {
    final product = item['product'];
    if (product is Map) {
      final image = product['image'] ?? product['image_url'];
      if (image != null && image.toString().isNotEmpty) {
        return image.toString();
      }
    }
    return '';
  }

  int _quantity(dynamic item) {
    return int.tryParse((item['quantity'] ?? 0).toString()) ?? 0;
  }

  double _price(dynamic item) {
    return double.tryParse((item['price'] ?? 0).toString()) ?? 0;
  }

  bool _isPaid() {
    return (order['status'] ?? '').toString().trim().toLowerCase() == 'completed';
  }

  @override
  Widget build(BuildContext context) {
    final details = _details();
    final statusColor = _statusColor(order['status']);
    final paymentMethod = _isPaid()
        ? (order['payment_method'] ?? 'Ti\u1ec1n m\u1eb7t').toString()
        : 'Ch\u01b0a thanh to\u00e1n';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          'Chi ti\u1ebft \u0111\u01a1n #${order['id'] ?? '--'}',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _InfoCard(
                  rows: [
                    _InfoRowData(
                      icon: Icons.table_restaurant_outlined,
                      label: 'B\u00e0n',
                      value: _tableName(),
                    ),
                    _InfoRowData(
                      icon: Icons.verified_user_outlined,
                      label: 'Tr\u1ea1ng th\u00e1i',
                      value: _statusText(order['status']),
                      valueColor: statusColor,
                    ),
                    _InfoRowData(
                      icon: Icons.payments_outlined,
                      label: 'Ph\u01b0\u01a1ng th\u1ee9c',
                      value: paymentMethod,
                    ),
                    _InfoRowData(
                      icon: Icons.schedule_outlined,
                      label: 'Th\u1eddi gian',
                      value: _formatTime(order['updated_at'] ?? order['created_at']),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'Danh s\u00e1ch m\u00f3n',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (details.isEmpty)
                  const _EmptyOrderItems()
                else
                  ...details.map((item) {
                    final quantity = _quantity(item);
                    final price = _price(item);
                    return _OrderItemCard(
                      name: _productName(item),
                      imageName: _productImage(item),
                      quantity: quantity,
                      unitPrice: _formatMoney(price),
                      lineTotal: _formatMoney(price * quantity),
                    );
                  }),
              ],
            ),
          ),
          _TotalBar(total: _formatMoney(order['total_amount'])),
        ],
      ),
    );
  }
}

class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRowData({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRowData> rows;

  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _InfoRow(row: rows[i]),
            if (i != rows.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final _InfoRowData row;

  const _InfoRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(row.icon, color: const Color(0xFF2563EB), size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            row.label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ),
        Flexible(
          child: Text(
            row.value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: row.valueColor ?? const Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  final String name;
  final String imageName;
  final int quantity;
  final String unitPrice;
  final String lineTotal;

  const _OrderItemCard({
    required this.name,
    required this.imageName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = imageName.isEmpty
        ? ''
        : (imageName.startsWith('assets/') ? imageName : 'assets/images/$imageName');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: assetPath.isEmpty
                ? const _ProductImageFallback()
                : Image.asset(
                    assetPath,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const _ProductImageFallback(),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$unitPrice  x$quantity',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            lineTotal,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      color: const Color(0xFFEAF2FF),
      child: const Icon(Icons.local_cafe, color: Color(0xFF2563EB)),
    );
  }
}

class _EmptyOrderItems extends StatelessWidget {
  const _EmptyOrderItems();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Kh\u00f4ng c\u00f3 m\u00f3n n\u00e0o trong \u0111\u01a1n n\u00e0y',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

class _TotalBar extends StatelessWidget {
  final String total;

  const _TotalBar({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'T\u1ed5ng c\u1ed9ng',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              total,
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
