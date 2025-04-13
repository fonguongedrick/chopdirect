import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const FarmerDashboardScreen(),
    const FarmerProductsScreen(),
    const FarmerOrdersScreen(),
    const FarmerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChopDirect Farmer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

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
                    backgroundImage: AssetImage('assets/farmer_avatar.jpg'),
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
            customer: 'John M.',
            items: 'Tomatoes (2kg), Onions (1kg)',
            status: 'Processing',
            date: 'Today, 10:30 AM',
          ),
          const FarmerOrderCard(
            orderId: '#CD-1233',
            customer: 'Sarah K.',
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

class DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  
  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
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
  
  const DashboardActionCard({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FarmerOrderCard extends StatelessWidget {
  final String orderId;
  final String customer;
  final String items;
  final String status;
  final String date;
  
  const FarmerOrderCard({
    super.key,
    required this.orderId,
    required this.customer,
    required this.items,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    if (status == 'Processing') {
      statusColor = Colors.orange;
    } else if (status == 'Shipped') {
      statusColor = Colors.blue;
    } else if (status == 'Delivered') {
      statusColor = Colors.green;
    } else if (status == 'Cancelled') {
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              customer,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(items),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FarmerProductsScreen extends StatelessWidget {
  const FarmerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('My Products'),
              background: Image.asset(
                'assets/farm_products.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Product'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddProductScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const FarmerProductCard(
                    name: 'Fresh Tomatoes',
                    price: 'XAF 500/kg',
                    stock: '24 kg',
                    image: 'assets/tomatoes.jpg',
                    rating: 4.5,
                  ),
                  const FarmerProductCard(
                    name: 'Organic Bananas',
                    price: 'XAF 300/bunch',
                    stock: '15 bunches',
                    image: 'assets/bananas.jpg',
                    rating: 4.2,
                  ),
                  const FarmerProductCard(
                    name: 'Green Beans',
                    price: 'XAF 700/kg',
                    stock: '8 kg',
                    image: 'assets/beans.jpg',
                    rating: 4.7,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FarmerProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String stock;
  final String image;
  final double rating;
  
  const FarmerProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.stock,
    required this.image,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(price),
                  Text('Stock: $stock'),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(rating.toString()),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProductScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Product image
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                    Text('Add Product Image'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Product details form
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Product Name',
                hintText: 'e.g. Fresh Tomatoes',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your product...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      hintText: 'e.g. 500',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'kg',
                        child: Text('per kg'),
                      ),
                      DropdownMenuItem(
                        value: 'bunch',
                        child: Text('per bunch'),
                      ),
                      DropdownMenuItem(
                        value: 'piece',
                        child: Text('per piece'),
                      ),
                      DropdownMenuItem(
                        value: 'bag',
                        child: Text('per bag'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Available Stock',
                hintText: 'e.g. 20',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'vegetables',
                  child: Text('Vegetables'),
                ),
                DropdownMenuItem(
                  value: 'fruits',
                  child: Text('Fruits'),
                ),
                DropdownMenuItem(
                  value: 'grains',
                  child: Text('Grains'),
                ),
                DropdownMenuItem(
                  value: 'drinks',
                  child: Text('Drinks'),
                ),
                DropdownMenuItem(
                  value: 'others',
                  child: Text('Others'),
                ),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Add Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProductScreen extends StatelessWidget {
  const EditProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/tomatoes.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            
            // Product details form
            TextFormField(
              initialValue: 'Fresh Tomatoes',
              decoration: const InputDecoration(
                labelText: 'Product Name',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: 'Freshly harvested organic tomatoes from our farm',
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '500',
                    decoration: const InputDecoration(
                      labelText: 'Price',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    value: 'kg',
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'kg',
                        child: Text('per kg'),
                      ),
                      DropdownMenuItem(
                        value: 'bunch',
                        child: Text('per bunch'),
                      ),
                      DropdownMenuItem(
                        value: 'piece',
                        child: Text('per piece'),
                      ),
                      DropdownMenuItem(
                        value: 'bag',
                        child: Text('per bag'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: '24',
              decoration: const InputDecoration(
                labelText: 'Available Stock',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: 'vegetables',
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'vegetables',
                  child: Text('Vegetables'),
                ),
                DropdownMenuItem(
                  value: 'fruits',
                  child: Text('Fruits'),
                ),
                DropdownMenuItem(
                  value: 'grains',
                  child: Text('Grains'),
                ),
                DropdownMenuItem(
                  value: 'drinks',
                  child: Text('Drinks'),
                ),
                DropdownMenuItem(
                  value: 'others',
                  child: Text('Others'),
                ),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Update Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                    customer: 'John M.',
                    items: 'Tomatoes (2kg), Onions (1kg)',
                    status: 'Processing',
                    date: 'Today, 10:30 AM',
                  ),
                  FarmerOrderCard(
                    orderId: '#CD-1233',
                    customer: 'Sarah K.',
                    items: 'Bananas (3 bunches)',
                    status: 'Shipped',
                    date: 'Yesterday, 2:15 PM',
                  ),
                  FarmerOrderCard(
                    orderId: '#CD-1232',
                    customer: 'Michael T.',
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
                    customer: 'John M.',
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
                    customer: 'Sarah K.',
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
                    customer: 'Michael T.',
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

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      onTap: () {},
    );
  }
}

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
            backgroundImage: AssetImage('assets/farmer_avatar.jpg'),
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