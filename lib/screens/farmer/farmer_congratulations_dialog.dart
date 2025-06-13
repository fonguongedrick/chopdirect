import 'package:chopdirect/constants/constanst.dart';
import 'package:flutter/material.dart';

class FarmerCongratulationsDialog extends StatelessWidget {
  final VoidCallback onClaim;
  final bool isLevelUp;
  final String farmLevel;
  final String userName;

  const FarmerCongratulationsDialog({
    super.key,
    required this.onClaim,
    required this.isLevelUp,
    required this.farmLevel,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.pureWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, color: AppColors.accentYellow, size: 56),
            const SizedBox(height: 12),
            Text(
              isLevelUp ? "LEVEL UP!" : "CONGRATULATIONS",
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              userName,
              style: TextStyle(
                color: AppColors.secondaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isLevelUp
                  ? "You have advanced to"
                  : "You have successfully registered as a",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "$farmLevel on ChopDirect.",
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 18),
            if (!isLevelUp)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      "REWARD",
                      style: TextStyle(
                        color: AppColors.accentYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt, color: AppColors.accentYellow, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          "You have earned ",
                          style: TextStyle(color: Colors.grey[800], fontSize: 14),
                        ),
                        Text(
                          "30XP",
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stars, color: AppColors.accentYellow, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          "You have earned ",
                          style: TextStyle(color: Colors.grey[800], fontSize: 14),
                        ),
                        Text(
                          "100 ChopPoints",
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "You are now a Rookie farmer under ChopDirect.\nKeep selling to go up the ranks.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.celebration, color: AppColors.pureWhite),
                label: Text(
                  isLevelUp ? "Continue" : "Claim Reward",
                  style: const TextStyle(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  shadowColor: AppColors.primaryGreen.withOpacity(0.2),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onClaim();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}