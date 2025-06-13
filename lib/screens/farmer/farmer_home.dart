import 'package:chopdirect/screens/farmer/farmer_order.dart';
import 'package:chopdirect/screens/farmer/farmers_dashbaord.dart';
import 'package:chopdirect/screens/farmer/farmers_product.dart';
import 'package:chopdirect/screens/farmer/farmers_profile.dart';
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
    FarmerDashboardScreen(),
    const FarmerProductsScreen(),
    const FarmerOrdersScreen(),
    const FarmerProfileScreen(),
  ];

  // Gamification elements
  final bool _showNewOrderBadge = true; // Would normally come from state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChopDirect Farmer'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Badge(
              smallSize: 8,
              child: const Icon(Icons.notifications, color: Colors.white),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildGamifiedNavBar(context),
    );
  }

  Widget _buildGamifiedNavBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade900, Colors.green.shade600],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: FontAwesomeIcons.house,
            label: 'Home',
            index: 0,
            isActive: _currentIndex == 0,
            glowColor: Colors.greenAccent,
          ),
          _buildNavItem(
            icon: FontAwesomeIcons.seedling,
            label: 'Products',
            index: 1,
            isActive: _currentIndex == 1,
            glowColor: Colors.lightGreenAccent,
            badgeIcon: Icons.local_florist,
          ),
          _buildNavItem(
            icon: FontAwesomeIcons.clipboardList,
            label: 'Orders',
            index: 2,
            isActive: _currentIndex == 2,
            showBadge: _showNewOrderBadge,
            glowColor: Colors.orangeAccent,
            badgeIcon: Icons.bolt,
          ),
          _buildNavItem(
            icon: FontAwesomeIcons.userAstronaut,
            label: 'Profile',
            index: 3,
            isActive: _currentIndex == 3,
            glowColor: Colors.amber,
            badgeIcon: Icons.star,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    bool showBadge = false,
    Color? glowColor,
    IconData? badgeIcon,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withOpacity(0.18) : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: (glowColor ?? Colors.amber).withOpacity(0.5),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                    border: isActive
                        ? Border.all(
                            color: (glowColor ?? Colors.amber).withOpacity(0.7),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                    size: 26,
                  ),
                ),
                if (showBadge)
                  Positioned(
                    top: -7,
                    right: -7,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: badgeIcon != null
                          ? Icon(badgeIcon, color: Colors.white, size: 12)
                          : const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 0.5,
                shadows: isActive
                    ? [
                        const Shadow(
                          color: Colors.black26,
                          blurRadius: 2,
                        )
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}