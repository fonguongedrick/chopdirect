import 'package:chopdirect/screens/buyer/notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:chopdirect/screens/buyer/profile_menu_item.dart';
import 'package:chopdirect/screens/buyer/buyer_order_history.dart';

class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({Key? key}) : super(key: key);

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String userLocation = "Fetching location...";

  // Function to get user's current location using geolocator and geocoding.
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
      setState(() => userLocation = "Error retrieving location");
    }
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure that the user is logged in.
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: const Center(child: Text("User not logged in.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("users_chopdirect")
            .where("userId", isEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.green));
          } else if (snapshot.hasError) {
            return Center(
                child: Text("ERROR: ${snapshot.error}",
                    style: const TextStyle(color: Colors.black)));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("No user data available.",
                    style: TextStyle(color: Colors.black)));
          }

          // Retrieve the first matching document.
          Map<String, dynamic> user = snapshot.data!.docs.first.data();
          int loyaltyPoints = user["loyaltyPoints"] ?? 0;

          // Level thresholds with agricultural names
          const int seedlingThreshold = 100;
          const int harvestThreshold = 500;
          const int goldenThreshold = 2000;
          String currentLevel;
          double progressValue;
          String progressLabel;
          Color levelColor;

          if (loyaltyPoints < seedlingThreshold) {
            currentLevel = "Seedling Buyer";
            progressValue = loyaltyPoints / seedlingThreshold;
            progressLabel = "$loyaltyPoints/$seedlingThreshold points";
            levelColor = Colors.blue;
          } else if (loyaltyPoints < harvestThreshold) {
            currentLevel = "Harvest Buyer";
            progressValue =
                (loyaltyPoints - seedlingThreshold) / (harvestThreshold - seedlingThreshold);
            progressLabel = "$loyaltyPoints/$harvestThreshold points";
            levelColor = Colors.green;
          } else if (loyaltyPoints < goldenThreshold) {
            currentLevel = "Golden Farmer";
            progressValue =
                (loyaltyPoints - harvestThreshold) / (goldenThreshold - harvestThreshold);
            progressLabel = "$loyaltyPoints/$goldenThreshold points";
            levelColor = Colors.amber;
          } else {
            currentLevel = "Crop Master";
            progressValue = 1.0;
            progressLabel = "Max level achieved";
            levelColor = Colors.deepOrange;
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1B5E20),
                          Color(0xFF2E7D32),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60.0),
                        child: Animate(
                          effects: [
                            ScaleEffect(
                              duration: 600.ms,
                              curve: Curves.elasticOut, // Fixed animation curve
                            )
                          ],
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                pinned: true,
                backgroundColor: Colors.green,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  "My Farm Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // User Info Card
                      Animate(
                        effects: [
                          SlideEffect(
                              duration: 500.ms,
                              begin: const Offset(0, -0.3)
                          )
                        ],
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  user["name"] ?? "No User",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      userLocation,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "Orders",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "12",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "Reviews",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "8",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "Savings",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "₦15,200",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Loyalty Program Card
                      Animate(
                        effects: [
                          SlideEffect(
                            duration: 500.ms,
                            begin: const Offset(0, 0.3),
                          ),
                          FadeEffect(duration: 500.ms)
                        ],
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: levelColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: levelColor),
                                      ),
                                      child: Text(
                                        currentLevel,
                                        style: TextStyle(
                                          color: levelColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.leaderboard,
                                        color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      "$loyaltyPoints",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Loyalty Progress",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: progressValue,
                                    backgroundColor: Colors.grey[300],
                                    color: levelColor,
                                    minHeight: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  progressLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFEB3B),
                                      foregroundColor: Colors.green[800],
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Implement redeem points functionality here.
                                    },
                                    child: const Text(
                                      'Redeem Farm Rewards',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Profile Actions
                      Animate(
                        effects: [FadeEffect(duration: 500.ms)],
                        child: const Text(
                          "ACCOUNT SETTINGS",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // Profile Menu Items with staggered animations
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    // Add delay to each item
                    final animationDelay = Duration(milliseconds: index * 100);

                    return Animate(
                        effects: [
                        FadeEffect(duration: 400.ms),
                    SlideEffect(
                    duration: 400.ms,
                    begin: const Offset(0.2, 0)
                    )
                        ],
                    delay: animationDelay,
                    child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ProfileMenuItem(
                    icon: profileActions[index].icon,
                    title: profileActions[index].title,
                    onTap: () => profileActions[index].onTap(context),
                    ),
                    ),
                    );
                  },
                  childCount: profileActions.length,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
              // Logout Button
              SliverToBoxAdapter(
                child: Animate(
                  effects: [FadeEffect(duration: 600.ms)],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Profile actions data
  final List<ProfileAction> profileActions = [
    ProfileAction(
      icon: Icons.person,
      title: 'Edit Profile',
      onTap: (context) async {
        final result = await Navigator.pushNamed(context, "/editProfile");
        if (result == true) {
          // Refresh if needed
        }
      },
    ),
    ProfileAction(
      icon: Icons.location_on,
      title: 'My Farm Addresses',
      onTap: (context) {},
    ),
    ProfileAction(
      icon: Icons.credit_card,
      title: 'Payment Methods',
      onTap: (context) {},
    ),
    ProfileAction(
      icon: Icons.history,
      title: 'Order History',
      onTap: (context) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BuyerOrderHistory(),
        ),
      ),
    ),
    ProfileAction(
      icon: Icons.star,
      title: 'My Farm Reviews',
      onTap: (context) {},
    ),
    ProfileAction(
      icon: Icons.people,
      title: 'Refer a Farmer',
      onTap: (context) {},
    ),
    ProfileAction(
      icon: Icons.help_outline,
      title: 'Farm Support',
      onTap: (context) {},
    ),
    ProfileAction(
      icon: Icons.notifications,
      title: 'Notification Settings',
      onTap: (context) 
      {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Notifications()));
      },
    ),
  ];
}

class ProfileAction {
  final IconData icon;
  final String title;
  final Function(BuildContext) onTap;

  ProfileAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}