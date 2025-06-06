import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mesomb/mesomb.dart';

import 'order_confirmation.dart';

class PaymentMethod extends StatefulWidget {
  final double? subtotal;
  const PaymentMethod({super.key, this.subtotal});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  late PaymentOperation payment;
  final TextEditingController _phoneController = TextEditingController();
  final double deliveryFee = 500; // Static delivery fee

  @override
  void initState() {
    super.initState();
    payment = PaymentOperation(
      '795ee41f78b16c24023a17ed94a90bf577b569c4',
      '98af2657-3378-40e1-adfb-5b1017ffb25d',
      'bb817a20-d65a-4566-9d75-46381ff8c19f',
    );
    _phoneController.text = "+237";
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Creates an order in Firestore using the current user's cart.
  /// Returns the generated order ID if successful.
  Future<String?> _storeOrder() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    try {
      // Fetch user details from Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection("users_chopdirect")
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        debugPrint("User not found. Cannot store order.");
        return null;
      }

      Map<String, dynamic> userData = userDoc.data()!;
      String userName = userData["name"] ?? "Unknown";
      String userPhone = userData["phone"] ?? "Unknown";

      // Retrieve cart items using the UID
      QuerySnapshot<Map<String, dynamic>> cartSnapshot = await FirebaseFirestore.instance
          .collection("cart")
          .where("userId", isEqualTo: userId)
          .get();

      debugPrint("Fetching cart for userId: $userId");
      debugPrint("Cart Query Returned: ${cartSnapshot.docs.length} items");

      for (var doc in cartSnapshot.docs) {
        debugPrint("Cart Document ID: ${doc.id}");
        debugPrint("Cart Item Data: ${doc.data()}");
      }

      List<Map<String, dynamic>> cartItems = cartSnapshot.docs.map((doc) {
        Map<String, dynamic> itemData = doc.data();
        // Generate a unique ID for each order item
        String orderItemId = FirebaseFirestore.instance.collection("orders").doc().id;
        return {
          ...itemData,
          "orderItemId": orderItemId,
          "farmerName": itemData["farmerName"] ?? "Unknown",
          "farmerContact": itemData["farmerContact"] ?? "Unknown",
        };
      }).toList();

      if (cartItems.isEmpty) {
        debugPrint("Cart is empty. No order created.");
        return null;
      }

      // Calculate pricing while converting price (which may be a string like "1500.0 XAF") to a number
      double sub = 0;
      for (var item in cartItems) {
        double priceValue = 0;
        if (item['price'] is String) {
          // Remove any currency text or units like "XAF" or "/kg"
          String cleanedPrice = (item['price'] as String)
              .replaceAll("XAF", "")
              .replaceAll("/kg", "")
              .trim();
          priceValue = double.tryParse(cleanedPrice) ?? 0;
        } else if (item['price'] is num) {
          priceValue = item['price'];
        }
        sub += priceValue * (item['quantity'] as num);
      }
      double totalAmount = sub + deliveryFee;

      // Generate a unique order ID
      String generatedOrderId = FirebaseFirestore.instance.collection("orders").doc().id;

      // Store order in Firestore
      await FirebaseFirestore.instance.collection('orders').doc(generatedOrderId).set({
        "orderId": generatedOrderId,
        "userId": userId,
        "userName": userName,
        "userPhone": userPhone,
        "status": "pending",
        "timestamp": FieldValue.serverTimestamp(),
        "items": cartItems,
        "subtotal": sub,
        "deliveryFee": deliveryFee,
        "totalAmount": totalAmount,
      });

      // Clear cart after storing order
      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      debugPrint("Order stored successfully with totalAmount: $totalAmount XAF and orderId: $generatedOrderId");
      return generatedOrderId;
    } catch (e) {
      debugPrint("Error storing order: $e");
      return null;
    }
  }

  // Payment via MTN MoMo
  Future<void> processPaymentMTNPayment() async {
    double sub = widget.subtotal ?? 0;
    double totalAmount = sub + deliveryFee;
    String nonce = Random().nextInt(1000000).toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter Payment Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 26),
              TextField(
                controller: TextEditingController(text: "${sub.toStringAsFixed(2)} XAF"),
                decoration: InputDecoration(labelText: "Subtotal"),
                readOnly: true,
              ),
              SizedBox(height: 25),
              TextField(
                controller: TextEditingController(text: "${deliveryFee.toStringAsFixed(2)} XAF"),
                decoration: InputDecoration(labelText: "Delivery Fee"),
                readOnly: true,
              ),
              SizedBox(height: 25),
              TextField(
                controller: TextEditingController(text: "${totalAmount.toStringAsFixed(2)} XAF"),
                decoration: InputDecoration(labelText: "Total Payment"),
                readOnly: true,
              ),
              SizedBox(height: 25),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  if (!value.startsWith("+237")) {
                    _phoneController.text = "+237";
                    _phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _phoneController.text.length),
                    );
                  }
                },
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {
                  String phone = _phoneController.text.trim();
                  if (phone.isEmpty || !phone.startsWith("+237") || phone.length <= 12) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid phone number')),
                    );
                    return;
                  }

                  final response = await payment.makeCollect(
                    amount: 1,
                    service: "MTN",
                    payer: phone,
                    nonce: nonce,
                  );

                  if (response.isTransactionSuccess()) {
                    sendOrderNotification();
                    // Create the order in Firestore
                    String? orderId = await _storeOrder();
                    if (orderId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderConfirmationScreen(orderId: orderId)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Order creation failed. Please try again')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment failed, please try again')),
                    );
                  }
                },
                child: Text("Make Payment"),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Payment via Orange Money
  Future<void> processOrangePayment() async {
    double sub = widget.subtotal ?? 0;
    double totalAmount = sub + deliveryFee;
    String nonce = Random().nextInt(1000000).toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter Payment Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 26),
              TextField(
                controller: TextEditingController(text: "${sub.toStringAsFixed(2)} XAF"),
                decoration: InputDecoration(labelText: "Subtotal"),
                readOnly: true,
              ),
              SizedBox(height: 25),
              TextField(
                controller: TextEditingController(text: "${deliveryFee.toStringAsFixed(2)} XAF"),
                decoration: InputDecoration(labelText: "Delivery Fee"),
                readOnly: true,
              ),
              SizedBox(height: 25),
              TextField(
                controller: TextEditingController(text: "${totalAmount.toStringAsFixed(2)} XAF"),
                decoration: InputDecoration(labelText: "Total Payment"),
                readOnly: true,
              ),
              SizedBox(height: 25),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  if (!value.startsWith("+237")) {
                    _phoneController.text = "+237";
                    _phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _phoneController.text.length),
                    );
                  }
                },
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {
                  String phone = _phoneController.text.trim();
                  if (phone.isEmpty || !phone.startsWith("+237") || phone.length <= 12) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid phone number')),
                    );
                    return;
                  }

                  final response = await payment.makeCollect(
                    amount: 1,
                    service: "Orange",
                    payer: phone,
                    nonce: nonce,
                  );

                  if (response.isTransactionSuccess()) {
                    sendOrderNotification();
                    // Create the order in Firestore
                    String? orderId = await _storeOrder();
                    if (orderId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderConfirmationScreen(orderId: orderId)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Order creation failed. Please try again')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment failed, please try again')),
                    );
                  }
                },
                child: Text("Make Payment"),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void sendOrderNotification() {
    FirebaseMessaging.instance.subscribeToTopic("order_updates");

    // Simulate receiving a notification in-app
    notificationsList.insert(0, RemoteMessage(
        notification: RemoteNotification(
          title: "Order Successful!",
          body: "Your order has been placed successfully.",
        ),
        data: {"screen": "order_details"}
    ));
    notificationsNotifier.value = List.from(notificationsList);
    unreadNotifier.value = true;

    debugPrint("Order notification simulated locally!");
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back)),
                    Text(
                      "Complete Payment Via...",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            SizedBox(height: 100),
            GestureDetector(
              onTap: processPaymentMTNPayment,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                height: 83,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(20),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset("assets/mtnmomo.png", scale: 2)),
                    ),
                    SizedBox(width: 20),
                    Text(
                      "MTN MoMo",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Spacer(),
                    Icon(Icons.keyboard_arrow_right, size: 40),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: processOrangePayment,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: 83,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(20),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset("assets/orangemoney.jpeg", scale: 2)),
                    ),
                    SizedBox(width: 20),
                    Text(
                      "Orange Money",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Spacer(),
                    Icon(Icons.keyboard_arrow_right, size: 40),
                  ],
                ),
              ),
            ),
            SizedBox(height: 70),
            Center(
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Text(
                    "Other Payments",
                    style: TextStyle(fontSize: 16),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
