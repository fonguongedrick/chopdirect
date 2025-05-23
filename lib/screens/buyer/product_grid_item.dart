import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductGridItem extends StatelessWidget {
  final String name;
  final String price;
  final String image;

  const ProductGridItem({
    super.key,
    required this.name,
    required this.price,
    required this.image,
  });

  void addToCart() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("User not logged in!");
      return;
    }

    FirebaseFirestore.instance.collection("cart").doc("${currentUser.email}_$name").set({
      "userId": currentUser.email,
      "name": name,
      "price": price,
      "imageUrl": image,
      "quantity": 1,  // Default quantity
    });

    print("$name added to cart!");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border, size: 20),
                      onPressed: () {},
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: addToCart,
                        child: Image.asset("assets/cart.png")),

                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
