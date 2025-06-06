// Product model class
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final String category;
  final int stock;
  final String imageUrl;
  final double rating;
  final int reviewCount;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.category,
    required this.stock,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num).toDouble(),
      unit: data['unit'] ?? 'unit',
      category: data['category'] ?? 'category',
      stock: (data['stock'] as num).toInt(),
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'category': category,
      'stock': stock,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}