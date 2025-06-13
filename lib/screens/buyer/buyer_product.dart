import 'package:chopdirect/screens/buyer/cart_item.dart';
import 'package:chopdirect/widgets/pricing_row.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_method.dart';   // Assuming checkout leads to payment

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void updateQuantity(String name, int currentQuantity, int change) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Use UID and product name to generate the document ID.
    DocumentReference itemRef = FirebaseFirestore.instance
        .collection("cart")
        .doc("${currentUser.uid}_$name");

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
        appBar: AppBar(title: const Text("Your Cart")),
        body: const Center(child: Text("Please log in to view your cart.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("cart")
            .where("userId", isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Error fetching cart items: ${snapshot.error}");
            return Center(
              child: Text("Error loading cart: ${snapshot.error}"),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Your cart is empty."));
          }

          List<QueryDocumentSnapshot<Map<String, dynamic>>> cartItems =
              snapshot.data!.docs;

          // Calculate total price & total quantity.
          double totalPrice = 0;
          int totalQuantity = 0;
          for (var doc in cartItems) {
            Map<String, dynamic> item = doc.data();
            // Remove any extra text from the price then parse.
            String cleanPrice = item["price"]
                .replaceAll("XAF", "")
                .replaceAll("/kg", "")
                .trim();
            double priceValue = double.tryParse(cleanPrice) ?? 0;
            int quantity = item["quantity"];
            totalPrice += priceValue * quantity;
            totalQuantity += quantity;
          }

          return Column(
            children: [
              // Display the list of cart items.
              Expanded(
                child: ListView(
                  children: cartItems.map((doc) {
                    Map<String, dynamic> item = doc.data();
                    return CartItemWidget(
                      name: item["name"],
                      price: item["price"],
                      quantity: item["quantity"],
                      image: item["imageUrl"],
                      onUpdateQuantity: (change) =>
                          updateQuantity(item["name"], item["quantity"], change),
                      farmerId: item["farmerId"],
                      imageUrl: item["imageUrl"],
                      id: doc.id,
                    );
                  }).toList(),
                ),
              ),
              // Checkout section displaying totals.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Use the PricingRow widget instead of an undefined helper
                    PricingRow(label: 'Total Items', amount: totalQuantity.toString()),
                    PricingRow(
                        label: 'Total Price',
                        amount: 'XAF ${totalPrice.toInt()}',
                        isTotal: true),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PaymentMethod(subtotal: totalPrice)),
                          );
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
