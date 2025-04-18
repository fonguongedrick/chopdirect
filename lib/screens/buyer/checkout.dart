import 'package:chopdirect/screens/buyer/cards/paymentmethod_card.dart';
import 'package:chopdirect/screens/buyer/order_confirmation.dart';
import 'package:chopdirect/screens/buyer/order_summary_item.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Home'),
                    const Text('Mile 2 , Bamenda'),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Change Address'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Method',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const PaymentMethodCard(
              icon: Icons.phone_android,
              title: 'Mobile Money',
              subtitle: 'MTN MoMo, Orange Money',
              isSelected: true,
            ),
            const PaymentMethodCard(
              icon: Icons.credit_card,
              title: 'Card Payment',
              subtitle: 'Visa, Mastercard',
              isSelected: false,
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Summary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const OrderSummaryItem(label: 'Subtotal', value: 'XAF 2,600'),
            const OrderSummaryItem(label: 'Delivery', value: 'XAF 500'),
            const Divider(),
            const OrderSummaryItem(
              label: 'Total',
              value: 'XAF 3,100',
              isTotal: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderConfirmationScreen(),
                    ),
                  );
                },
                child: const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
