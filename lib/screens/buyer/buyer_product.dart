import 'package:chopdirect/screens/buyer/buyer_cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chopdirect/screens/buyer/cards/product_card.dart';
import 'package:chopdirect/screens/buyer/product_grid_item.dart';
import 'package:chopdirect/screens/buyer/section_headers.dart';

import 'cards/farmers_card.dart';

// Function to fetch products from Firestore
Future<List<Map<String, dynamic>>> fetchProducts() async {
  QuerySnapshot<Map<String, dynamic>> snapshot =
  await FirebaseFirestore.instance.collection("products").get();
  return snapshot.docs.map((doc) => doc.data()).toList();
}

class BuyerProductsScreen extends StatefulWidget {
  const BuyerProductsScreen({super.key});

  @override
  State<BuyerProductsScreen> createState() => _BuyerProductsScreenState();
}

class _BuyerProductsScreenState extends State<BuyerProductsScreen> {
  int cartItemCount = 0;
  void fetchCartItemCount() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    FirebaseFirestore.instance
        .collection("cart")
        .where("userId", isEqualTo: currentUser.email)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          cartItemCount = snapshot.docs.length;
        });
      }
    }, onError: (error) {
      print("Firestore Error: $error"); // ✅ Logs errors instead of breaking UI
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Text(""),
        title: Text("CHOPDIRECT",
         style: TextStyle(
           color: Colors.white,
           fontWeight: FontWeight.bold,
           fontSize: 20,
         ),
        ),
        actions: [
          Stack(
            children: [
              Container(
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
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen()));
                  },
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
              child: Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon:Image.asset("assets/search.png"),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.transparent
                      )
                    ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.transparent
                          )
                      ),
                    filled: true,
                    fillColor: Color(0xffE9EAEB),
                    suffixIcon: Image.asset("assets/filter.png")
                  ),
                ),
              ),
            ),

            // Featured Products - Firestore Fetch
            const SectionHeader(title: 'Featured Products'),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error loading products: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No products available"));
                }

                List<Map<String, dynamic>> products = snapshot.data!;
                return SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: products.map((product) {
                      return ProductCard(
                        name: product["name"],
                        price: "${product["price"]} XAF",
                        farmer: product["farmerId"] ?? "Unknown",
                        image: product["imageUrl"],
                        rating: product["ratings"] ?? 0.0,
                        stock: product['stock'] ?? 00,
                        updateCartBadge: incrementCartCount,
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SectionHeader(title: 'Nearby Farms'),
            SizedBox( height: 160,
              child: ListView( scrollDirection: Axis.horizontal,
                children: const [ FarmCard( name: 'Njoh Farm', distance: '2.5 km', products: 'Tomatoes, Peppers, Onions', image: 'assets/farm1.jpeg', ), FarmCard( name: 'Mbu Farm', distance: '3.1 km', products: 'Bananas, Plantains', image: 'assets/farm2.jpeg', ), FarmCard( name: 'Ndi Farm', distance: '5.2 km', products: 'Beans, Maize', image: 'assets/farm3.jpeg', ), ], ), ),

            // All Products - Firestore Fetch
            const SectionHeader(title: 'All Products'),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error loading products: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No products available"));
                }

                List<Map<String, dynamic>> products = snapshot.data!;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  children: products.map((product) {
                    return ProductGridItem(
                      name: product["name"],
                      price: "${product["price"]}XAF",
                      image: product["imageUrl"],
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
