import 'package:chopdirect/screens/farmer/add_product.dart';
import 'package:chopdirect/screens/farmer/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddProductScreen(product: product),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16/9,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              product.category,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 32),
            _buildDetailRow('Price', 'XAF ${product.price.toStringAsFixed(0)}'),
            _buildDetailRow('Unit', product.unit),
            _buildDetailRow('Available Stock', '${product.stock} ${product.unit}'),
            _buildDetailRow('Description', product.description ?? 'No description'),
            if (product.rating > 0) ...[
              const Divider(height: 32),
              _buildRatingSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ratings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              product.rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Icon(Icons.star, color: Colors.amber, size: 28),
            const SizedBox(width: 4),
            Text('(${product.reviewCount} reviews)'),
          ],
        ),
      ],
    );
  }
}
