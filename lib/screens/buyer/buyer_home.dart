import 'package:chopdirect/screens/buyer/buyer_product_screen.dart';
import 'package:chopdirect/screens/buyer/notifications.dart';
import 'package:flutter/material.dart';

import 'buyer_leaderboard.dart';
import 'buyer_profile.dart';
import 'orders.dart';

/// Global ValueNotifier for order badge count.
/// In a real app, consider using Provider, Riverpod, or Bloc for state management.
final ValueNotifier<int> ordersBadgeCountNotifier = ValueNotifier<int>(0);

/// Global ValueNotifier for notifications badge count.
final ValueNotifier<int> notificationsBadgeCountNotifier = ValueNotifier<int>(0);

class BuyerHomeScreen extends StatefulWidget {
  final int initialIndex;
  const BuyerHomeScreen({super.key, this.initialIndex = 0});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _controller;

  // Updated pages list with NotificationsScreen added at index 2.
  final List<Widget> _pages = [
    const BuyerProductsScreen(),    // Index 0: Home
    const OrdersScreen(),             // Index 1: Orders
     const Notifications(),      // Index 2: Notifications
    // const BuyerLeaderboardScreen(),   // Index 3: Leaderboard
      const BuyerProfileScreen(),             // Index 4: Profile
  ];

  // Example: Badge count for leaderboard (could come from your backend).
  int _leaderboardBadgeCount = 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _controller.repeat(reverse: true);
    
    // Make sure your app subscribes to the topic from your notification setup.
    // For example, you might call:
    // FirebaseMessaging.instance.subscribeToTopic("order_updates");
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Gamified color palette.
  static const Color kActiveColor = Color(0xFF00E676);
  static const Color kInactiveColor = Color(0xFFBDBDBD);
  static const Color kNavBarBg = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildGamifiedNavBar(),
    );
  }

  Widget _buildGamifiedNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: kNavBarBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          _buildNavItem(
            iconPath: "assets/homes.png",
            label: "Home",
            index: 0,
            badge: null,
            animated: true,
          ),
          // Orders (with reactive badge)
          ValueListenableBuilder<int>(
            valueListenable: ordersBadgeCountNotifier,
            builder: (context, badgeCount, child) {
              return _buildNavItem(
                iconPath: "assets/orders.png",
                label: "Orders",
                index: 1,
                badge: badgeCount > 0 ? badgeCount.toString() : null,
                animated: false,
              );
            },
          ),
          // Notifications (with reactive badge)
          ValueListenableBuilder<int>(
            valueListenable: notificationsBadgeCountNotifier,
            builder: (context, badgeCount, child) {
              return _buildNavItem(
                iconPath: "assets/notifications.png",
                label: "Notifications",
                index: 2,
                badge: badgeCount > 0 ? badgeCount.toString() : null,
                animated: false,
              );
            },
          ),
          // Leaderboard
          // _buildNavItem(
          //   iconPath: "assets/leader.png",
          //   label: "Leaderboard",
          //   index: 3,
          //   badge: _leaderboardBadgeCount > 0 ? "!" : null,
          //   animated: false,
          // ),
          // Profile
          _buildNavItem(
            iconPath: "assets/profile.png",
            label: "Profile",
            index: 3,
            badge: null,
            animated: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String iconPath,
    required String label,
    required int index,
    String? badge,
    bool animated = false,
  }) {
    final bool isActive = _currentIndex == index;

    // Gamified glow effect for active item.
    final Widget iconWidget = animated && isActive
        ? AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kActiveColor.withOpacity(0.5 + 0.3 * _controller.value),
                      blurRadius: 16 + 8 * _controller.value,
                      spreadRadius: 2 + 2 * _controller.value,
                    ),
                  ],
                ),
                child: Image.asset(
                  iconPath,
                  width: 38 + 6 * _controller.value,
                  height: 38 + 6 * _controller.value,
                  color: kActiveColor,
                ),
              );
            },
          )
        : Image.asset(
            iconPath,
            width: isActive ? 38 : 32,
            height: isActive ? 38 : 32,
            color: isActive ? kActiveColor : kInactiveColor,
          );

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        // Optionally trigger an animation, confetti, or sound effect for gamification.
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          vertical: isActive ? 10 : 6,
          horizontal: isActive ? 18 : 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? kActiveColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: isActive
              ? Border.all(color: kActiveColor, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                iconWidget,
                if (badge != null)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 350),
              style: TextStyle(
                color: isActive ? kActiveColor : kInactiveColor,
                fontSize: isActive ? 15 : 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                shadows: isActive
                    ? [Shadow(color: kActiveColor.withOpacity(0.4), blurRadius: 8)]
                    : [],
              ),
              child: Text(label),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 4,
                width: 24,
                decoration: BoxDecoration(
                  color: kActiveColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: kActiveColor.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
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
