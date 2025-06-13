class Product {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final String farmerId;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.farmerId,
  });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? 'Unknown Product',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'],
      farmerId: data['farmerId'] ?? '',
    );
  }
}