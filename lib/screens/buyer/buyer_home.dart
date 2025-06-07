import 'package:chopdirect/api/firebase_api.dart'; // Import Firebase API to track notifications
import 'package:chopdirect/screens/buyer/buyer_cart.dart';
import 'package:chopdirect/screens/buyer/buyer_leaderboard.dart';
import 'package:chopdirect/screens/buyer/buyer_product.dart';
import 'package:chopdirect/screens/buyer/buyer_profile.dart';
import 'package:chopdirect/screens/buyer/notifications.dart';
import 'package:chopdirect/screens/buyer/orders.dart';
import 'package:flutter/material.dart';

class BuyerHomeScreen extends StatefulWidget {
  final int initialIndex;
  const BuyerHomeScreen({super.key, this.initialIndex = 0});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  late int _currentIndex;
  Key notificationsKey = UniqueKey();
  final List<Widget> _pages = [
    const BuyerProductsScreen(),
    const OrdersScreen(),
    const BuyerLeaderboardScreen(),
    //  Notifications(),
    BuyerProfileScreen(),
  ];

  Widget _buildPage() {
    // Build the page according to _currentIndex.
    switch (_currentIndex) {
      case 0:
        return const BuyerProductsScreen();
      case 1:
        return const OrdersScreen();
      // case 2:
      //   return Notifications(key: notificationsKey); // Use your dynamic key here
      case 2:
        return BuyerLeaderboardScreen();
      case 3:
        return BuyerProfileScreen();  
      default:
        return const BuyerProductsScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem("assets/home.png", "Home", 0),
            _buildNavItem("assets/board.png", "Orders", 1),
             _buildNavItem("assets/board.png", "Learderboard", 2),
            // Wrap the Notifications nav item with ValueListenableBuilder:
            // ValueListenableBuilder(
            //   valueListenable: FirebaseApi.unreadNotifier,
            //   builder: (context, bool hasUnread, _) {
            //     return _buildNavItem("assets/notifications.png", "Notifications", 2, showDot: hasUnread);
            //   },
            // ),
            _buildNavItem("assets/profile.png", "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String iconPath, String label, int index, {bool showDot = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          if (index == 2) {
            // // When the Notifications tab is opened, mark notifications as read.
            // FirebaseApi.hasUnreadNotifications = false;
            // FirebaseApi.unreadNotifier.value = false;
          }
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              Image.asset(iconPath, color: _currentIndex == index ? Colors.green : Colors.grey),
              Text(
                label,
                style: TextStyle(color: _currentIndex == index ? Colors.green : Colors.grey),
              ),
            ],
          ),
          if (index == 2 && showDot)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
