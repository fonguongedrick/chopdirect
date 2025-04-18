import 'package:flutter/material.dart';

class FarmerOrderCard extends StatelessWidget {
  final String orderId;
  final String customer;
  final String items;
  final String status;
  final String date;

  const FarmerOrderCard({
    super.key,
    required this.orderId,
    required this.customer,
    required this.items,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    if (status == 'Processing') {
      statusColor = Colors.orange;
    } else if (status == 'Shipped') {
      statusColor = Colors.blue;
    } else if (status == 'Delivered') {
      statusColor = Colors.green;
    } else if (status == 'Cancelled') {
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              customer,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(items),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
