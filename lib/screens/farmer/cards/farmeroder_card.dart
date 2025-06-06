import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FarmerOrderCard extends StatelessWidget {
  final String orderId;
  final String orderNumber;
  final String customer;
  final List<Map<String, dynamic>> items;
  final String status;
  final String date;
  final double totalAmount;
  final double rating;

  const FarmerOrderCard({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.customer,
    required this.items,
    required this.status,
    required this.date,
    required this.totalAmount,
    this.rating = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header with number and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Customer information
            Text(
              'Customer: $customer',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Order items list
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• ${item['name']} (${item['quantity']}${item['unit']}) - XAF ${item['price']}',
                  style: const TextStyle(fontSize: 14),
                ),
              )).toList(),
            ),
            const SizedBox(height: 8),

            // Total amount
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: XAF $totalAmount',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Status and rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status chip
                Chip(
                  label: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: _getStatusColor(status),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),

                // Rating indicator (only shown if rating > 0)
                if (rating > 0)
                  Row(
                    children: [
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      RatingBarIndicator(
                        rating: rating,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 16.0,
                        direction: Axis.horizontal,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.lightBlue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}