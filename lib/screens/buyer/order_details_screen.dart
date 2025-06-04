import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${orderId.substring(0, 8)}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Status', orderData['status'] ?? 'pending'),
            _buildDetailRow('Order Date',
                orderData['timestamp']?.toDate().toString().substring(0, 16) ?? 'N/A'),
            _buildDetailRow('Subtotal',
                '${orderData['subtotal']?.toStringAsFixed(2)} XAF'),
            _buildDetailRow('Delivery Fee',
                '${orderData['deliveryFee']?.toStringAsFixed(2)} XAF'),
            _buildDetailRow('Total',
                '${orderData['totalAmount']?.toStringAsFixed(2)} XAF'),

            const SizedBox(height: 20),
            const Text(
              'Order Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            if (orderData['items'] != null && orderData['items'].length > 0)
              ...orderData['items'].map<Widget>((item) =>
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['imageUrl'] ?? '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? 'Unknown Item',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Quantity: ${item['quantity'] ?? 1}'),
                              Text('Price: ${item['price']?.toStringAsFixed(2)} XAF'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ).toList()
            else
              const Text('No items information available'),

            const SizedBox(height: 30),
            // Add tracking information or other details as needed
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}