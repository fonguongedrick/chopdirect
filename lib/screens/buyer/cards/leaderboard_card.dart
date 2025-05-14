import 'package:flutter/material.dart';

class LeaderboardCard extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final String avatar;

  const LeaderboardCard({
    super.key,
    required this.rank,
    required this.name,
    required this.points,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rank == 1
                    ? Colors.amber
                    : rank == 2
                    ? Colors.grey[300]
                    : rank == 3
                    ? Colors.brown[200]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rank == 1 ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(avatar),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('$points points'),
                ],
              ),
            ),
            Icon(Icons.emoji_events,
                color: rank == 1
                    ? Colors.amber
                    : rank == 2
                    ? Colors.grey
                    : rank == 3
                    ? Colors.brown
                    : Colors.transparent),
          ],
        ),
      ),
    );
  }
}
