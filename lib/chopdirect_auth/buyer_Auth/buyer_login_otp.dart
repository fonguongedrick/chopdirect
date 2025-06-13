import 'package:chopdirect/constants/constanst.dart';
import 'package:chopdirect/screens/buyer/buyer_home.dart';
import 'package:chopdirect/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'buyer_signUp_otp.dart';

class BuyerLogIn extends StatefulWidget {
  const BuyerLogIn({super.key});

  @override
  State<BuyerLogIn> createState() => _BuyerLogInState();
}

class _BuyerLogInState extends State<BuyerLogIn>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BuyerHomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mapErrorCode(e.code)),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !AppRegex.email.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email to reset password.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent! Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mapErrorCode(e.code)),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  String _mapErrorCode(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Account not found! Register first';
      case 'wrong-password':
        return 'Incorrect password! Try again';
      case 'invalid-email':
        return 'Invalid email format';
      default:
        return 'Login failed: ${code.replaceAll('-', ' ')}';
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
              colors: [
                AppColors.primaryGreen,
                AppColors.secondaryGreen,
              ],
              stops: [0.2, 0.8],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingScreen(),
                          ),
                        ),
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.pureWhite.withOpacity(0.15),
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_left,
                            size: 40,
                            color: AppColors.pureWhite,
                          ),
                        ),
                      ),
                    ),

                    // Animated Logo
                    Animate(
                      onPlay: (controller) => controller.repeat(),
                      effects: [
                        SlideEffect(
                          duration: 800.ms,
                          begin: const Offset(0, -0.1),
                          end: const Offset(0, 0.1),
                          curve: Curves.elasticInOut,
                        ),
                        ShimmerEffect(
                          delay: 600.ms,
                          duration: 1000.ms,
                        ),
                      ],
                      child: const Icon(
                        Icons.shopping_basket_rounded,
                        size: 80,
                        color: AppColors.pureWhite,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Animate(
                      effects: [FadeEffect(duration: 400.ms)],
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Chop",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.pureWhite,
                                    letterSpacing: 0,
                                  ),
                            ),
                            TextSpan(
                              text: "Direct",
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
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Email Field
                    Animate(
                      effects: [
                        SlideEffect(
                          duration: 500.ms,
                          begin: const Offset(-0.5, 0),
                        )
                      ],
                      child: _InputField(
                        key: const ValueKey('email_field'),
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        label: "EMAIL",
                        autofillHints: const [AutofillHints.email],
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) {
                            return 'Enter your email';
                          }
                          if (!AppRegex.email.hasMatch(trimmed)) {
                            return 'Enter valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    Animate(
                      effects: [
                        SlideEffect(
                          duration: 500.ms,
                          begin: const Offset(0.5, 0),
                          delay: 100.ms,
                        )
                      ],
                      child: _InputField(
                        key: const ValueKey('password_field'),
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        label: "PASSWORD",
                        isPassword: true,
                        autofillHints: const [AutofillHints.password],
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) {
                            return 'Enter password';
                          }
                          if (trimmed.length < 6) {
                            return 'Password too short (min 6 chars)';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Forgot Password
                    Animate(
                      effects: [FadeEffect(duration: 600.ms)],
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: Text(
                            "FORGOT PASSWORD?",
                            style: TextStyle(
                              color: AppColors.pureWhite.withOpacity(0.8),
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Login Button
                    Animate(
                      effects: [ScaleEffect(duration: 500.ms)],
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
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
                                      "LogIn",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Sign Up Section
                    Animate(
                      effects: [FadeEffect(duration: 700.ms)],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "NEW TO ChopDirect? ",
                            style: TextStyle(
                              color: AppColors.pureWhite.withOpacity(0.8),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BuyerSignUp(),
                              ),
                            ),
                            child: Text(
                              "REGISTER",
                              style: TextStyle(
                                color: AppColors.accentYellow,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final bool isPassword;
  final List<String>? autofillHints;
  final String? Function(String?)? validator;

  const _InputField({
    Key? key,
    required this.controller,
    required this.icon,
    required this.label,
    this.isPassword = false,
    this.autofillHints,
    this.validator,
  }) : super(key: key);

  @override
  State<_InputField> createState() => __InputFieldState();
}

class __InputFieldState extends State<_InputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      style: const TextStyle(color: AppColors.pureWhite),
      validator: widget.validator,
      autofillHints: widget.autofillHints,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          color: AppColors.pureWhite.withOpacity(0.8),
        ),
        prefixIcon: Icon(
          widget.icon,
          color: AppColors.pureWhite.withOpacity(0.7),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.pureWhite.withOpacity(0.7),
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        filled: true,
        fillColor: AppColors.pureWhite.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.accentYellow,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        errorStyle: const TextStyle(color: AppColors.errorRed),
      ),
    );
  }
}