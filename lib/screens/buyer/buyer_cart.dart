import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_item.dart';
import 'payment_method.dart'; // Assuming checkout leads to payment

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void updateQuantity(String name, int currentQuantity, int change) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    DocumentReference itemRef = FirebaseFirestore.instance.collection("cart")
        .doc("${currentUser.email}_$name");

    if (currentQuantity + change > 0) {
      await itemRef.update({"quantity": currentQuantity + change});
    } else {
      await itemRef.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Your Cart")),
        body: Center(child: Text("Please log in to view your cart.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Your Cart")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection("cart")
            .where("userId", isEqualTo: currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Error fetching cart items: ${snapshot.error}");
            return Center(child: Text("Error loading cart: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Your cart is empty."));
          }

          List<QueryDocumentSnapshot<Map<String, dynamic>>> cartItems = snapshot.data!.docs;

          // Calculate total price & quantity
          double totalPrice = 0;
          int totalQuantity = 0;
          for (var doc in cartItems) {
            Map<String, dynamic> item = doc.data();
            String cleanPrice = item["price"].replaceAll("XAF", "").replaceAll("/kg", "").trim();
            totalPrice += double.parse(cleanPrice) * item["quantity"];
            totalQuantity += item["quantity"] as int;
          }

          return Column(
            children: [
              // Cart Items List
              Expanded(
                child: ListView(
                  children: cartItems.map((doc) {
                    Map<String, dynamic> item = doc.data();
                    return CartItem(
                      name: item["name"],
                      price: item["price"],
                      quantity: item["quantity"],
                      image: item["imageUrl"],
                      onUpdateQuantity: (change) => updateQuantity(item["name"], item["quantity"], change),
                    );
                  }).toList(),
                ),
              ),

              // Checkout Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text("Total Items: $totalQuantity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Total Price: XAF ${totalPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          print("Proceeding to checkout...");
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => PaymentMethod(subtotal: totalPrice),
                          ));
                        },
                        child: const Text("Checkout"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
