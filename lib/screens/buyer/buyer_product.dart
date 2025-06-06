import 'package:chopdirect/screens/buyer/buyer_cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chopdirect/screens/buyer/cards/product_card.dart';
import 'package:chopdirect/screens/buyer/product_grid_item.dart';
import 'package:chopdirect/screens/buyer/section_headers.dart';
import 'cards/farmers_card.dart';

// Function to fetch products from Firestore as a stream
Stream<List<Map<String, dynamic>>> fetchProducts() {
  return FirebaseFirestore.instance
      .collection('products')
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
}

class BuyerProductsScreen extends StatefulWidget {
  const BuyerProductsScreen({super.key});

  @override
  State<BuyerProductsScreen> createState() => _BuyerProductsScreenState();
}

class _BuyerProductsScreenState extends State<BuyerProductsScreen> {
  int cartItemCount = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // When fetching the cart count, you currently use currentUser.email.
  // Consider using currentUser.uid for consistency.
  void fetchCartItemCount() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    FirebaseFirestore.instance
        .collection("cart")
        .where("userId", isEqualTo: currentUser.email) // Adjust if needed
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          cartItemCount = snapshot.docs.length;
        });
      }
    }, onError: (error) {
      print("Firestore Error: $error");
    });
  }

  void incrementCartCount() {
    setState(() {
      cartItemCount++;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCartItemCount();
    // Listen to search field changes
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Local helper: filter products by search query (by product name)
  List<Map<String, dynamic>> _filterProducts(
      List<Map<String, dynamic>> products, String query) {
    if (query.isEmpty) return products;
    return products.where((product) {
      final prodName = (product["name"] ?? "").toString().toLowerCase();
      return prodName.contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CHOPDIRECT",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen())
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 20),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Image.asset("assets/cart.png"),
                ),
              ),
              if (cartItemCount > 0)
                Positioned(
                  top: 5,
                  right: 15,
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search and filter
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by product name...',
                  prefixIcon: Image.asset("assets/search.png"),
                  filled: true,
                  fillColor: const Color(0xffE9EAEB),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  suffixIcon: Image.asset("assets/filter.png"),
                ),
              ),
            ),

            const SectionHeader(title: 'Featured Products'),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchProducts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<Map<String, dynamic>> products = snapshot.data!;
                // Filter products based on search query
                products = _filterProducts(products, _searchQuery);
                return SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: products.map((product) {
                      return ProductCard(
                        name: product["name"],
                        price: "${product["price"]} XAF",
                        farmer: product["farmerId"] ?? "Unknown",
                        image: product["imageUrl"] ?? "",
                        rating: product["ratings"]?.toDouble() ?? 0.0,
                        stock: product['stock'] ?? 0,
                        updateCartBadge: incrementCartCount,
                      );
                    }).toList(),
                  ),
                );
              },
            ),

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
                      image: 'assets/farm1.jpeg'),
                  FarmCard(
                      name: 'Mbu Farm',
                      distance: '3.1 km',
                      products: 'Bananas, Plantains',
                      image: 'assets/farm2.jpeg'),
                  FarmCard(
                      name: 'Ndi Farm',
                      distance: '5.2 km',
                      products: 'Beans, Maize',
                      image: 'assets/farm3.jpeg'),
                ],
              ),
            ),

            const SectionHeader(title: 'All Products'),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchProducts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<Map<String, dynamic>> products = snapshot.data!;
                // Filter products based on search query
                products = _filterProducts(products, _searchQuery);
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  children: products.map((product) {
                    return ProductGridItem(
                      name: product["name"],
                      price: "${product["price"]} XAF",
                      image: product["imageUrl"] ?? "",
                      farmer: product["farmerId"] ?? "Unknown",
                      updateCartBadge: incrementCartCount,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
