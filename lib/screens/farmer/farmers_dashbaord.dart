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
  String farmerName = "Njoh"; // Default name
  int productCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFarmerData();
  }

  Future<void> _loadFarmerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Get farmer details
        final farmerDoc = await FirebaseFirestore.instance
            .collection('users_chopdirect')
            .doc(user.uid)
            .get();

        if (farmerDoc.exists) {
          setState(() {
            farmerName = farmerDoc.data()?['name'] ?? "Farmer";
          });
        }

        // Get product count
        final productsQuery = await FirebaseFirestore.instance
            .collection('products')
            .where('farmerId', isEqualTo: user.uid)
            .get();

        setState(() {
          productCount = productsQuery.docs.length;
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
      }
    }
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
          ).then((_) => _loadFarmerData()); // Refresh after adding product
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Product"),
        backgroundColor: Colors.green[800],
        elevation: 4,
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
                            'Your farm is doing great!',
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

            // Stats cards
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
                  value: '18',
                  label: 'Orders',
                  color: Colors.blue,
                ),
                DashboardStatCard(
                  icon: Icons.star,
                  value: '4.8',
                  label: 'Rating',
                  color: Colors.amber,
                ),
                DashboardStatCard(
                  icon: Icons.attach_money,
                  value: 'XAF 245K',
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
                  onTap: () {},
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

            // Recent orders
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const FarmerOrderCard(
              orderId: '#CD-1234',
              customer: 'Nfon AShi.',
              items: 'Tomatoes (2kg), Onions (1kg)',
              status: 'Processing',
              date: 'Today, 10:30 AM',
            ),
            const FarmerOrderCard(
              orderId: '#CD-1233',
              customer: 'Ngwa Joseph.',
              items: 'Bananas (3 bunches)',
              status: 'Shipped',
              date: 'Yesterday, 2:15 PM',
            ),
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

// Enhanced DashboardActionCard with color parameter
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