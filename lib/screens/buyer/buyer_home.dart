import 'package:chopdirect/screens/buyer/buyer_cart.dart';
import 'package:chopdirect/screens/buyer/buyer_leaderboard.dart';
import 'package:chopdirect/screens/buyer/buyer_product.dart';
import 'package:chopdirect/screens/buyer/buyer_profile.dart';
import 'package:chopdirect/screens/buyer/notifications.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const BuyerProductsScreen(),
    const BuyerLeaderboardScreen(),
    const Notifications(),
     BuyerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
              child: Column(
                children: [
                  Image.asset("assets/home.png",
                   color: _currentIndex == 0 ? Colors.green : Colors.grey,
                  ),
                  Text("Home",
                   style: TextStyle(
                     color: _currentIndex ==0? Colors.green : Colors.grey
                   ),
                  ),
                ],
              ),
            ),

            GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
              child: Column(
                children: [
                  Image.asset("assets/board.png",
                    color: _currentIndex == 1 ? Colors.green : Colors.grey,
                  ),
                  Text("leaderboard",
                    style: TextStyle(
                        color: _currentIndex ==1? Colors.green : Colors.grey
                    ),
                  ),
                ],
              ),
            ),

            GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
              child: Column(
                children: [
                  Image.asset("assets/notifications.png",
                    color: _currentIndex == 2 ? Colors.green : Colors.grey,
                  ),
                  Text("notifications",
                    style: TextStyle(
                        color: _currentIndex ==2? Colors.green : Colors.grey
                    ),
                  ),
                ],
              ),
            ),

            GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 3;
                });
              },
              child: Column(
                children: [
                  Image.asset("assets/profile.png",
                    color: _currentIndex == 3 ? Colors.green : Colors.grey,
                  ),
                  Text("profile",
                    style: TextStyle(
                        color: _currentIndex ==3? Colors.green : Colors.grey
                    ),
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
















