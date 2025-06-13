import 'package:chopdirect/constants/constanst.dart';
import 'package:chopdirect/screens/farmer/add_product.dart';
import 'package:chopdirect/screens/farmer/cards/dashboardstat_card.dart';
import 'package:chopdirect/screens/farmer/cards/farmeroder_card.dart';
import 'package:chopdirect/screens/farmer/farmer_congratulations_dialog.dart';
import 'package:chopdirect/screens/farmer/farmer_earnings.dart';
import 'package:chopdirect/screens/farmer/farmer_order.dart';
import 'package:chopdirect/screens/farmer/widget/farm_levels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  String farmerName = "Farmer";
  int productCount = 0;
  int orderCount = 0;
  double rating = 0.0;
  double earnings = 0.0;
  int dailyStreak = 3;
  int completedGoals = 2;
  bool isLoading = true;

  int xp = 0;
  int chopPoints = 0;
  int levelIndex = 0;
  String farmLevel = "Rookie Farmer";
  bool showCongratsDialog = false;
  bool showLevelUpDialog = false;
  bool justRegistered = false;

  @override
  void initState() {
    super.initState();
    _loadFarmerData();
  }

  Future<void> _loadFarmerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final farmerDoc = await FirebaseFirestore.instance
            .collection('farmers_chopdirect')
            .doc(user.uid)
            .get();

        if (farmerDoc.exists) {
          final data = farmerDoc.data()!;
          setState(() {
            farmerName = data['name'] ?? "Farmer";
            xp = data['xp'] ?? 0;
            chopPoints = data['chopPoints'] ?? 0;
            farmLevel = data['farmLevel'] ?? "Rookie Farmer";
            justRegistered = data['justRegistered'] ?? false;
            dailyStreak = data['dailyStreak'] ?? 3;
            completedGoals = data['completedGoals'] ?? 2;
          });

          int newLevelIndex = getLevelIndex(xp, chopPoints);
          String newLevelName = farmLevels[newLevelIndex]["name"];
          if (newLevelName != farmLevel) {
            await FirebaseFirestore.instance
                .collection('farmers_chopdirect')
                .doc(user.uid)
                .update({
              "farmLevel": newLevelName,
            });
            setState(() {
              farmLevel = newLevelName;
              levelIndex = newLevelIndex;
              showLevelUpDialog = true;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => FarmerCongratulationsDialog(
                  isLevelUp: true,
                  farmLevel: newLevelName,
                  userName: farmerName,
                  onClaim: () {
                    setState(() {
                      showLevelUpDialog = false;
                    });
                  },
                ),
              );
            });
          } else {
            setState(() {
              levelIndex = newLevelIndex;
            });
          }

          if (justRegistered && !showCongratsDialog) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => FarmerCongratulationsDialog(
                  isLevelUp: false,
                  farmLevel: farmLevel,
                  userName: farmerName,
                  onClaim: () async {
                    await FirebaseFirestore.instance
                        .collection('farmers_chopdirect')
                        .doc(user.uid)
                        .set({
                      "xp": FieldValue.increment(30),
                      "chopPoints": FieldValue.increment(100),
                      "farmLevel": "Rookie Farmer",
                      "justRegistered": false,
                    }, SetOptions(merge: true));
                    setState(() {
                      xp += 30;
                      chopPoints += 100;
                      justRegistered = false;
                      showCongratsDialog = true;
                    });
                    _loadFarmerData();
                  },
                ),
              );
            });
          }
        }

        final productsQuery = await FirebaseFirestore.instance
            .collection('products')
            .where('farmerId', isEqualTo: user.uid)
            .get();

        final ordersQuery = await FirebaseFirestore.instance
            .collection('orders')
            .where('farmerId', isEqualTo: user.uid)
            .get();

        double totalEarnings = 0;
        for (var doc in ordersQuery.docs) {
          if (doc.data()['status'] == 'completed') {
            totalEarnings += (doc.data()['totalAmount'] ?? 0).toDouble();
          }
        }

        setState(() {
          productCount = productsQuery.docs.length;
          orderCount = ordersQuery.docs.length;
          earnings = totalEarnings;
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final isSmall = screenWidth < 400;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: Animate(
        effects: [
          ScaleEffect(
            duration: 2000.ms,
            curve: Curves.easeInOut,
          ),
          ShakeEffect(
            duration: 1000.ms,
            hz: 4,
            curve: Curves.easeInOut,
          ),
        ],
        onPlay: (controller) => controller.repeat(),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddProductScreen(),
              ),
            ).then((_) => _loadFarmerData());
          },
          icon: const Icon(Icons.add, color: AppColors.pureWhite),
          label: const Text(
            "Add Product",
            style: TextStyle(
              color: AppColors.pureWhite,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: AppColors.primaryGreen,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 6 : 16,
              vertical: isSmall ? 8 : 16,
            ),
            child: Column(
              children: [
                _buildProfileCard(isSmall: isSmall).animate().fadeIn().slideY(duration: 300.ms),
                SizedBox(height: isSmall ? 8 : 16),
                _buildStatsGrid(isSmall: isSmall, isTablet: isTablet),
                SizedBox(height: isSmall ? 8 : 16),
                _buildQuestCard(isSmall: isSmall),
                SizedBox(height: isSmall ? 8 : 16),
                _buildQuickActions(isSmall: isSmall, isTablet: isTablet),
                SizedBox(height: isSmall ? 8 : 16),
                _buildAchievementsSection(isSmall: isSmall, isTablet: isTablet),
                SizedBox(height: isSmall ? 8 : 16),
                _buildRecentOrders(isSmall: isSmall),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard({bool isSmall = false}) {
    Map<String, dynamic> currentLevel = farmLevels[levelIndex];
    Map<String, dynamic>? nextLevel = getNextLevel(levelIndex);

    double xpProgress = nextLevel != null
        ? (xp - currentLevel["xp"]) / (nextLevel["xp"] - currentLevel["xp"])
        : 1.0;
    double chopPointsProgress = nextLevel != null
        ? (chopPoints - currentLevel["chopPoints"]) /
            (nextLevel["chopPoints"] - currentLevel["chopPoints"])
        : 1.0;

    xpProgress = xpProgress.clamp(0.0, 1.0);
    chopPointsProgress = chopPointsProgress.clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmall ? 10.0 : 16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accentYellow,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: isSmall ? 22 : 30,
                    backgroundColor: AppColors.pureWhite,
                    backgroundImage: const AssetImage('assets/farm1.jpeg'),
                  ),
                ),
                SizedBox(width: isSmall ? 8 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, $farmerName!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmall ? 14 : 18,
                          color: AppColors.pureWhite,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmall ? 2 : 4),
                      Text(
                        currentLevel["name"],
                        style: TextStyle(
                          color: AppColors.accentYellow,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmall ? 12 : 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmall ? 4 : 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.bolt,
                            color: AppColors.accentYellow,
                            size: isSmall ? 16 : 24,
                          ),
                          Text(
                            '$dailyStreak',
                            style: TextStyle(
                              color: AppColors.pureWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmall ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: isSmall ? 8 : 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'XP Progress',
                  style: TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: isSmall ? 10 : 12,
                  ),
                ),
                SizedBox(height: 2),
                Stack(
                  children: [
                    LinearProgressIndicator(
                      value: xpProgress,
                      backgroundColor: Colors.black.withOpacity(0.2),
                      color: AppColors.accentYellow,
                      minHeight: isSmall ? 8 : 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          nextLevel != null
                              ? '${xp - currentLevel["xp"]}/${nextLevel["xp"] - currentLevel["xp"]} XP to next level'
                              : 'Max Level',
                          style: TextStyle(
                            color: AppColors.pureWhite,
                            fontSize: isSmall ? 8 : 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmall ? 4 : 8),
                Text(
                  'ChopPoints Progress',
                  style: TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: isSmall ? 10 : 12,
                  ),
                ),
                SizedBox(height: 2),
                Stack(
                  children: [
                    LinearProgressIndicator(
                      value: chopPointsProgress,
                      backgroundColor: Colors.black.withOpacity(0.2),
                      color: AppColors.primaryGreen,
                      minHeight: isSmall ? 8 : 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          nextLevel != null
                              ? '${chopPoints - currentLevel["chopPoints"]}/${nextLevel["chopPoints"] - currentLevel["chopPoints"]} ChopPoints to next level'
                              : 'Max Level',
                          style: TextStyle(
                            color: AppColors.pureWhite,
                            fontSize: isSmall ? 8 : 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid({bool isSmall = false, bool isTablet = false}) {
    int crossAxisCount = isTablet ? 3 : 2;
    double childAspectRatio = isSmall ? 1 : 1.2;
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: isSmall ? 6 : 12,
          mainAxisSpacing: isSmall ? 6 : 12,
          children: [
            DashboardStatCard(
              icon: Icons.shopping_basket,
              value: isLoading ? '...' : '$productCount',
              label: 'Products',
              color: AppColors.primaryGreen,
              progress: productCount / 20,
              iconBackground: AppColors.primaryGreen.withOpacity(0.1),
              showMedal: productCount >= 10,
              medalColor: AppColors.accentYellow,
            ).animate().fadeIn(delay: 100.ms),
            DashboardStatCard(
              icon: Icons.receipt,
              value: isLoading ? '...' : '$orderCount',
              label: 'Orders',
              color: Colors.blue,
              progress: orderCount / 15,
              iconBackground: Colors.blue.withOpacity(0.1),
              showMedal: orderCount >= 5,
              medalColor: Colors.blue,
            ).animate().fadeIn(delay: 200.ms),
            DashboardStatCard(
              icon: Icons.star,
              value: rating.toStringAsFixed(1),
              label: 'Rating',
              color: Colors.amber,
              progress: rating / 5,
              iconBackground: Colors.amber.withOpacity(0.1),
              showMedal: rating >= 4.5,
              medalColor: Colors.amber,
            ).animate().fadeIn(delay: 300.ms),
            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                 MaterialPageRoute(builder: (context) => const MyEarnings()),
                  );
              },
              child: DashboardStatCard(
                icon: Icons.attach_money,
                value: 'XAF ${earnings.toStringAsFixed(0)}',
                label: 'Earnings',
                color: Colors.purple,
                progress: earnings / 500000,
                iconBackground: Colors.purple.withOpacity(0.1),
                showMedal: earnings >= 100000,
                medalColor: Colors.purple,
              ).animate().fadeIn(delay: 400.ms),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuestCard({bool isSmall = false}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmall ? 10.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmall ? 2 : 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.flag, color: AppColors.primaryGreen, size: isSmall ? 16 : 20),
                ),
                SizedBox(width: isSmall ? 4 : 8),
                Text(
                  'Daily Quests',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 13 : 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isSmall ? 4 : 8, vertical: isSmall ? 2 : 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completedGoals/3 completed',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmall ? 11 : 13,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmall ? 6 : 12),
            _buildQuestItem(
              'Add 1 Product',
              completedGoals >= 1,
              Icons.add,
              AppColors.primaryGreen,
              isSmall: isSmall,
            ),
            _buildQuestItem(
              'Process 3 Orders',
              completedGoals >= 2,
              Icons.local_shipping,
              Colors.blue,
              isSmall: isSmall,
            ),
            _buildQuestItem(
              'Earn XAF 10,000',
              completedGoals >= 3,
              Icons.attach_money,
              Colors.amber,
              isSmall: isSmall,
            ),
            SizedBox(height: isSmall ? 4 : 8),
            LinearProgressIndicator(
              value: completedGoals / 3,
              backgroundColor: Colors.grey[200],
              color: AppColors.primaryGreen,
              minHeight: isSmall ? 5 : 8,
              borderRadius: BorderRadius.circular(4),
            ),
            SizedBox(height: isSmall ? 4 : 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  if (completedGoals >= 3) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('+50 XP for completing quests!'),
                        backgroundColor: AppColors.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: completedGoals >= 3
                      ? AppColors.primaryGreen
                      : Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 10 : 16,
                    vertical: isSmall ? 6 : 10,
                  ),
                ),
                child: Text(
                  'Claim Reward',
                  style: TextStyle(
                    color: completedGoals >= 3
                        ? AppColors.pureWhite
                        : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 12 : 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildQuestItem(String title, bool completed, IconData icon, Color color, {bool isSmall = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 3 : 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSmall ? 18 : 24,
            height: isSmall ? 18 : 24,
            decoration: BoxDecoration(
              color: completed ? color.withOpacity(0.2) : Colors.grey[200],
              shape: BoxShape.circle,
              border: Border.all(
                color: completed ? color : Colors.grey[400]!,
              ),
            ),
            child: completed
                ? Icon(Icons.check, size: isSmall ? 12 : 16, color: color)
                : null,
          ),
          SizedBox(width: isSmall ? 6 : 12),
          Icon(icon, size: isSmall ? 14 : 20, color: completed ? color : Colors.grey[600]),
          SizedBox(width: isSmall ? 4 : 8),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isSmall ? 11 : 14,
                decoration: completed ? TextDecoration.lineThrough : null,
                color: completed ? Colors.grey : Colors.black,
                fontWeight: completed ? FontWeight.normal : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions({bool isSmall = false, bool isTablet = false}) {
    int crossAxisCount = isTablet ? 4 : 3;
    double childAspectRatio = isSmall ? 0.9 : 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 15 : 18,
          ),
        ).animate().fadeIn(delay: 600.ms),
        SizedBox(height: isSmall ? 4 : 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: isSmall ? 4 : 8,
          mainAxisSpacing: isSmall ? 4 : 8,
          children: [
            _buildActionButton(
              Icons.add,
              'Add Product',
              AppColors.primaryGreen,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProductScreen(),
                  ),
                ).then((_) => _loadFarmerData());
              },
              hasBadge: productCount >= 5,
              isSmall: isSmall,
            ),
            _buildActionButton(
              Icons.local_shipping,
              'Orders',
              Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FarmerOrdersScreen(),
                  ),
                );
              },
              hasBadge: orderCount >= 3,
              isSmall: isSmall,
            ),
            _buildActionButton(
              Icons.bar_chart,
              'Stats',
              Colors.orange,
              onTap: () {},
              hasBadge: earnings >= 50000,
              isSmall: isSmall,
            ),
            _buildActionButton(
              Icons.people,
              'Customers',
              Colors.purple,
              onTap: () {},
              hasBadge: orderCount >= 10,
              isSmall: isSmall,
            ),
            _buildActionButton(
              Icons.share,
              'Refer',
              Colors.teal,
              onTap: () {},
              isSmall: isSmall,
            ),
            _buildActionButton(
              Icons.help_outline,
              'Help',
              Colors.red,
              onTap: () {},
              isSmall: isSmall,
            ),
          ].animate(interval: 100.ms).fadeIn(),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, Color color,
      {VoidCallback? onTap, bool hasBadge = false, bool isSmall = false}) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: AppColors.pureWhite,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(isSmall ? 6 : 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmall ? 4 : 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: isSmall ? 18 : 24, color: color),
                  ),
                  SizedBox(height: isSmall ? 4 : 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: isSmall ? 10 : 12),
                  ),
                ],
              ),
            ),
            if (hasBadge)
              Positioned(
                top: isSmall ? 2 : 4,
                right: isSmall ? 2 : 4,
                child: Container(
                  padding: EdgeInsets.all(isSmall ? 2 : 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    size: isSmall ? 8 : 10,
                    color: AppColors.pureWhite,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection({bool isSmall = false, bool isTablet = false}) {
    double badgeSize = isSmall ? 54 : 70;
    double iconSize = isSmall ? 24 : 32;
    double fontSize = isSmall ? 10 : 12;
    double descFontSize = isSmall ? 8 : 10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Achievements',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 15 : 18,
          ),
        ).animate().fadeIn(delay: 700.ms),
        SizedBox(height: isSmall ? 4 : 8),
        SizedBox(
          height: badgeSize + 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAchievementBadge(
                'First Sale',
                Icons.emoji_events,
                AppColors.accentYellow,
                completed: true,
                description: 'Made your first sale',
                badgeSize: badgeSize,
                iconSize: iconSize,
                fontSize: fontSize,
                descFontSize: descFontSize,
              ),
              _buildAchievementBadge(
                'Pro Farmer',
                Icons.agriculture,
                AppColors.primaryGreen,
                completed: productCount >= 10,
                description: '10+ products',
                badgeSize: badgeSize,
                iconSize: iconSize,
                fontSize: fontSize,
                descFontSize: descFontSize,
              ),
              _buildAchievementBadge(
                'Top Seller',
                Icons.star,
                Colors.purple,
                completed: earnings >= 100000,
                description: 'XAF 100K+ earned',
                badgeSize: badgeSize,
                iconSize: iconSize,
                fontSize: fontSize,
                descFontSize: descFontSize,
              ),
              _buildAchievementBadge(
                'Daily Streak',
                Icons.bolt,
                Colors.orange,
                completed: dailyStreak >= 7,
                description: '7-day streak',
                badgeSize: badgeSize,
                iconSize: iconSize,
                fontSize: fontSize,
                descFontSize: descFontSize,
              ),
              _buildAchievementBadge(
                'Customer Favorite',
                Icons.favorite,
                Colors.red,
                completed: rating >= 4.5,
                description: '4.5+ rating',
                badgeSize: badgeSize,
                iconSize: iconSize,
                fontSize: fontSize,
                descFontSize: descFontSize,
              ),
            ].animate(interval: 100.ms).slideX(begin: 0.5, end: 0),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(
      String title, IconData icon, Color color,
      {bool completed = false,
      String description = '',
      double badgeSize = 70,
      double iconSize = 32,
      double fontSize = 12,
      double descFontSize = 10}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              gradient: completed
                  ? LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: completed ? null : Colors.grey[200],
              shape: BoxShape.circle,
              border: Border.all(
                color: completed ? color : Colors.grey[400]!,
                width: 2,
              ),
              boxShadow: completed
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: completed ? AppColors.pureWhite : Colors.grey[500],
                ),
                if (completed)
                  Positioned(
                    bottom: 8,
                    child: Icon(
                      Icons.check_circle,
                      size: iconSize / 2,
                      color: AppColors.pureWhite,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: completed ? color : Colors.grey[600],
            ),
          ),
          Text(
            description,
            style: TextStyle(
              fontSize: descFontSize,
              color: completed ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders({bool isSmall = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 15 : 18,
          ),
        ).animate().fadeIn(delay: 800.ms),
        SizedBox(height: isSmall ? 4 : 8),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('farmerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .orderBy('createdAt', descending: true)
              .limit(2)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(isSmall ? 10.0 : 16.0),
                  child: Text(
                    'No recent orders',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: isSmall ? 12 : 14),
                  ),
                ),
              );
            }

            return Column(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return FarmerOrderCard(
                  orderId: data['orderId'] ?? '#CD-0000',
                  customer: data['customerName'] ?? 'Customer',
                  items: _formatItems(data['items']),
                  status: data['status'] ?? 'Pending',
                  date: _formatDate(data['createdAt']),
                ).animate().fadeIn(delay: 100.ms);
              }).toList(),
            );
          },
        ),
        SizedBox(height: isSmall ? 4 : 8),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FarmerOrdersScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 14 : 24, vertical: isSmall ? 8 : 12),
            ),
            child: Text(
              'View All Orders',
              style: TextStyle(color: AppColors.pureWhite, fontSize: isSmall ? 12 : 14),
            ),
          ),
        ).animate().fadeIn(delay: 900.ms),
      ],
    );
  }

  String _formatItems(dynamic items) {
    if (items is List) {
      return items.take(2).map((item) => item['name']).join(', ') +
          (items.length > 2 ? ' +${items.length - 2} more' : '');
    }
    return 'Multiple items';
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Recently';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date.isAfter(today)) {
      return 'Today, ${_formatTime(date)}';
    } else if (date.isAfter(yesterday)) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}