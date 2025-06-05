import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePin = true;
  bool _isFarmerLogin = false;
  String? _errorMessage;
  int _failedAttempts = 0;
  DateTime? _lastFailedAttempt;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if user is temporarily blocked
    if (_isTemporarilyBlocked()) {
      _showError('Too many attempts. Try again later.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isFarmerLogin) {
        await _loginFarmer();
      } else {
        await _loginBuyer();
      }
      // Reset failed attempts on successful login
      _failedAttempts = 0;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
      _failedAttempts++;
      _lastFailedAttempt = DateTime.now();
    } catch (e) {
      _showError('Login failed. Please try again.');
      _failedAttempts++;
      _lastFailedAttempt = DateTime.now();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _isTemporarilyBlocked() {
    if (_failedAttempts >= 5 && _lastFailedAttempt != null) {
      final cooldownEnd = _lastFailedAttempt!.add(const Duration(minutes: 5));
      if (DateTime.now().isBefore(cooldownEnd)) {
        return true;
      } else {
        // Reset if cooldown period has passed
        _failedAttempts = 0;
        return false;
      }
    }
    return false;
  }

  Future<void> _loginBuyer() async {
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!userCredential.user!.emailVerified) {
      await _showEmailVerificationDialog(userCredential.user!);
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Email not verified',
      );
    }

    await _checkUserStatus(userCredential.user!.uid);
  }

  Future<void> _loginFarmer() async {
    final phone = '+237${_phoneController.text.trim()}';
    final pin = _pinController.text.trim();

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users_chopdirect')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No account found with this phone number',
      );
    }

    final userDoc = querySnapshot.docs.first;
    final userData = userDoc.data();
    final storedPin = userData['pin']?.toString() ?? '';

    if (storedPin != pin) {
      throw FirebaseAuthException(
        code: 'wrong-pin',
        message: 'Invalid PIN entered',
      );
    }

    await _checkUserStatus(userDoc.id);
  }

  Future<void> _checkUserStatus(String uid) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users_chopdirect')
        .doc(uid)
        .get();

    if (!userDoc.exists) {
      throw Exception('User data not found in database');
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    final userStatus = userData['status']?.toString() ?? 'pending';

    if (userStatus == 'suspended') {
      throw FirebaseAuthException(
        code: 'account-suspended',
        message: 'Your account has been suspended. Please contact support.',
      );
    }

    if (userStatus == 'pending') {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/pending_approval');
      }
      return;
    }

    final userRole = userData['role']?.toString() ?? 'buyer';
    if (mounted) {
      switch (userRole) {
        case 'farmer':
          Navigator.pushReplacementNamed(context, '/farmer');
          break;
        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/buyer');
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showEmailVerificationDialog(User user) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Email Not Verified'),
          content: const Text(
            'Please verify your email address before logging in. '
                'Check your inbox for the verification email.',
          ),
          actions: [
            TextButton(
              child: const Text('Resend Email'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await user.sendEmailVerification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verification email resent!'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to resend email: $e'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _handleFirebaseError(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'invalid-email':
        errorMessage = 'Please enter a valid email address';
        break;
      case 'user-disabled':
        errorMessage = 'This account has been disabled. Contact support.';
        break;
      case 'user-not-found':
        errorMessage = _isFarmerLogin
            ? 'No account found with this phone number'
            : 'No account found with this email';
        break;
      case 'wrong-password':
      case 'wrong-pin':
        errorMessage = _isFarmerLogin
            ? 'Invalid PIN entered'
            : 'Invalid password entered';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many attempts. Try again later.';
        break;
      case 'network-request-failed':
        errorMessage = 'Network error. Check your connection.';
        break;
      case 'account-suspended':
        errorMessage = 'Your account has been suspended. Contact support.';
        break;
      case 'email-not-verified':
        errorMessage = 'Please verify your email first';
        break;
      default:
        errorMessage = e.message ?? 'Login failed. Please try again.';
    }

    _showError(errorMessage);
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent. Check your inbox.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError('Failed to send reset email: ${e.message}');
    } catch (_) {
      _showError('Failed to send reset email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[800]!, Colors.green[600]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/logo.svg',
                    height: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    _isFarmerLogin ? 'Farmer Login' : 'Buyer Login',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red[800],
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isFarmerLogin ? 'Are you a buyer?' : 'Are you a farmer?',
                        style: const TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isFarmerLogin = !_isFarmerLogin;
                            _errorMessage = null;
                          });
                        },
                        child: Text(
                          _isFarmerLogin ? 'Switch to Buyer' : 'Switch to Farmer',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          child: _isFarmerLogin
                              ? _buildFarmerLoginForm()
                              : _buildBuyerLoginForm(),
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

  Widget _buildBuyerLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email *',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
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
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password *',
              prefixIcon: const Icon(Icons.lock),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _resetPassword,
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              'LOGIN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('OR'),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'Continue with',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(FontAwesomeIcons.facebook,
                    color: Colors.blue, size: 32),
                onPressed: () {},
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(FontAwesomeIcons.google,
                    color: Colors.red, size: 32),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/registration',
                    arguments: _isFarmerLogin ? 'farmer' : 'buyer',
                  );
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number *',
              prefixIcon: Icon(Icons.phone),
              hintText: '6XXXXXXXX',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              if (value.length != 9) {
                return 'Enter a valid 9-digit number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _pinController,
            decoration: InputDecoration(
              labelText: '5-digit PIN *',
              prefixIcon: const Icon(Icons.lock),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscurePin
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () {
                  setState(() => _obscurePin = !_obscurePin);
                },
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(5),
            ],
            obscureText: _obscurePin,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your PIN';
              }
              if (value.length != 5) {
                return 'PIN must be 5 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              'LOGIN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/registration',
                    arguments: 'farmer',
                  );
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}