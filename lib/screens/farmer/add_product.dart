import 'package:flutter/material.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Product image
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                    Text('Add Product Image'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product details form
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Product Name',
                hintText: 'e.g. Fresh Tomatoes',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your product...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      hintText: 'e.g. 500',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField(
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
              decoration: const InputDecoration(
                labelText: 'Available Stock',
                hintText: 'e.g. 20',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
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
                child: const Text('Add Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
