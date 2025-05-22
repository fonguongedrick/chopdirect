import 'package:flutter/material.dart';

class CartItem extends StatelessWidget {
  final String name;
  final String price;
  final int quantity;
  final String image;
  final Function(int) onUpdateQuantity;

  const CartItem({
    super.key,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(price),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => onUpdateQuantity(-1),
                      ),
                      Text(quantity.toString()),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => onUpdateQuantity(1),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => onUpdateQuantity(-quantity),
                          child: Image.asset("assets/delete.png",))
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}