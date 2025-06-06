import 'package:chopdirect/screens/farmer/add_product.dart';
import 'package:chopdirect/screens/farmer/cards/dashboardstat_card.dart';
import 'package:chopdirect/screens/farmer/cards/farmeroder_card.dart';
import 'package:chopdirect/screens/farmer/farmer_order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  String farmerName = "Farmer";
  int productCount = 0;
  int orderCount = 0;
  double averageRating = 0.0;
  double totalEarnings = 0.0;
  bool isLoading = true;
  List<Map<String, dynamic>> recentOrders = [];

  @override
  void initState() {
    super.initState();
    _loadFarmerData();
  }

  Future<void> _loadFarmerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1. Fetch farmer details
      final farmerDoc = await FirebaseFirestore.instance
          .collection('users_chopdirect')
          .doc(user.uid)
          .get();

      if (farmerDoc.exists) {
        setState(() {
          farmerName = farmerDoc.data()?['name'] ?? "Farmer";
        });
      }

      // 2. Fetch products count
      final productsQuery = await FirebaseFirestore.instance
          .collection('products')
          .where('farmerId', isEqualTo: user.uid)
          .get();

      // 3. Fetch recent orders (last 2)
      final ordersQuery = await FirebaseFirestore.instance
          .collection('orders')
          .where('farmerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(2)
          .get();

      // 4. Calculate stats
      double totalRatings = 0;
      int ratingCount = 0;
      List<Map<String, dynamic>> tempOrders = [];

      for (var order in ordersQuery.docs) {
        // Calculate earnings
        totalEarnings += (order['totalAmount'] as num).toDouble();

        // Get product names
        List<String> productNames = [];
        for (var item in order['items']) {
          final productDoc = await FirebaseFirestore.instance
              .collection('products')
              .doc(item['productId'])
              .get();
          if (productDoc.exists) {
            productNames.add('${productDoc['name']} (${item['quantity']}${item['unit']})');
          }
        }

        // Get customer name
        final customerDoc = await FirebaseFirestore.instance
            .collection('users_chopdirect')
            .doc(order['userId'])
            .get();
        final customerName = customerDoc.exists ? customerDoc['name'] : 'Customer';

        tempOrders.add({
          'orderId': '#${order.id.substring(0, 8).toUpperCase()}',
          'orderNumber': order.id,
          'customer': customerName,
          'items': productNames.join(', '),
          'status': order['status'],
          'date': _formatDate(order['createdAt'].toDate()),
          'totalAmount': (order['totalAmount'] as num).toDouble(),
        });

        // Calculate average rating
        if (order['rating'] != null) {
          totalRatings += (order['rating'] as num).toDouble();
          ratingCount++;
        }
      }

      // 5. Get total order count
      final orderCountQuery = await FirebaseFirestore.instance
          .collection('orders')
          .where('farmerId', isEqualTo: user.uid)
          .count()
          .get();

      setState(() {
        productCount = productsQuery.docs.length;
        orderCount = orderCountQuery.count ?? 0; // Add null check here
        averageRating = ratingCount > 0 ? totalRatings / ratingCount : 0.0;
        recentOrders = tempOrders;
        isLoading = false;
      });

    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error loading farmer data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
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
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
            ),
          ).then((_) => _loadFarmerData());
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Product"),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Welcome card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/farm1.jpeg'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, $farmerName!',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your farm summary',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_active),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stats cards with real data
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              children: [
                DashboardStatCard(
                  icon: Icons.shopping_basket,
                  value: isLoading ? '...' : '$productCount',
                  label: 'Products',
                  color: Colors.green,
                ),
                DashboardStatCard(
                  icon: Icons.receipt,
                  value: isLoading ? '...' : '$orderCount',
                  label: 'Orders',
                  color: Colors.blue,
                ),
                DashboardStatCard(
                  icon: Icons.star,
                  value: isLoading ? '...' : averageRating.toStringAsFixed(1),
                  label: 'Rating',
                  color: Colors.amber,
                ),
                DashboardStatCard(
                  icon: Icons.attach_money,
                  value: isLoading ? '...' : 'XAF ${totalEarnings.toStringAsFixed(0)}',
                  label: 'Earnings',
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1,
              children: [
                DashboardActionCard(
                  icon: Icons.add,
                  label: 'Add Product',
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddProductScreen(),
                      ),
                    ).then((_) => _loadFarmerData());
                  },
                ),
                DashboardActionCard(
                  icon: Icons.local_shipping,
                  label: 'Process Orders',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FarmerOrdersScreen(),
                      ),
                    );
                  },
                ),
                DashboardActionCard(
                  icon: Icons.bar_chart,
                  label: 'Stats',
                  color: Colors.orange,
                  onTap: () {},
                ),
                DashboardActionCard(
                  icon: Icons.people,
                  label: 'Customers',
                  color: Colors.purple,
                  onTap: () {},
                ),
                DashboardActionCard(
                  icon: Icons.share,
                  label: 'Refer',
                  color: Colors.teal,
                  onTap: () {},
                ),
                DashboardActionCard(
                  icon: Icons.help_outline,
                  label: 'Help',
                  color: Colors.red,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recent orders with real data
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (recentOrders.isEmpty)
              const Text('No recent orders')
            else
              ...recentOrders.map((order) => FarmerOrderCard(
                orderId: order['orderId'],
                customer: order['customer'],
                items: order['items'],
                status: order['status'],
                date: order['date'], orderNumber: order['orderNumber'], totalAmount:order['totalAmount'],
              )),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FarmerOrdersScreen(),
                  ),
                );
              },
              child: const Text('View All Orders'),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const DashboardActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.color = Colors.green,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}