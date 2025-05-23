import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _farmNameController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;
  String? _verificationId;
  final _otpController = TextEditingController();
  String? _selectedProductType;
  String? _location;
  String? _fcmToken;

  // Simplified product types
  final List<String> _productTypes = [
    'Vegetables', 'Fruits', 'Grains', 'Livestock'
  ];

  @override
  void initState() {
    super.initState();
    _getFcmToken();
    _requestLocation();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _farmNameController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _getFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      setState(() {
        _fcmToken = token;
      });
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }



  Future<void> _requestLocation() async {
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );

        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ); // ✅ Use placemarkFromCoordinates from geocoding

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _location = '${place.locality}, ${place.administrativeArea}';
          });
        }
      } else {
        // Handle permission denied
        print("Location permission not granted.");
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }


  Future<void> _verifyPhoneNumber() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String formattedPhone = '+237${_phoneController.text.trim()}';

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (credential) async {
          await _signInWithPhoneNumber(credential);
        },
        verificationFailed: (e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')),
          );
        },
        codeSent: (verificationId, _) {
          setState(() {
            _isLoading = false;
            _isOtpSent = true;
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      await _signInWithPhoneNumber(credential);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _signInWithPhoneNumber(PhoneAuthCredential credential) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _createFarmerProfile(userCredential.user!.uid);
        Navigator.pushReplacementNamed(context, '/pending_approval');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  Future<void> _createFarmerProfile(String uid) async {
    // Create farmer profile
    await FirebaseFirestore.instance.collection('users_chopdirect').doc(uid).set({
      'userId': uid,
      'phone': _phoneController.text.trim(),
      'role': 'farmer',
      'name': _nameController.text.trim(),
      'farmName': _farmNameController.text.trim(),
      'location': _location ?? 'Unknown location',
      'productType': _selectedProductType,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'fcmToken': _fcmToken ?? '', // Auto-generated token
      'coordinates': _location != null ? GeoPoint(
        (await Geolocator.getLastKnownPosition())?.latitude ?? 0,
        (await Geolocator.getLastKnownPosition())?.longitude ?? 0,
      ) : null,
    });

    // Create farmer application
    await FirebaseFirestore.instance.collection('farmer_applications').add({
      'userId': uid,
      'farmName': _farmNameController.text.trim(),
      'location': _location ?? 'Unknown location',
      'productType': _selectedProductType,
      'status': 'Pending',
      'submittedAt': FieldValue.serverTimestamp(),
      'reviewedAt': null,
      'reviewedBy': null,
      'coordinates': _location != null ? GeoPoint(
        (await Geolocator.getLastKnownPosition())?.latitude ?? 0,
        (await Geolocator.getLastKnownPosition())?.longitude ?? 0,
      ) : null,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[800]!, Colors.green[600]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Logo and Title
                  SvgPicture.asset('assets/logo.svg', height: 100, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Farmer Registration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Registration Form Card
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Phone Number Field
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number *',
                                    prefixIcon: Icon(Icons.phone),
                                    hintText: '6XXXXXXXX',
                                  ),
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter phone number';
                                    }
                                    if (value.length < 9) {
                                      return 'Enter a valid phone number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // OTP Field (only shown after sending)
                                if (_isOtpSent) ...[
                                  TextFormField(
                                    controller: _otpController,
                                    decoration: const InputDecoration(
                                      labelText: 'OTP Code *',
                                      prefixIcon: Icon(Icons.lock_clock),
                                      hintText: 'Enter 6-digit code',
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(6),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Name Field
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Your Name *',
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Please enter your name'
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                // Farm Name Field
                                TextFormField(
                                  controller: _farmNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Farm Name *',
                                    prefixIcon: Icon(Icons.agriculture),
                                  ),
                                  validator: (value) => value == null || value.isEmpty
                                      ? 'Please enter farm name'
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                // Location Display (auto-detected)
                                if (_location != null) ...[
                                  const Text(
                                    'Detected Location:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    _location!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _requestLocation,
                                    child: const Text('Refresh Location'),
                                  ),
                                ] else ...[
                                  const Text(
                                    'Detecting your location...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _requestLocation,
                                    child: const Text('Enable Location'),
                                  ),
                                ],
                                const SizedBox(height: 16),

                                // Product Type Dropdown
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Main Product *',
                                    prefixIcon: Icon(Icons.shopping_basket),
                                  ),
                                  value: _selectedProductType,
                                  items: _productTypes.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedProductType = value);
                                  },
                                  validator: (value) => value == null
                                      ? 'Please select your main product'
                                      : null,
                                ),
                                const SizedBox(height: 24),

                                // Verification Button
                                ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _isOtpSent ? _verifyOtp : _verifyPhoneNumber,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Text(
                                    _isOtpSent ? 'VERIFY OTP & REGISTER' : 'SEND OTP',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}