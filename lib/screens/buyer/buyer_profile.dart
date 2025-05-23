import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chopdirect/screens/buyer/profile_menu_item.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({super.key});

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

   String userLocation = "Fetching location...";

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    if (currentUser == null) {
      return Future.error("User not logged in");
    }
    String? userId = currentUser?.uid;
    if(userId == null){
      return Future.error("User not logged in");
    }
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection("users_chopdirect")
        .where("userId", isEqualTo: userId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return Future.error("No user data found!");
    }

    return querySnapshot.docs.first;
  }

  //to get user location
  Future<void> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => userLocation = "Location services are disabled");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() => userLocation = "Location permission denied");
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10), // ✅ Timeout to prevent indefinite waiting
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

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
  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Text(""),
        title: Text("Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("ERROR: ${snapshot.error}"));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No user data available."));
          }

          Map<String, dynamic>? user = snapshot.data?.data();
          if (user == null) {
            return const Center(child: Text("User data is missing."));
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

                // Profile Menu Items
                 ProfileMenuItem(
                    icon: Icons.person, title: 'Edit Profile',
                  onTap: (){
                      Navigator.pushNamed(context, "/editProfile");
                  },
                ),
                const ProfileMenuItem(icon: Icons.location_on, title: 'Addresses'),
                const ProfileMenuItem(icon: Icons.credit_card, title: 'Payment Methods'),
                const ProfileMenuItem(icon: Icons.history, title: 'Order History'),
                const ProfileMenuItem(icon: Icons.star, title: 'My Reviews'),
                const ProfileMenuItem(icon: Icons.people, title: 'Refer a Friend'),
                const ProfileMenuItem(icon: Icons.help_outline, title: 'Help & Support'),
                const ProfileMenuItem(icon: Icons.settings, title: 'Settings'),
                const SizedBox(height: 16),

                // Logout Button
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
        },
      ),
    );
  }
}
