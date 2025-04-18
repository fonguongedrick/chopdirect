import 'package:chopdirect/screens/buyer/profile_menu_item.dart';
import 'package:flutter/material.dart';

class BuyerProfileScreen extends StatelessWidget {
  const BuyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/Ellipse 7.png'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nfon Ashi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text('Bamenda, Cameroon'),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Loyalty Points'),
                      Text('420', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Current Level'),
                      Text('Silver Farmer', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  LinearProgressIndicator(
                    value: 0.6,
                    backgroundColor: Colors.grey[200],
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8),
                  const Text('60% to next level'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Redeem Points'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const ProfileMenuItem(
            icon: Icons.person,
            title: 'Edit Profile',
          ),
          const ProfileMenuItem(
            icon: Icons.location_on,
            title: 'Addresses',
          ),
          const ProfileMenuItem(
            icon: Icons.credit_card,
            title: 'Payment Methods',
          ),
          const ProfileMenuItem(
            icon: Icons.history,
            title: 'Order History',
          ),
          const ProfileMenuItem(
            icon: Icons.star,
            title: 'My Reviews',
          ),
          const ProfileMenuItem(
            icon: Icons.people,
            title: 'Refer a Friend',
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
