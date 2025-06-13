class CartItem {
  final String id;
  final String name;
  final double price;
  final List<String> specialties;
  final String farmerId;
  final String imageUrl;
  int quantity;
  
  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.farmerId,
    required this.imageUrl,
    this.quantity = 1,
    this.specialties = const [],
  });
}