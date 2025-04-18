import 'package:chopdirect/screens/buyer/cart_item.dart';
import 'package:chopdirect/screens/buyer/checkout.dart';
import 'package:flutter/material.dart';

class BuyerCartScreen extends StatelessWidget {
  const BuyerCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const CartItem(
            name: 'Fresh Tomatoes',
            price: 'XAF 500',
            quantity: 2,
            image: 'assets/tomatoes.jpg',
          ),
          const CartItem(
            name: 'Organic Bananas',
            price: 'XAF 300',
            quantity: 1,
            image: 'assets/bananas.jpeg',
          ),
          const CartItem(
            name: ' Beans',
            price: 'XAF 700',
            quantity: 3,
            image: 'assets/beans.png',
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal'),
                        Text('XAF 2,600'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery'),
                        Text('XAF 500'),
                      ],
                    ),
                    const Divider(),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'XAF 3,100',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CheckoutScreen(),
                            ),
                          );
                        },
                        child: const Text('Proceed to Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
