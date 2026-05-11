class CartItem {
  final int id;
  final String name;
  final double price;
  final String? image;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.image,
    this.quantity = 1,
  });

  // Hàm factory để tạo CartItem từ JSON của Laravel một cách an toàn
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      // Ép kiểu double.parse để tránh lỗi int vs double
      price: double.parse(json['price'].toString()),
      image: json['image'],
      quantity: json['quantity'] ?? 1,
    );
  }

  // Tính thành tiền của món này
  double get total => price * quantity;
}