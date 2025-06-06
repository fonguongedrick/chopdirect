import 'package:chopdirect/screens/farmer/add_product.dart';
import 'package:chopdirect/screens/farmer/cards/farmerproduct_card.dart';
import 'package:chopdirect/screens/farmer/product_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/product_model.dart';

class FarmerProductsScreen extends StatefulWidget {
  const FarmerProductsScreen({super.key});

  @override
  State<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'XAF ',
      decimalDigits: 0,
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
            ),
          ).then((_) => setState(() {}));
        },
        backgroundColor: Colors.green[800],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('My Products',
                style: TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 3)],
                ),
              ),
              background: Image.asset(
                'assets/farm_products.jpeg',
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'My Products (${_auth.currentUser?.displayName ?? ''})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('products')
                .where('farmerId', isEqualTo: _auth.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_basket, size: 50, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No products found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddProductScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800],
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Add Your First Product',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final filteredProducts = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['name']?.toString().toLowerCase() ?? '';
                final category = data['category']?.toString().toLowerCase() ?? '';
                return name.contains(_searchQuery) ||
                    category.contains(_searchQuery);
              }).toList();

              if (filteredProducts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 50, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No products matching "$_searchQuery"',
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final product = filteredProducts[index];
                    final data = product.data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: FarmerProductCard(
                        productId: product.id,
                        name: data['name'] ?? 'Unnamed Product',
                        category: data['category'] ?? 'Uncategorized',
                        price: double.parse(currencyFormat.format(data['price'] ?? 0)),
                        unit: data['unit'] ?? '',
                        imageUrl: data['imageUrl'] ?? '',
                        availableQuantity: (data['stock'] as num?)?.toInt() ?? 0,
                        rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
                        reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
                        onTap: () => _viewProductDetails(context, product.id),
                        onEdit: () => _editProduct(context, product.id),
                        onDelete: () => _confirmDeleteProduct(product.id),
                      ),
                    );
                  },
                  childCount: filteredProducts.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _viewProductDetails(BuildContext context, String productId) async {
    final product = await _fetchProductDetails(productId);
    if (product != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ),
      );
    }
  }

  Future<void> _editProduct(BuildContext context, String productId) async {
    final product = await _fetchProductDetails(productId);
    if (product != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddProductScreen(product: product),
        ),
      ).then((_) => setState(() {}));
    }
  }

  Future<Product?> _fetchProductDetails(String productId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product: $e');
      return null;
    }
  }

  Future<void> _confirmDeleteProduct(String productId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProduct(productId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}