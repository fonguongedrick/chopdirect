import 'package:flutter/material.dart';

import 'item_menu_profile.dart';

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/farm1.jpeg'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Njoh Farm',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text('Bamenda, Cameroon'),
          const SizedBox(height: 24),

          // Farmer stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Loyalty Points'),
                      Text('1,250', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Current Level'),
                      Text('Gold Farmer', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Sales'),
                      Text('XAF 1.2M', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Customer Rating'),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text('4.8', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('View Leaderboard'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Profile menu
          const ProfileMenuItem(
            icon: Icons.person,
            title: 'Farm Profile',
          ),
          const ProfileMenuItem(
            icon: Icons.verified,
            title: 'Verification',
          ),
          const ProfileMenuItem(
            icon: Icons.bar_chart,
            title: 'Analytics',
          ),
          const ProfileMenuItem(
            icon: Icons.people,
            title: 'Refer Other Farmers',
          ),
          const ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
          ),
          const ProfileMenuItem(
            icon: Icons.settings,
            title: 'Settings',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
}
