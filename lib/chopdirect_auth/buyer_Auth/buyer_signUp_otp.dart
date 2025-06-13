import 'package:chopdirect/chopdirect_auth/buyer_Auth/Buyer_profile.dart';
import 'package:chopdirect/chopdirect_auth/buyer_Auth/buyer_login_otp.dart';
import 'package:chopdirect/constants/constanst.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BuyerSignUp extends StatefulWidget {
  const BuyerSignUp({super.key});

  @override
  State<BuyerSignUp> createState() => _BuyerSignUpState();
}

class _BuyerSignUpState extends State<BuyerSignUp> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _saveUserData(userCredential.user!);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BuyerProfileSetUp()),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) _showErrorSnackbar(context, _mapErrorCode(e.code));
    } catch (e) {
      if (mounted) _showErrorSnackbar(context, 'Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserData(User user) async {
    await FirebaseFirestore.instance
        .collection('users_chopdirect')
        .doc(user.uid)
        .set({
      'userId': user.uid,
      'email': user.email,
      'timestamp': FieldValue.serverTimestamp(),
      'role': 'Buyer',
      'profileComplete': false,
    });
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.pureWhite),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _mapErrorCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please log in instead.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
              stops: [0.2, 0.8],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icon with animation
                    const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 80,
                      color: AppColors.pureWhite,
                    )
                        .animate()
                        .scale(duration: 500.ms, curve: Curves.elasticOut)
                        .shimmer(delay: 600.ms, duration: 1000.ms),
                    const SizedBox(height: 20),

                    // Title with animation
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'REGISTER TO ',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.pureWhite,
                              letterSpacing: 1.5,
                            ),
                          ),
                          TextSpan(
                            text: 'ChopDirect',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.accentYellow,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 40),

                    // Email Field with animation
                    _buildEmailField().animate().slideX(
                          duration: 500.ms,
                          begin: -0.5,
                        ),
                    const SizedBox(height: 20),

                    // Password Field with animation
                    _buildPasswordField().animate().slideX(
                          duration: 500.ms,
                          begin: 0.5,
                          delay: 100.ms,
                        ),
                    const SizedBox(height: 20),

                    // Confirm Password Field with animation
                    _buildConfirmPasswordField().animate().slideX(
                          duration: 500.ms,
                          begin: -0.5,
                          delay: 200.ms,
                        ),
                    const SizedBox(height: 30),

                    // Sign Up Button with animation
                    _buildSignUpButton().animate().scale(duration: 500.ms),
                    const SizedBox(height: 30),

                    // Login Prompt with animation
                    _buildLoginPrompt().animate().fadeIn(duration: 700.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: AppColors.pureWhite),
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.isEmpty) {
          return 'Please enter your email';
        }
        if (!AppRegex.email.hasMatch(trimmed)) {
          return 'Please enter a valid email';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'EMAIL',
        labelStyle: TextStyle(color: AppColors.pureWhite.withOpacity(0.8)),
        prefixIcon: Icon(Icons.email_outlined, color: AppColors.pureWhite.withOpacity(0.7)),
        filled: true,
        fillColor: AppColors.pureWhite.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentYellow, width: 2),
        ),
        errorStyle: const TextStyle(color: AppColors.errorRed),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: const [AutofillHints.newPassword],
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: AppColors.pureWhite),
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.isEmpty) {
          return 'Please enter a password';
        }
        if (trimmed.length < 6) {
          return 'Password must be at least 6 characters';
        }
        // Optionally, add more password strength checks here
        return null;
      },
      decoration: InputDecoration(
        labelText: 'PASSWORD',
        labelStyle: TextStyle(color: AppColors.pureWhite.withOpacity(0.8)),
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.pureWhite.withOpacity(0.7)),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.pureWhite.withOpacity(0.7),
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: AppColors.pureWhite.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentYellow, width: 2),
        ),
        errorStyle: const TextStyle(color: AppColors.errorRed),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: const [AutofillHints.newPassword],
      textInputAction: TextInputAction.done,
      style: const TextStyle(color: AppColors.pureWhite),
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.isEmpty) {
          return 'Please confirm your password';
        }
        if (trimmed != _passwordController.text.trim()) {
          return 'Passwords do not match';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'CONFIRM PASSWORD',
        labelStyle: TextStyle(color: AppColors.pureWhite.withOpacity(0.8)),
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.pureWhite.withOpacity(0.7)),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.pureWhite.withOpacity(0.7),
          ),
          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
        filled: true,
        fillColor: AppColors.pureWhite.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentYellow, width: 2),
        ),
        errorStyle: const TextStyle(color: AppColors.errorRed),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _signUp,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentYellow,
        foregroundColor: AppColors.primaryGreen,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        shadowColor: AppColors.accentYellow.withOpacity(0.5),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primaryGreen,
            )
          : Text(
              'SIGN UP',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
            ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ALREADY HAVE AN ACCOUNT? ',
          style: TextStyle(color: AppColors.pureWhite.withOpacity(0.8)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BuyerLogIn()),
            );
          },
          child: Text(
            'LOG IN',
            style: TextStyle(
              color: AppColors.accentYellow,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}