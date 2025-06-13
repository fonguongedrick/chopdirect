import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mesomb/mesomb.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:chopdirect/models/cart_manager.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  final CartManager cartManager;
  const DeliveryDetailsScreen({Key? key, required this.cartManager}) : super(key: key);

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String _deliveryOption = 'home';
  String _selectedTimeSlot = 'morning';
  bool _isLoading = false;

  // Replace with your actual MeSomb credentials
  final String _applicationKey = '795ee41f78b16c24023a17ed94a90bf577b569c4';
  final String _accessKey = '98af2657-3378-40e1-adfb-5b1017ffb25d';
  final String _secretKey = 'bb817a20-d65a-4566-9d75-46381ff8c19f'; 

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.cartManager.subtotal;
    final deliveryFee = _deliveryOption == 'home' ? 500 : 0;
    final total = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Delivery Method'),
              _buildDeliveryOptionCard('Home Delivery', 'home', Icons.home),
              _buildDeliveryOptionCard('Takeaway', 'takeaway', Icons.shopping_bag),
              const SizedBox(height: 24),
              _buildSectionHeader('Delivery Address'),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Enter your full address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter your address'
                    : null,
                maxLines: 2,
              ),
              if (_deliveryOption == 'home') ...[
                const SizedBox(height: 24),
                _buildSectionHeader('Delivery Time'),
                ..._buildTimeSlots(),
              ],
              const SizedBox(height: 24),
              _buildSectionHeader('Special Instructions (Optional)'),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Any special delivery instructions',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Order Summary'),
              _buildOrderSummary(subtotal.toDouble(), deliveryFee.toDouble(), total.toDouble()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _proceedToPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Proceed to Payment', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDeliveryOptionCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _deliveryOption == value ? const Color(0xFF4CAF50) : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4CAF50)),
        title: Text(title),
        trailing: Radio<String>(
          value: value,
          groupValue: _deliveryOption,
          activeColor: const Color(0xFF4CAF50),
          onChanged: (String? newVal) {
            setState(() {
              _deliveryOption = newVal!;
            });
          },
        ),
        onTap: () {
          setState(() {
            _deliveryOption = value;
          });
        },
      ),
    );
  }

  List<Widget> _buildTimeSlots() {
    return [
      _buildTimeSlotOption('Morning (8AM - 12PM)', 'morning'),
      _buildTimeSlotOption('Afternoon (12PM - 5PM)', 'afternoon'),
      _buildTimeSlotOption('Evening (5PM - 8PM)', 'evening'),
    ];
  }

  Widget _buildTimeSlotOption(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _selectedTimeSlot == value ? const Color(0xFF4CAF50) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ListTile(
        title: Text(title),
        trailing: Radio<String>(
          value: value,
          groupValue: _selectedTimeSlot,
          activeColor: const Color(0xFF4CAF50),
          onChanged: (String? newVal) {
            setState(() {
              _selectedTimeSlot = newVal!;
            });
          },
        ),
        onTap: () {
          setState(() {
            _selectedTimeSlot = value;
          });
        },
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal, double deliveryFee, double total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', subtotal),
            _buildSummaryRow('Delivery Fee', deliveryFee),
            const Divider(),
            _buildSummaryRow('Total', total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 16 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text('${amount.toInt()} XAF',
              style: TextStyle(
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? const Color(0xFF4CAF50) : null,
              )),
        ],
      ),
    );
  }

  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final paymentSuccess = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          amount: widget.cartManager.subtotal + (_deliveryOption == 'home' ? 500 : 0),
          applicationKey: _applicationKey,
          accessKey: _accessKey,
          secretKey: _secretKey,
        ),
      ),
    );

    if (paymentSuccess == true) {
      await _saveOrderToFirebase();
      _showSuccessDialog();
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveOrderToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final orderData = {
      'userId': user.uid,
      'items': widget.cartManager.items
          .map((item) => {
                'productId': item.id,
                'name': item.name,
                'quantity': item.quantity,
                'price': item.price,
                'farmerId': item.farmerId,
              })
          .toList(),
      'deliveryOption': _deliveryOption,
      'address': _deliveryOption == 'home' ? _addressController.text : null,
      'deliveryTime': _deliveryOption == 'home' ? _selectedTimeSlot : null,
      'specialInstructions': _notesController.text,
      'subtotal': widget.cartManager.subtotal,
      'deliveryFee': _deliveryOption == 'home' ? 500 : 0,
      'total': widget.cartManager.subtotal + (_deliveryOption == 'home' ? 500 : 0),
      'status': 'paid',
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Save the order to Firestore.
    await FirebaseFirestore.instance.collection('orders').add(orderData);

    // Do not call any client-side notification function.
    // The Cloud Function will trigger on new order creation.

    // Clear the cart.
    widget.cartManager.clearCart();
  }

  void _showSuccessDialog() {
    final pointsEarned = ((widget.cartManager.subtotal + (_deliveryOption == 'home' ? 500 : 0)) / 1000).floor();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Order Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text('Your order has been placed successfully.'),
            const SizedBox(height: 16),
            Text('You earned $pointsEarned loyalty points!',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/buyer');
            },
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String applicationKey;
  final String accessKey;
  final String secretKey;

  const PaymentScreen({
    Key? key,
    required this.amount,
    required this.applicationKey,
    required this.accessKey,
    required this.secretKey,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    // Ensure the device subscribes to the "order_updates" topic so that it can receive notifications.
    FirebaseMessaging.instance.subscribeToTopic("order_updates");
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('${widget.amount.toInt()} XAF',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile Money Number',
                hintText: 'Enter your phone number',
                prefixIcon: Icon(Icons.phone),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _processPayment,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Pay with Mobile Money'),
            ),
            if (_statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _statusMessage,
                  style: TextStyle(color: _statusMessage.contains('success') ? Colors.green : Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_phoneController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final payment = PaymentOperation(
        widget.applicationKey,
        widget.accessKey,
        widget.secretKey,
      );

      final response = await payment.makeCollect(
        amount:1, //widget.amount, // Use the actual payment amount.
        service: 'MTN',
        payer: _phoneController.text,
        country: 'CM',
        currency: 'XAF',
        nonce: RandomGenerator.nonce(),
      );

      if (response.isOperationSuccess()) {
        _statusMessage = 'Payment successful!';
        Navigator.pop(context, true); // Return success result to the previous screen.
      } else {
        _statusMessage = 'Payment failed: ${response.message}';
      }
    } catch (e) {
      _statusMessage = 'Error: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
