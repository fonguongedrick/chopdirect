import 'package:chopdirect/screens/buyer/buyer_order_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chopdirect/screens/buyer/profile_menu_item.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({Key? key}) : super(key: key);

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String userLocation = "Fetching location...";
  bool _isLoggingOut = false;

  Future<void> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => userLocation = "Location services are disabled");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => userLocation = "Location permission denied");
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() => userLocation = "${place.locality}, ${place.country}");
      } else {
        setState(() => userLocation = "Location not found");
      }
    } catch (e) {
      setState(() => userLocation = "Error retrieving location: $e");
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoggingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: const Center(child: Text("User not logged in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("users_chopdirect")
            .where("userId", isEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("ERROR: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No user data available."));
          }

          Map<String, dynamic> user = snapshot.data!.docs.first.data();
          int loyaltyPoints = user["loyaltyPoints"] ?? 0;

          const int silverThreshold = 500;
          const int goldenThreshold = 5000;

          String currentLevel;
          double progressValue;
          String progressLabel;

          if (loyaltyPoints < silverThreshold) {
            currentLevel = "Silver Farmer";
            progressValue = loyaltyPoints / silverThreshold;
            int progressPercent = (progressValue * 100).round();
            progressLabel = "$progressPercent% progress";
          } else if (loyaltyPoints < goldenThreshold) {
            currentLevel = "Golden Farmer";
            int pointsForGolden = goldenThreshold - silverThreshold;
            progressValue = (loyaltyPoints - silverThreshold) / pointsForGolden;
            int progressPercent = (progressValue * 100).round();
            progressLabel = "$progressPercent% progress";
          } else {
            currentLevel = "Special Buyer";
            progressValue = 1.0;
            progressLabel = "Max level achieved";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/Ellipse 7.png'),
                ),
                const SizedBox(height: 16),
                Text(
                  user["name"] ?? "No User",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(userLocation),
                const SizedBox(height: 24),

                // Loyalty Points Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Loyalty Points'),
                            Text(
                              "$loyaltyPoints",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Current Level'),
                            Text(
                              currentLevel,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(),
                        LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Colors.grey,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Center(child: Text(progressLabel)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              // Implement redeem points functionality
                            },
                            child: const Text('Redeem Points'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Profile Menu Items
                ProfileMenuItem(
                  icon: Icons.person,
                  title: 'Edit Profile',
                  onTap: () async {
                    final result = await Navigator.pushNamed(context, "/editProfile");
                    if (result == true && mounted) {
                      setState(() {});
                    }
                  },
                ),
                const ProfileMenuItem(icon: Icons.location_on, title: 'Addresses'),
                const ProfileMenuItem(icon: Icons.credit_card, title: 'Payment Methods'),
                ProfileMenuItem(
                  icon: Icons.history,
                  title: 'Order History',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BuyerOrderHistory(),
                    ),
                  ),
                ),
                const ProfileMenuItem(icon: Icons.star, title: 'My Reviews'),
                const ProfileMenuItem(icon: Icons.people, title: 'Refer a Friend'),
                const ProfileMenuItem(icon: Icons.help_outline, title: 'Help & Support'),
                const ProfileMenuItem(icon: Icons.settings, title: 'Settings'),
                const SizedBox(height: 16),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoggingOut ? null : _signOut,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoggingOut
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    )
                        : const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}