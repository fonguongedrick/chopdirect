import 'package:chopdirect/screens/buyer/product_overview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  final String name;
  final String price;
  final String farmer;
  final String image;
  final double rating;
  final int? stock;
  final VoidCallback updateCartBadge;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.farmer,
    required this.image,
    required this.rating,
    this.stock,
    required this.updateCartBadge,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
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




  bool isFavorite = false;

  void toggleFavorite() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("User not logged in!");
      return;
    }

    DocumentReference favRef = FirebaseFirestore.instance
        .collection("favorites")
        .doc("${currentUser.email}_${widget.name}");

    if (isFavorite) {
      await favRef.delete();
    } else {
      await favRef.set({
        "userId": currentUser.email,
        "name": widget.name,
        "price": widget.price,
        "imageUrl": widget.image,
      });
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void checkFavoriteStatus() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    DocumentReference favRef = FirebaseFirestore.instance.collection("favorites").doc("${currentUser.email}_${widget.name}");

    DocumentSnapshot doc = await favRef.get();
    setState(() {
      isFavorite = doc.exists;
    });
  }

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap:(){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>
                        ProductOverview(
                            name: widget.name,
                            image: widget.image,
                            rating: widget.rating,
                            price: widget.price,
                            farmer: widget.farmer,
                            stock: widget.stock,
                          updateCartBadge: widget.updateCartBadge,
                        )
                       ));
                      },
                      child: Image.asset(
                        widget.image,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 70,
                      right: 5,
                      child: GestureDetector(
                        onTap: addToCart,
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle
                          ),
                          child: Image.asset("assets/cart.png"),
                        ),
                      ),
                    )
                  ],
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
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      widget.price,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.stock.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      widget.farmer,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(widget.rating.toString()),
                        const Spacer(),
                        IconButton(
                          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, size: 20,
                           color: isFavorite ?Colors.red :Colors.black,
                          ),
                          onPressed: toggleFavorite,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//CachedNetworkImage(
//                         imageUrl: widget.image,
//                         height: 120,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                         placeholder: (context, url) => Center(child: CircularProgressIndicator()),
//                         errorWidget: (context, url, error) => Icon(Icons.error),
//                       )