import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveOrders(),
          _buildOrderHistory(),
        ],
      ),
    );
  }

  Widget _buildActiveOrders() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return _buildAuthError();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['pending', 'processing', 'shipped'])
          
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return _buildEmptyState('No active orders');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data?.docs.length,
          itemBuilder: (context, index) {
            final order = snapshot.data!.docs[index];
            return _buildOrderCard(order, isActive: true);
          },
        );
      },
    );
  }

  Widget _buildOrderHistory() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return _buildAuthError();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['delivered', 'cancelled'])
          
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return _buildEmptyState('No order history');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data?.docs.length,
          itemBuilder: (context, index) {
            final order = snapshot.data!.docs[index];
            return _buildOrderCard(order, isActive: false);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(QueryDocumentSnapshot order, {required bool isActive}) {
    final data = order.data() as Map<String, dynamic>;
    final date = (data['createdAt'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMM d, yyyy - h:mm a').format(date);
    final status = data['status'] as String;
    final total = data['total'] as num;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formattedDate,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(data['items'] as List).length} items',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${NumberFormat.currency(symbol: '').format(total)} XAF',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (isActive && status != 'cancelled') ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _trackOrder(order),
                    child: const Text('Track Order'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Error loading orders', style: TextStyle(fontSize: 16)),
          Text(error, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildAuthError() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text('Please sign in to view your orders', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  void _showOrderDetails(QueryDocumentSnapshot order) {
    final data = order.data() as Map<String, dynamic>;
    final items = data['items'] as List;
    final date = (data['createdAt']).toDate();
    final formattedDate = DateFormat('MMM d, yyyy - h:mm a').format(date);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Order #${order.id.substring(0, 8).toUpperCase()}'),
              Text(formattedDate, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
              ...items.map((item) => _buildOrderItem(item)).toList(),
              const Divider(),
              _buildDetailRow('Subtotal', data['subtotal']),
              _buildDetailRow('Delivery Fee', data['deliveryFee'] ?? 0),
              const Divider(),
              _buildDetailRow('Total', data['total'], isTotal: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderItem(dynamic item) {
    final product = item as Map<String, dynamic>;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'] ?? 'Unknown Product'),
                Text('${product['quantity']} x ${product['price']} XAF'),
              ],
            ),
          ),
          Text('${(product['price'] * product['quantity']).toStringAsFixed(0)} XAF'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, num value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isTotal ? const TextStyle(fontWeight: FontWeight.bold) : null),
          Text(
            '${value.toStringAsFixed(0)} XAF',
            style: isTotal 
                ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                : null,
          ),
        ],
      ),
    );
  }

  void _trackOrder(QueryDocumentSnapshot order) {
    final data = order.data() as Map<String, dynamic>;
    final status = data['status'] as String;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Track Order')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatusTimeline(status),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Delivery Info', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildTrackingInfo('Order Number', order.id.substring(0, 8)),
                        _buildTrackingInfo('Status', status.toUpperCase()),
                        if (data['address'] != null)
                          _buildTrackingInfo('Delivery Address', data['address']),
                        _buildTrackingInfo(
                          'Delivery Method', 
                          data['deliveryOption'] == 'home' ? 'Home Delivery' : 'Takeaway'
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(String currentStatus) {
    final steps = [
      {'status': 'pending', 'label': 'Order Placed'},
      {'status': 'processing', 'label': 'Processing'},
      {'status': 'shipped', 'label': 'Shipped'},
      {'status': 'delivered', 'label': 'Delivered'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Order Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...steps.map((step) {
              final isCompleted = steps.indexWhere((s) => s['status'] == currentStatus) >= 
                  steps.indexWhere((s) => s['status'] == step['status']);
              final isCurrent = step['status'] == currentStatus;

              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? Colors.green : Colors.grey[300],
                          border: isCurrent ? Border.all(color: Colors.green, width: 2) : null,
                        ),
                        child: isCompleted 
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Text(step['label']!, style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? Colors.green : null,
                      )),
                    ],
                  ),
                  if (step != steps.last)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                      child: Container(
                        width: 2,
                        height: 20,
                        color: isCompleted ? Colors.green : Colors.grey[300],
                      ),
                    ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}