import 'package:chopdirect/screens/buyer/cards/leaderboard_card.dart';
import 'package:flutter/material.dart';

class BuyerLeaderboardScreen extends StatelessWidget {
  const BuyerLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Top Buyers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const LeaderboardCard(
            rank: 1,
            name: 'Nfon Ashi(You)',
            points: 1250,
            avatar: 'assets/Ellipse 7.png',
          ),
          const LeaderboardCard(
            rank: 2,
            name: 'Ngwa Joseph.',
            points: 980,
            avatar: 'assets/Ellipse 7.png',
          ),
          const LeaderboardCard(
            rank: 3,
            name: 'Neba James.',
            points: 870,
            avatar: 'assets/Ellipse 7.png',
          ),
          const LeaderboardCard(
            rank: 4,
            name: 'Ndoh Peter.',
            points: 750,
            avatar: 'assets/Ellipse 7.png',
          ),
          const LeaderboardCard(
            rank: 5,
            name: 'Afuh Joy.',
            points: 680,
            avatar: 'assets/Ellipse 7.png',
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Stats',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your Rank'),
                      Text('#12'),
                    ],
                  ),
                  const Divider(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your Points'),
                      Text('420'),
                    ],
                  ),
                  const Divider(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Days Active'),
                      Text('5'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('View All Badges'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
