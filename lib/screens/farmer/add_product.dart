import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  final DocumentSnapshot? productDoc; // For editing existing product
  final Product? product; // Alternative product model

  const AddProductScreen({super.key, this.productDoc, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  String _selectedCategory = 'vegetables';
  String _selectedUnit = 'kg';
  File? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = false;
  bool _isImageChanged = false;

  final List<String> _categories = [
    'vegetables',
    'fruits',
    'grains',
    'livestock',
    'dairy',
    'herbs'
  ];

  final List<String> _units = ['kg', 'g', 'bunch', 'piece', 'bag', 'liter'];

  @override
  void initState() {
    super.initState();

    // Initialize with product data (either from document or model)
    final existingData = widget.productDoc?.data() as Map<String, dynamic>? ??
        widget.product?.toMap() ?? {};

    _nameController = TextEditingController(text: existingData['name'] ?? '');
    _descriptionController = TextEditingController(
        text: existingData['description'] ?? '');
    _priceController = TextEditingController(
        text: existingData['price']?.toString() ?? '');
    _stockController = TextEditingController(
        text: existingData['stock']?.toString() ?? '');
    _selectedCategory = existingData['category'] ?? 'vegetables';
    _selectedUnit = existingData['unit'] ?? 'kg';
    _existingImageUrl = existingData['imageUrl'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isImageChanged = true;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _existingImageUrl;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Only require image for new products
    if (isNewProduct && _imageFile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _uploadImage();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'unit': _selectedUnit,
        'category': _selectedCategory,
        'stock': int.parse(_stockController.text.trim()),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add image URL if we have one
      if (imageUrl != null) {
        productData['imageUrl'] = imageUrl;
      }

      if (isNewProduct) {
        // Add new product
        productData['farmerId'] = user.uid;
        productData['rating'] = 0;
        productData['reviewCount'] = 0;
        productData['status'] = 'active';
        productData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('products').add(productData);
      } else {
        // Update existing product
        final docRef = widget.productDoc?.reference ??
            FirebaseFirestore.instance.collection('products').doc(widget.product?.id);
        await docRef.update(productData);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true); // Return success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNewProduct
              ? 'Error adding product: $e'
              : 'Error updating product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  bool get isNewProduct => widget.productDoc == null && widget.product == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isNewProduct ? 'Add New Product' : 'Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : _existingImageUrl != null
                      ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 50),
                      SizedBox(height: 8),
                      Text('Tap to add product image'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Price and Stock
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (XAF) *',
                        border: OutlineInputBorder(),
                        prefixText: 'XAF ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Price must be positive';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stock';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter valid number';
                        }
                        if (int.parse(value) < 0) {
                          return 'Stock cannot be negative';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category[0].toUpperCase() + category.substring(1),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Unit Dropdown
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Unit *',
                  border: OutlineInputBorder(),
                ),
                items: _units.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  isNewProduct ? 'Add Product' : 'Update Product',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

