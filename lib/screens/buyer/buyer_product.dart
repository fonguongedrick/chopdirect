import 'package:chopdirect/screens/buyer/cards/farmers_card.dart';
import 'package:chopdirect/screens/buyer/cards/product_card.dart';
import 'package:chopdirect/screens/buyer/category_chip.dart';
import 'package:chopdirect/screens/buyer/product_grid_item.dart';
import 'package:chopdirect/screens/buyer/section_headers.dart';
import 'package:flutter/material.dart';


class BuyerProductsScreen extends StatelessWidget {
  const BuyerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Search and filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Categories
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                CategoryChip(icon: Icons.eco, label: 'Vegetables'),
                CategoryChip(icon: Icons.apple, label: 'Fruits'),
                CategoryChip(icon: Icons.grain, label: 'Grains'),
                CategoryChip(icon: Icons.local_drink, label: 'Drinks'),
                CategoryChip(icon: Icons.kitchen, label: 'Others'),
              ],
            ),
          ),

          // Featured products
          const SectionHeader(title: 'Featured Products'),
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                ProductCard(
                  name: 'Fresh Tomatoes',
                  price: 'XAF 500/kg',
                  farmer: 'Njoh Farm',
                  image: 'assets/tomatoes.jpg',
                  rating: 4.5,
                ),
                ProductCard(
                  name: 'Organic Bananas',
                  price: 'XAF 300/bunch',
                  farmer: 'Mbu Farm',
                  image: 'assets/bananas.jpeg',
                  rating: 4.2,
                ),
                ProductCard(
                  name: ' Beans',
                  price: 'XAF 700/kg',
                  farmer: 'Ndi Farm',
                  image: 'assets/beans.png',
                  rating: 4.7,
                ),
              ],
            ),
          ),

          // Nearby farms
          const SectionHeader(title: 'Nearby Farms'),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                FarmCard(
                  name: 'Njoh Farm',
                  distance: '2.5 km',
                  products: 'Tomatoes, Peppers, Onions',
                  image: 'assets/farm1.jpeg',
                ),
                FarmCard(
                  name: 'Mbu Farm',
                  distance: '3.1 km',
                  products: 'Bananas, Plantains',
                  image: 'assets/farm2.jpeg',
                ),
                FarmCard(
                  name: 'Ndi Farm',
                  distance: '5.2 km',
                  products: 'Beans, Maize',
                  image: 'assets/farm3.jpeg',
                ),
              ],
            ),
          ),

          // All products
          const SectionHeader(title: 'All Products'),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            children: const [
              ProductGridItem(
                  name: 'Carrots',
                  price: 'XAF 600/kg',
                  image: 'assets/carrots.jpeg'),
              ProductGridItem(
                  name: 'Cabbage',
                  price: 'XAF 800/head',
                  image: 'assets/cabbage.jpeg'),
              ProductGridItem(
                  name: 'Potatoes',
                  price: 'XAF 700/kg',
                  image: 'assets/potatoes.jpg'),
              ProductGridItem(
                  name: 'Onions',
                  price: 'XAF 900/kg',
                  image: 'assets/onions.jpeg'),
            ],
          ),
        ],
      ),
    );
  }
}
