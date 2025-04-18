import 'package:chopdirect/screens/farmer/add_product.dart';
import 'package:chopdirect/screens/farmer/cards/farmerproduct_card.dart';
import 'package:flutter/material.dart';

class FarmerProductsScreen extends StatelessWidget {
  const FarmerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('My Products', style: TextStyle(color: Colors.white),),
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
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const FarmerProductCard(
                    name: 'Fresh Tomatoes',
                    price: 'XAF 500/kg',
                    stock: '24 kg',
                    image: 'assets/tomatoes.jpg',
                    rating: 4.5,
                  ),
                  const FarmerProductCard(
                    name: 'Organic Bananas',
                    price: 'XAF 300/bunch',
                    stock: '15 bunches',
                    image: 'assets/bananas.jpeg',
                    rating: 4.2,
                  ),
                  const FarmerProductCard(
                    name: 'Green Beans',
                    price: 'XAF 700/kg',
                    stock: '8 kg',
                    image: 'assets/beans.png',
                    rating: 4.7,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
