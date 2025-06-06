import 'package:chopdirect/screens/farmer/cards/farmeroder_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  late String farmerId;

  @override
  void initState() {
    super.initState();
    _loadFarmerId();
  }

  Future<void> _loadFarmerId() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        farmerId = user.uid;
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrders(String status) async {
    try {
      Query query = _firestore
          .collection('orders')
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('createdAt', descending: true);

      if (status != 'All') {
        query = query.where('status', isEqualTo: status);
      }

      final querySnapshot = await query.get();
      final productsQuery = await _firestore.collection('products').get();
      final productsMap = {
        for (var doc in productsQuery.docs) doc.id: doc.data()
      };

      List<Map<String, dynamic>> orders = [];
      for (var order in querySnapshot.docs) {
        // Get customer name
        final customerDoc = await _firestore
            .collection('users_chopdirect')
            .doc(order['userId'])
            .get();
        final customerName = customerDoc.exists ? customerDoc['name'] : 'Customer';

        // Process order items
        List<Map<String, dynamic>> orderItems = [];
        for (var item in order['items']) {
          if (productsMap.containsKey(item['productId'])) {
            orderItems.add({
              'productId': item['productId'],
              'name': productsMap[item['productId']]!['name'],
              'quantity': item['quantity'],
              'unit': item['unit'],
              'price': item['price'],
            });
          }
        }

        orders.add({
          'orderId': order.id,
          'orderNumber': '#${order.id.substring(0, 8).toUpperCase()}',
          'customer': customerName,
          'items': orderItems,
          'status': order['status'],
          'totalAmount': order['totalAmount'],
          'createdAt': order['createdAt'],
          'formattedDate': _formatDate(order['createdAt'].toDate()),
          'rating': order['rating'] ?? 0.0,
        });
      }

      return orders;
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today, ${_formatTime(date)}';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Processing'),
              Tab(text: 'Shipped'),
              Tab(text: 'Delivered'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // All orders
            _buildOrderTab('All'),
            // Processing orders
            _buildOrderTab('Processing'),
            // Shipped orders
            _buildOrderTab('Shipped'),
            // Delivered orders
            _buildOrderTab('Delivered'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTab(String status) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchOrders(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return const Center(
            child: Text('No orders found', style: TextStyle(fontSize: 16)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FarmerOrderCard(
                orderId: order['orderId'],
                orderNumber: order['orderNumber'],
                customer: order['customer'],
                items: order['items'],
                status: order['status'],
                date: order['formattedDate'],
                totalAmount: order['totalAmount'],
                rating: order['rating'],
              ),
            );
          },
        );
      },
    );
  }
}