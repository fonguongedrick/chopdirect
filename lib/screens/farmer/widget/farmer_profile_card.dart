import 'package:chopdirect/constants/constanst.dart';
import 'package:chopdirect/screens/farmer/widget/farm_levels.dart';
import 'package:flutter/material.dart';

class FarmerProfileCard extends StatelessWidget {
  final String farmerName;
  final String farmLevel;
  final int xp;
  final int chopPoints;
  final int levelIndex;
  final int dailyStreak;
  final bool isSmall;

  const FarmerProfileCard({
    super.key,
    required this.farmerName,
    required this.farmLevel,
    required this.xp,
    required this.chopPoints,
    required this.levelIndex,
    required this.dailyStreak,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmall ? 10.0 : 20.0),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accentYellow,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: isSmall ? 26 : 36,
                        backgroundColor: AppColors.pureWhite,
                        backgroundImage: const AssetImage('assets/farm1.jpeg'),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.amber[700],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: isSmall ? 14 : 18,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: isSmall ? 10 : 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, $farmerName!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmall ? 15 : 20,
                          color: AppColors.pureWhite,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmall ? 2 : 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.verified, color: Colors.amber[800], size: isSmall ? 13 : 16),
                                const SizedBox(width: 4),
                                Text(
                                  farmLevel,
                                  style: TextStyle(
                                    color: Colors.amber[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmall ? 11 : 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmall ? 4 : 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.bolt,
                            color: AppColors.accentYellow,
                            size: isSmall ? 16 : 22,
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
                    const SizedBox(height: 4),
                    Text(
                      'Streak',
                      style: TextStyle(
                        color: Colors.amber[100],
                        fontSize: isSmall ? 9 : 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: isSmall ? 10 : 18),
            // XP Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'XP Progress',
                  style: TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: isSmall ? 11 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: xpProgress,
                    backgroundColor: Colors.white.withOpacity(0.13),
                    color: AppColors.accentYellow,
                    minHeight: isSmall ? 8 : 12,
                  ),
                ),
                SizedBox(height: 2),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    nextLevel != null
                        ? '${xp - currentLevel["xp"]}/${nextLevel["xp"] - currentLevel["xp"]} XP to next level'
                        : 'Max Level',
                    style: TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: isSmall ? 9 : 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: isSmall ? 6 : 10),
                Text(
                  'ChopPoints Progress',
                  style: TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: isSmall ? 11 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: chopPointsProgress,
                    backgroundColor: Colors.white.withOpacity(0.13),
                    color: AppColors.primaryGreen,
                    minHeight: isSmall ? 8 : 12,
                  ),
                ),
                SizedBox(height: 2),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    nextLevel != null
                        ? '${chopPoints - currentLevel["chopPoints"]}/${nextLevel["chopPoints"] - currentLevel["chopPoints"]} ChopPoints to next level'
                        : 'Max Level',
                    style: TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: isSmall ? 9 : 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}