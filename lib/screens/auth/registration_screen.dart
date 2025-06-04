import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _otpController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _pinVisible = false;
  bool _confirmPinVisible = false;
  String? _verificationId;
  String? _selectedProductType;
  String? _location;
  String? _fcmToken;
  Position? _lastPosition;
  late String _userType;

  // Track current registration step for farmers
  int _currentStep = 0; // 0 = phone verification, 1 = pin setup, 2 = profile info

  final List<String> _productTypes = ['Vegetables', 'Fruits', 'Grains', 'Livestock'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    _userType = (args is String && args == 'farmer') ? 'farmer' : 'buyer';
  }

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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _farmNameController.dispose();
    _otpController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
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
        setState(() => _isLoading = true);
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium
        ).timeout(const Duration(seconds: 10));

        final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude
        );

        setState(() {
          _lastPosition = position;
          _location = placemarks.isNotEmpty
              ? '${placemarks.first.locality}, ${placemarks.first.administrativeArea}'
              : 'Lat: ${position.latitude.toStringAsFixed(4)}, Long: ${position.longitude.toStringAsFixed(4)}';
          _isLoading = false;
        });
      } else {
        _showSnackBar('Location permission is required for registration');
      }
    } on TimeoutException {
      setState(() => _isLoading = false);
      _showSnackBar('Location detection timed out');
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error getting location: ${e.toString()}');
    }
  }

  void _showOtpInputDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter OTP'),
        content: TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '6-digit OTP',
            hintText: 'Enter code from SMS',
          ),
          maxLength: 6,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _verifyOtp();
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyPhoneNumber() async {
    setState(() => _isLoading = true);

    try {
      // Force SMS-only verification (disable web reCAPTCHA)
      await FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: false,
        forceRecaptchaFlow: false, // This is the key change
      );

      final formattedPhone = '+237${_phoneController.text.trim()}';

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (e) {
          setState(() => _isLoading = false);
          _showSnackBar('Verification failed: ${e.message}');
        },
        codeSent: (verificationId, _) {
          setState(() {
            _isLoading = false;
            _isOtpSent = true;
            _verificationId = verificationId;
          });
          // Show OTP input UI instead of redirecting
          _showOtpInputDialog(); // Add this method
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      _showSnackBar('Please enter a valid 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      await _signInWithCredential(credential);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('OTP verification failed: $e');
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        // For farmers, move to PIN setup after OTP verification
        if (_userType == 'farmer') {
          setState(() {
            _isLoading = false;
            _currentStep = 1; // Move to PIN setup step
          });
        } else {
          await _createUserProfile(user.uid);
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Registration failed: $e');
    }
  }

  Future<void> _setupPin() async {
    if (_pinController.text.isEmpty || _pinController.text.length != 4) {
      _showSnackBar('Please enter a 4-digit PIN');
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      _showSnackBar('PINs do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Store the PIN securely (in production, use a more secure method like Firebase Functions)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_pin_${_phoneController.text}', _pinController.text);

      // Move to profile information step
      setState(() {
        _isLoading = false;
        _currentStep = 2;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error setting up PIN: $e');
    }
  }

  Future<void> _registerWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await userCredential.user!.sendEmailVerification();
      await _createUserProfile(userCredential.user!.uid);

      _showSnackBar('Registration successful!');
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed. Please try again.';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }
      _showSnackBar(errorMessage);
    } catch (e) {
      _showSnackBar('An unexpected error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _completeFarmerRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _createUserProfile(user.uid);
        _showSnackBar('Registration successful!');
        Navigator.pushReplacementNamed(context, '/pending_approval');
      } else {
        _showSnackBar('User not authenticated. Please try again.');
      }
    } catch (e) {
      _showSnackBar('An unexpected error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createUserProfile(String uid) async {
    final geoPoint = _lastPosition != null
        ? GeoPoint(_lastPosition!.latitude, _lastPosition!.longitude)
        : null;

    final batch = FirebaseFirestore.instance.batch();

    // Create user document
    final userRef = FirebaseFirestore.instance.collection('users_chopdirect').doc(uid);
    batch.set(userRef, {
      'userId': uid,
      'phone': _userType == 'farmer' ? _phoneController.text.trim() : null,
      'email': _userType == 'buyer' ? _emailController.text.trim() : null,
      'role': _userType,
      'name': _nameController.text.trim(),
      'fcmToken': _fcmToken ?? '',
      'location': _location ?? 'Unknown location',
      'coordinates': geoPoint,
      'status': _userType == 'farmer' ? 'Pending' : 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      if (_userType == 'farmer') ...{
        'farmName': _farmNameController.text.trim(),
        'productType': _selectedProductType,
        'hasPinAuth': true, // Mark that this user uses PIN authentication
      }
    });

    // For farmers, create application record
    if (_userType == 'farmer') {
      final applicationRef = FirebaseFirestore.instance.collection('farmer_applications').doc();
      batch.set(applicationRef, {
        'applicationId': applicationRef.id,
        'userId': uid,
        'farmName': _farmNameController.text.trim(),
        'location': _location ?? 'Unknown location',
        'productType': _selectedProductType,
        'status': 'Pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'reviewedAt': null,
        'reviewedBy': null,
        'coordinates': geoPoint,
      });
    }

    await batch.commit();
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Widget _buildFarmerPhoneVerification() {
    return Column(
      children: [
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            prefixIcon: Icon(Icons.phone),
            hintText: '6XXXXXX (9 digits without +237)',
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9), // Ensures exactly 9 digits
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            }
            if (value.length != 9) {
              return 'Enter 9-digit number (without +237)';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

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
          const SizedBox(height: 8),
          TextButton(
            onPressed: _verifyPhoneNumber,
            child: const Text("Resend OTP"),
          ),
        ],

        ElevatedButton(
          onPressed: _isLoading
              ? null
              : _isOtpSent
              ? _verifyOtp
              : _verifyPhoneNumber,
          child: _isLoading
              ? const CircularProgressIndicator()
              : Text(_isOtpSent ? 'VERIFY OTP' : 'SEND OTP'),
        ),
      ],
    );
  }

  Widget _buildFarmerPinSetup() {
    return Column(
      children: [
        const Text(
          'Set up a 4-digit PIN for quick login',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _pinController,
          decoration: InputDecoration(
            labelText: 'PIN *',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_pinVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() => _pinVisible = !_pinVisible);
              },
            ),
          ),
          obscureText: !_pinVisible,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter PIN';
            }
            if (value.length != 4) {
              return 'PIN must be 4 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPinController,
          decoration: InputDecoration(
            labelText: 'Confirm PIN *',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_confirmPinVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() => _confirmPinVisible = !_confirmPinVisible);
              },
            ),
          ),
          obscureText: !_confirmPinVisible,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm PIN';
            }
            if (value != _pinController.text) {
              return 'PINs do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _setupPin,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('SETUP PIN & CONTINUE'),
        ),
      ],
    );
  }

  Widget _buildFarmerProfileInfo() {
    return Column(
      children: [
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
          TextButton(
            onPressed: _requestLocation,
            child: const Text('Enable Location'),
          ),
        ],
        const SizedBox(height: 16),

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

        ElevatedButton(
          onPressed: _isLoading ? null : _completeFarmerRegistration,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('COMPLETE REGISTRATION'),
        ),
      ],
    );
  }

  Widget _buildBuyerRegistration() {
    return Column(
      children: [
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

        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email *',
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password *',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_passwordVisible
                  ? Icons.visibility_off
                  : Icons.visibility),
              onPressed: () {
                setState(() => _passwordVisible = !_passwordVisible);
              },
            ),
          ),
          obscureText: !_passwordVisible,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter password';
            }
            if (value.length < 6) {
              return 'Minimum 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirm Password *',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_confirmPasswordVisible
                  ? Icons.visibility_off
                  : Icons.visibility),
              onPressed: () {
                setState(() => _confirmPasswordVisible = !_confirmPasswordVisible);
              },
            ),
          ),
          obscureText: !_confirmPasswordVisible,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _isLoading ? null : _registerWithEmail,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('REGISTER'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFarmer = _userType == 'farmer';
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade800, Colors.green.shade600],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SvgPicture.asset('assets/logo.svg', height: 100, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    isFarmer ? 'Farmer Registration' : 'Buyer Registration',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (isFarmer && _currentStep > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Step ${_currentStep + 1} of 3',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_currentStep + 1) / 3,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      color: Colors.white,
                    ),
                  ],

                  const SizedBox(height: 16),

                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (isFarmer) ...[
                                  if (_currentStep == 0) _buildFarmerPhoneVerification(),
                                  if (_currentStep == 1) _buildFarmerPinSetup(),
                                  if (_currentStep == 2) _buildFarmerProfileInfo(),
                                ] else ...[
                                  _buildBuyerRegistration(),
                                ],

                                const SizedBox(height: 16),

                                // Login Link
                                Center(
                                  child: TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () => Navigator.pushNamed(context, '/login'),
                                    child: const Text('Already have an account? Login'),
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
          ),
        ],
      ),
    );
  }
}