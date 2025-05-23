// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _identifierController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//
//   Future<void> _login() async {
//     final identifier = _identifierController.text.trim();
//     final password = _passwordController.text.trim();
//
//     if (identifier.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill all fields")),
//       );
//       return;
//     }
//
//     try {
//       setState(() => _isLoading = true);
//
//       // Check if it's a phone number (digits only), else treat it as email
//       String email;
//       if (RegExp(r'^\d+$').hasMatch(identifier)) {
//         email = '$identifier@chopdirect.com'; // internal email mapping
//       } else {
//         email = identifier;
//       }
//
//       final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       final user = userCredential.user;
//
//       if (user == null) {
//         throw FirebaseAuthException(code: 'user-not-found', message: 'User not found');
//       }
//
//       // Fetch user type from Firestore
//       final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//       if (!doc.exists) {
//         throw Exception('User data not found');
//       }
//
//       final userType = doc.data()?['userType'];
//       if (userType == 'buyer') {
//         Navigator.pushReplacementNamed(context, '/buyer');
//       } else if (userType == 'farmer') {
//         Navigator.pushReplacementNamed(context, '/farmer');
//       } else {
//         throw Exception('User type not valid');
//       }
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.message ?? 'Login failed')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.green[800]!, Colors.green[600]!],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 children: [
//                   SvgPicture.asset(
//                     'assets/logo.svg',
//                     height: 100,
//                     color: Colors.white,
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Login to ChopDirect',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   Expanded(
//                     child: Card(
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                       child: Padding(
//                         padding: const EdgeInsets.all(24.0),
//                         child: Form(
//                           key: _formKey,
//                           child: SingleChildScrollView(
//                             child: Column(
//                               children: [
//                                 TextFormField(
//                                   controller: _identifierController,
//                                   decoration: const InputDecoration(
//                                     labelText: 'Phone Number or Email',
//                                     prefixIcon: Icon(Icons.person),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 TextFormField(
//                                   controller: _passwordController,
//                                   obscureText: _obscurePassword,
//                                   decoration: InputDecoration(
//                                     labelText: 'Password',
//                                     prefixIcon: const Icon(Icons.lock),
//                                     suffixIcon: IconButton(
//                                       icon: Icon(
//                                         _obscurePassword
//                                             ? Icons.visibility_off
//                                             : Icons.visibility,
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           _obscurePassword = !_obscurePassword;
//                                         });
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Align(
//                                   alignment: Alignment.centerRight,
//                                   child: TextButton(
//                                     onPressed: () {},
//                                     child: const Text('Forgot Password?'),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 _isLoading
//                                     ? const Center(child: CircularProgressIndicator())
//                                     : SizedBox(
//                                   width: double.infinity,
//                                   child: ElevatedButton(
//                                     onPressed: _login,
//                                     child: const Text('Login'),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 24),
//                                 const Text('............Or login with...........'),
//                                 const SizedBox(height: 16),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     IconButton(
//                                       icon: const Icon(FontAwesomeIcons.google, color: Colors.green),
//                                       onPressed: () {},
//                                     ),
//                                     IconButton(
//                                       icon: const Icon(FontAwesomeIcons.facebook, color: Colors.blue),
//                                       onPressed: () {},
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 24),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Text("Don't have an account?"),
//                                     TextButton(
//                                       onPressed: () {
//                                         Navigator.pushNamed(context, '/onboarding');
//                                       },
//                                       child: const Text('Sign Up'),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isEmailValid = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Authenticate with Firebase
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Check if email is verified
      if (!userCredential.user!.emailVerified) {
        await _showEmailVerificationDialog(userCredential.user!);
        return;
      }

      // 3. Get user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users_chopdirect')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found in database');
      }

      final userData = userDoc.data();
      final userStatus = userData?['status'] ?? 'pending';

      // 4. Check account status
      if (userStatus == 'suspended') {
        throw FirebaseAuthException(
          code: 'account-suspended',
          message: 'Your account has been suspended. Please contact support.',
        );
      }

      if (userStatus == 'pending') {
        Navigator.pushReplacementNamed(context, '/pending_approval');
        return;
      }

      // 5. Navigate based on user role
      final userRole = userData?['role'] ?? 'buyer';
      switch (userRole) {
        case 'farmer':
          Navigator.pushReplacementNamed(context, '/farmer_dashboard');
          break;
        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/buyer_dashboard');
      }

    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showEmailVerificationDialog(User user) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email Not Verified'),
          content: const Text(
              'Please verify your email address before logging in. '
                  'Check your inbox for the verification email.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Resend Email'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await user.sendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Verification email resent!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to resend email: $e')),
                  );
                }
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
      case 'wrong-password':
        errorMessage = 'Invalid email or password';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many attempts. Try again later.';
        break;
      case 'network-request-failed':
        errorMessage = 'Network error. Check your connection.';
        break;
      default:
        errorMessage = e.message ?? 'Login failed. Please try again.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_isEmailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
          duration: Duration(seconds: 5),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send reset email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  // Logo
                  SvgPicture.asset(
                    'assets/logo.svg',
                    height: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),

                  // Title
                  const Text(
                    'Login to ChopDirect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login Form
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email *',
                                    prefixIcon: const Icon(Icons.email),
                                    errorText: _isEmailValid ? null : 'Enter valid email',
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                      setState(() => _isEmailValid = false);
                                      return 'Enter a valid email';
                                    }
                                    setState(() => _isEmailValid = true);
                                    return null;
                                  },
                                  onChanged: (value) {
                                    if (_isEmailValid && value.isNotEmpty) {
                                      setState(() {
                                        _isEmailValid = RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                            .hasMatch(value);
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password *',
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
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

                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _resetPassword,
                                    child: const Text('Forgot Password?'),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Login Button
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: theme.primaryColor,
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
                                      : Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Divider
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

                                // Social Login Buttons
                                const Text(
                                  'Continue with',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(FontAwesomeIcons.facebook, color: Colors.blue),
                                      onPressed: () {},
                                    ),
                                    const SizedBox(width: 24),
                                    IconButton(
                                      icon: const Icon(FontAwesomeIcons.facebook, color: Colors.blue),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Sign Up Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Don't have an account?"),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/onboarding');
                                      },
                                      child: const Text('Sign Up'),
                                    ),
                                  ],
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