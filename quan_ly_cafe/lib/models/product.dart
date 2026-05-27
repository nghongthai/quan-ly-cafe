class Product {
  final int id;
  final String name;
  final double price;
  final String image;
  final String? createdAt;
  final String? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.createdAt,
    this.updatedAt,
  });

  // Chuyển đổi từ JSON (Laravel) sang Object (Flutter)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      // Laravel trả về giá tiền dạng String "20000.00", cần ép về double
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      // Lấy tên file ảnh, nếu null thì để trống
      image: json['image'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Nếu sau này bạn cần gửi dữ liệu ngược lại server
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
    };
  }
}