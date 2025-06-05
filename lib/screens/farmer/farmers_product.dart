import 'package:chopdirect/screens/farmer/add_product.dart';
import 'package:chopdirect/screens/farmer/cards/farmerproduct_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FarmerProductsScreen extends StatefulWidget {
  const FarmerProductsScreen({super.key});

  @override
  State<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('My Products', style: TextStyle(color: Colors.white)),
              background: Image.asset(
                'assets/farm_products.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Product'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddProductScreen(),
                            ),
                          ).then((_) => setState(() {})); // Refresh after adding
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddProductScreen(),
                              ),
                            );
                          },
                          child: const Text('Add your first product'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final product = snapshot.data!.docs[index];
                    final data = product.data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: FarmerProductCard(
                        productId: product.id,
                        name: data['name'] ?? 'Unnamed Product',
                        price: 'XAF ${data['price']?.toStringAsFixed(0) ?? '0'}',
                        stock: '${data['stock']?.toString() ?? '0'} ${data['unit'] ?? ''}',
                        image: data['imageUrl'] ?? '',
                        rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
                        onDelete: () => _deleteProduct(product.id),
                      ),
                    );
                  },
                  childCount: snapshot.data!.docs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $e')),
      );
    }
  }
}