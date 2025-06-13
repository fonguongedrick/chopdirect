import 'package:flutter/material.dart';
import 'cart_item.dart';

class CartManager extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _currentFarmerId;

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get subtotal => totalPrice;
  String? get currentFarmerId => _currentFarmerId;

  bool canAddItem(String farmerId) {
    return _currentFarmerId == null || _currentFarmerId == farmerId;
  }

  void addItem(Map<String, dynamic> product) {
    final farmerId = product['farmerId'] ?? '';
    if (!canAddItem(farmerId)) {
      throw Exception('Cannot add items from different farmers');
    }
    _currentFarmerId = farmerId;

    final existingIndex = _items.indexWhere((item) => item.id == product['id']);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        id: product['id'] ?? '',
        name: product['name'] ?? '',
        price: (product['price'] ?? 0).toDouble(),
        farmerId: farmerId,
        imageUrl: product['imageUrl'] ?? '',
      ));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    if (_items.isEmpty) {
      _currentFarmerId = null;
    }
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (quantity <= 0) {
        removeItem(id);
      } else {
        _items[index].quantity = quantity;
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    _currentFarmerId = null;
    notifyListeners();
  }
}
