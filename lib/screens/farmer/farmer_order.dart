import 'package:chopdirect/screens/farmer/cards/farmeroder_card.dart';
import 'package:flutter/material.dart';

class FarmerOrdersScreen extends StatelessWidget {
  const FarmerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            SingleChildScrollView(
              child: Column(
                children: const [
                  FarmerOrderCard(
                    orderId: '#CD-1234',
                    customer: 'Nfon Ashi.',
                    items: 'Tomatoes (2kg), Onions (1kg)',
                    status: 'Processing',
                    date: 'Today, 10:30 AM',
                  ),
                  FarmerOrderCard(
                    orderId: '#CD-1233',
                    customer: 'Ngwa Joseph',
                    items: 'Bananas (3 bunches)',
                    status: 'Shipped',
                    date: 'Yesterday, 2:15 PM',
                  ),
                  FarmerOrderCard(
                    orderId: '#CD-1232',
                    customer: 'Neba James',
                    items: 'Carrots (1kg), Cabbage (2 heads)',
                    status: 'Delivered',
                    date: '2 days ago',
                  ),
                ],
              ),
            ),

            // Processing orders
            SingleChildScrollView(
              child: Column(
                children: const [
                  FarmerOrderCard(
                    orderId: '#CD-1234',
                    customer: 'Nfon Ashi',
                    items: 'Tomatoes (2kg), Onions (1kg)',
                    status: 'Processing',
                    date: 'Today, 10:30 AM',
                  ),
                ],
              ),
            ),

            // Shipped orders
            SingleChildScrollView(
              child: Column(
                children: const [
                  FarmerOrderCard(
                    orderId: '#CD-1233',
                    customer: 'Ngwa Joseph',
                    items: 'Bananas (3 bunches)',
                    status: 'Shipped',
                    date: 'Yesterday, 2:15 PM',
                  ),
                ],
              ),
            ),

            // Delivered orders
            SingleChildScrollView(
              child: Column(
                children: const [
                  FarmerOrderCard(
                    orderId: '#CD-1232',
                    customer: 'Neba James.',
                    items: 'Carrots (1kg), Cabbage (2 heads)',
                    status: 'Delivered',
                    date: '2 days ago',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
