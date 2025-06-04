import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'buyer_order_history/pending_order.dart';
import 'buyer_order_history/processing_order.dart';
import 'buyer_order_history/delivered_orders.dart';
import 'buyer_order_history/cancelled_order.dart';

class BuyerOrderHistory extends StatefulWidget {
  const BuyerOrderHistory({super.key});

  @override
  State<BuyerOrderHistory> createState() => _BuyerOrderHistoryState();
}

class _BuyerOrderHistoryState extends State<BuyerOrderHistory> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RefreshController _refreshController = RefreshController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      await _firestore.collection('orders')
          .where('userId', isEqualTo: _auth.currentUser?.uid)
          .get();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
      setState(() => _errorMessage = 'Failed to refresh orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders History"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Processing"),
            Tab(text: "Delivered"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PendingOrder(),      // ✅ Displays pending orders
          ProcessingOrder(),   // ✅ Displays processing orders
          DeliveredOrders(),   // ✅ Displays delivered orders
          CancelledOrder(),    // ✅ Displays cancelled orders separately
        ],
      ),
    );
  }
}
