import 'package:chopdirect/screens/buyer/Track_Order_screen.dart';
import 'package:chopdirect/screens/buyer/buyer_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {

  Future<void> _updateLoyaltyPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Query the collection where the "userId" field matches the current user's UID.
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection("users_chopdirect")
        .where("userId", isEqualTo: user.uid)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference<Map<String, dynamic>> userDoc = querySnapshot.docs.first.reference;
      try {
        await userDoc.update({
          "loyaltyPoints": FieldValue.increment(25), // Adds 10 points per order.
        });
        debugPrint("Loyalty points updated successfully.");
      } catch (e) {
        debugPrint("Error updating loyalty points: $e");
      }
    } else {
      debugPrint("User document not found.");
    }
  }

  Future<String> _createOrderAndGetId() async {
    // Example: Creating an order in Firestore and getting its ID
    DocumentReference orderRef = await FirebaseFirestore.instance.collection('orders').add({
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
      // ... other order details
    });
    return orderRef.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Order Placed Successfully!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '+ 2,347 Points Earned',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your order has been received and is being processed. You will receive a confirmation message shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _updateLoyaltyPoints();
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>BuyerHomeScreen()));
                  },
                  child: const Text('Back to Home'),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  String orderId = await _createOrderAndGetId();
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>TrackOrderScreen(orderId: orderId,)));
                },
                child: const Text('Track Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
