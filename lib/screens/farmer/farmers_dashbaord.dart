import 'package:chopdirect/screens/farmer/cards/dashboardstat_card.dart';
import 'package:chopdirect/screens/farmer/cards/dashoardaction_card.dart';
import 'package:chopdirect/screens/farmer/cards/farmeroder_card.dart';
import 'package:chopdirect/screens/farmer/farmer_order.dart';
import 'package:flutter/material.dart';

class FarmerDashboardScreen extends StatelessWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Welcome card
          Card(
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
                        const Text(
                          'Welcome back, Njoh!',
                          style: TextStyle(
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
            children: const [
              DashboardStatCard(
                icon: Icons.shopping_basket,
                value: '24',
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
            children: const [
              DashboardActionCard(
                icon: Icons.add,
                label: 'Add Product',
              ),
              DashboardActionCard(
                icon: Icons.local_shipping,
                label: 'Process Orders',
              ),
              DashboardActionCard(
                icon: Icons.bar_chart,
                label: 'Stats',
              ),
              DashboardActionCard(
                icon: Icons.people,
                label: 'Customers',
              ),
              DashboardActionCard(
                icon: Icons.share,
                label: 'Refer',
              ),
              DashboardActionCard(
                icon: Icons.help_outline,
                label: 'Help',
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
    );
  }
}
