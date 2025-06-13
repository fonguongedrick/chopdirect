import 'package:chopdirect/constants/constanst.dart';
import 'package:chopdirect/screens/farmer/cards/dashboardstat_card.dart';
import 'package:flutter/material.dart';


class FarmerStatsGrid extends StatelessWidget {
  final bool isSmall;
  final bool isTablet;
  final int productCount;
  final int orderCount;
  final double rating;
  final double earnings;
  final bool isLoading;

  const FarmerStatsGrid({
    super.key,
    required this.isSmall,
    required this.isTablet,
    required this.productCount,
    required this.orderCount,
    required this.rating,
    required this.earnings,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
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
            ),
            DashboardStatCard(
              icon: Icons.receipt,
              value: isLoading ? '...' : '$orderCount',
              label: 'Orders',
              color: Colors.blue,
              progress: orderCount / 15,
              iconBackground: Colors.blue.withOpacity(0.1),
              showMedal: orderCount >= 5,
              medalColor: Colors.blue,
            ),
            DashboardStatCard(
              icon: Icons.star,
              value: rating.toStringAsFixed(1),
              label: 'Rating',
              color: Colors.amber,
              progress: rating / 5,
              iconBackground: Colors.amber.withOpacity(0.1),
              showMedal: rating >= 4.5,
              medalColor: Colors.amber,
            ),
            DashboardStatCard(
              icon: Icons.attach_money,
              value: 'XAF ${earnings.toStringAsFixed(0)}',
              label: 'Earnings',
              color: Colors.purple,
              progress: earnings / 500000,
              iconBackground: Colors.purple.withOpacity(0.1),
              showMedal: earnings >= 100000,
              medalColor: Colors.purple,
            ),
          ],
        );
      },
    );
  }
}