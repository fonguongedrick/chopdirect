import 'package:flutter/material.dart';

class EditProductScreen extends StatelessWidget {
  const EditProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/tomatoes.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Product details form
            TextFormField(
              initialValue: 'Fresh Tomatoes',
              decoration: const InputDecoration(
                labelText: 'Product Name',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: 'Freshly harvested organic tomatoes from our farm',
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '500',
                    decoration: const InputDecoration(
                      labelText: 'Price',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
                    value: 'kg',
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'kg',
                        child: Text('per kg'),
                      ),
                      DropdownMenuItem(
                        value: 'bunch',
                        child: Text('per bunch'),
                      ),
                      DropdownMenuItem(
                        value: 'piece',
                        child: Text('per piece'),
                      ),
                      DropdownMenuItem(
                        value: 'bag',
                        child: Text('per bag'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: '24',
              decoration: const InputDecoration(
                labelText: 'Available Stock',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: 'vegetables',
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'vegetables',
                  child: Text('Vegetables'),
                ),
                DropdownMenuItem(
                  value: 'fruits',
                  child: Text('Fruits'),
                ),
                DropdownMenuItem(
                  value: 'grains',
                  child: Text('Grains'),
                ),
                DropdownMenuItem(
                  value: 'drinks',
                  child: Text('Drinks'),
                ),
                DropdownMenuItem(
                  value: 'others',
                  child: Text('Others'),
                ),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Update Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
