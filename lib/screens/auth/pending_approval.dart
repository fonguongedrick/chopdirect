import 'package:chopdirect/screens/auth/payment_plan.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // Add this import for StreamSubscription

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkApprovalStatus();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  void _checkApprovalStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _userSubscription = FirebaseFirestore.instance
        .collection('users_chopdirect')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final status = snapshot['status'] as String?;
        final role = snapshot['role'] as String?;
        final farmName = snapshot['farmName'] as String?;
        final hasPaymentPlan = snapshot['paymentPlan'] != null;

        if (status == 'approved' && role == 'farmer') {
          if (!hasPaymentPlan) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentPlanScreen(
                  farmerId: user.uid,
                  farmName: farmName ?? 'Your Farm',
                ),
              ),
            );
          } else {
            Navigator.pushReplacementNamed(context, '/farmer');
          }
        }
      }
    }, onError: (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    });
  }
// ... rest of your PendingApprovalScreen code

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Pending Approval'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                'Your account is pending approval',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Our team is reviewing your registration. '
                    'You\'ll receive a notification once your account is approved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _signOut,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                )
                    : const Text('Sign Out'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Implement contact support functionality
                  // launchUrl(Uri.parse('mailto:support@chopdirect.com'));
                },
                child: const Text('Contact Support'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}