import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductGridItem extends StatefulWidget {
  final String name;
  final String price;
  final String image;
  final String farmer;
  final VoidCallback updateCartBadge;

  const ProductGridItem({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    required this.farmer,
    required this.updateCartBadge,
  });

  @override
  State<ProductGridItem> createState() => _ProductGridItemState();
}

class _ProductGridItemState extends State<ProductGridItem> {
  void addToCart() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("User not logged in!");
      return;
    }

    // Query all cart items for the current user.
    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection("cart")
        .where("userId", isEqualTo: currentUser.email)
        .get();

    if (cartSnapshot.docs.isNotEmpty) {
      String existingFarmer = cartSnapshot.docs.first['farmer'];
      if (existingFarmer != widget.farmer) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Sorry'),
              content: const Text(
                  'You cannot add products from a different farmer to your cart.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog.
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }
    }

    // Either the cart is empty or the farmer matches; proceed to add/update the product.
    DocumentReference cartRef = FirebaseFirestore.instance
        .collection("cart")
        .doc("${currentUser.email}_${widget.name}");

    DocumentSnapshot cartItem = await cartRef.get();

    if (cartItem.exists) {
      int currentQuantity = cartItem["quantity"] ?? 1;
      await cartRef.update({
        "quantity": currentQuantity + 1,
      });
    } else {
      await cartRef.set({
        "userId": currentUser.email,
        "name": widget.name,
        "price": widget.price,
        "imageUrl": widget.image,
        "quantity": 1, // Default quantity
        "farmer": widget.farmer, // Store the product's farmer
      });
    }

    widget.updateCartBadge();
    print("${widget.name} added to cart!");
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
              child: Image.network(
                widget.image,
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
                  widget.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.price,
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
