import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPlanScreen extends StatefulWidget {
  final String farmerId;
  final String farmName;

  const PaymentPlanScreen({
    super.key,
    required this.farmerId,
    required this.farmName,
  });

  @override
  State<PaymentPlanScreen> createState() => _PaymentPlanScreenState();
}

class _PaymentPlanScreenState extends State<PaymentPlanScreen> {
  String? _selectedPlan;
  bool _isLoading = false;

  final Map<String, Map<String, dynamic>> _plans = {
    'commission': {
      'name': 'Commission',
      'description': '5% commission on each sale',
      'rate': 0.05,
      'price': 0,
    },
    '1_month': {
      'name': '1 Month Subscription',
      'description': '20,000 FCFA per month',
      'rate': 0,
      'price': 20000,
    },
    '3_months': {
      'name': '3 Months Subscription',
      'description': '55,000 FCFA (Save 5,000 FCFA)',
      'rate': 0,
      'price': 55000,
    },
    '6_months': {
      'name': '6 Months Subscription',
      'description': '105,000 FCFA (Save 15,000 FCFA)',
      'rate': 0,
      'price': 105000,
    },
    '1_year': {
      'name': '1 Year Subscription',
      'description': '200,000 FCFA (Save 40,000 FCFA)',
      'rate': 0,
      'price': 200000,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Payment Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${widget.farmName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please choose how you want to pay for our services:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Available Plans:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: _plans.entries.map((entry) {
                  final planKey = entry.key;
                  final plan = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    color: _selectedPlan == planKey
                        ? Colors.green[50]
                        : Colors.white,
                    child: RadioListTile<String>(
                      title: Text(
                        plan['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(plan['description']),
                      value: planKey,
                      groupValue: _selectedPlan,
                      onChanged: (value) {
                        setState(() => _selectedPlan = value);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedPlan == null || _isLoading
                    ? null
                    : _submitPaymentPlan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.green[800],
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPaymentPlan() async {
    if (_selectedPlan == null) return;

    setState(() => _isLoading = true);

    try {
      final selectedPlan = _plans[_selectedPlan]!;

      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(widget.farmerId)
          .update({
        'paymentPlan': {
          'type': _selectedPlan == 'commission' ? 'commission' : 'subscription',
          'rate': selectedPlan['rate'],
          'price': selectedPlan['price'],
          'selectedAt': FieldValue.serverTimestamp(),
          'status': 'active',
        },
        'status': 'approved', // Approve farmer after selecting plan
      });

      // Navigate to farmer home after successful selection
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/farmer',
            (route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving payment plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}