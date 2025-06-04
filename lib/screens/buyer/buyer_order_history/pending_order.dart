import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../order_details_screen.dart';

class PendingOrder extends StatefulWidget {
  const PendingOrder({super.key});

  @override
  State<PendingOrder> createState() => _PendingOrderState();
}

class _PendingOrderState extends State<PendingOrder> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
          leading: SizedBox.shrink(),
          title: const Text("Pending Orders",style: TextStyle(color: Colors.black),), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('orders')
            .where('userId', isEqualTo: _auth.currentUser?.uid)
            .where('status', isEqualTo: 'pending')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _buildErrorState(snapshot.error.toString());
          if (snapshot.connectionState == ConnectionState.waiting) return _buildLoadingState();
          if (snapshot.data?.docs.isEmpty ?? true) return _buildEmptyState();
          return _buildOrderList(snapshot.data!.docs);
        },
      ),
    );
  }

  Widget _buildOrderList(List<QueryDocumentSnapshot> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        var order = orders[index];
        var data = order.data() as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text('Order #${order.id.substring(0, 8)}'),
            subtitle: Text('Total: ${data['totalAmount']?.toStringAsFixed(2)} XAF'),
            trailing: Chip(
              label: Text("Pending", style: const TextStyle(color: Colors.orange)),
              backgroundColor: Colors.orange.withOpacity(0.2),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(
                    orderId: order.id,
                    orderData: data,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() => const Center(child: CircularProgressIndicator());
  Widget _buildEmptyState() => const Center(child: Text("No pending orders"));
  Widget _buildErrorState(String error) => Center(child: Text("Error: $error"));
}
