import 'dart:async';

import 'package:chopdirect/chopdirect_auth/farmer_auth/farmer_otp_verification.dart';
import 'package:chopdirect/chopdirect_auth/farmer_auth/farmer_signUp_otp.dart';
import 'package:chopdirect/constants/constanst.dart';
import 'package:chopdirect/screens/farmer/farmer_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';

import '../../screens/onboarding_screen.dart';

class FarmerLoginOtp extends StatefulWidget {
  const FarmerLoginOtp({super.key});

  @override
  State<FarmerLoginOtp> createState() => _FarmerLoginState();
}

class _FarmerLoginState extends State<FarmerLoginOtp> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final countryPicker = const FlCountryCodePicker();
  CountryCode? countryCode;
  bool _isLoading = false;
  bool _isError = false;
  String? _errorMessage;
  Timer? _errorTimer;

  @override
  void initState() {
    super.initState();
    // Set default country to Cameroon
    countryCode = CountryCode(
      name: 'Cameroon',
      code: 'CM',
      dialCode: '+237',
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  String sanitizePhoneNumber(String phone) {
    // Remove all non-digit characters
    String sanitized = phone.replaceAll(RegExp(r'\D'), '');
    // Remove leading zero if present
    if (sanitized.startsWith('0')) {
      sanitized = sanitized.substring(1);
    }
    return sanitized;
  }

  bool isValidCameroonNumber(String phone) {
    // Cameroon mobile numbers: 6XXXXXXXX or 7XXXXXXXX (9 digits, starting with 6 or 7)
    final sanitized = sanitizePhoneNumber(phone);
    return RegExp(r'^[67]\d{8}$').hasMatch(sanitized);
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = null;
    });

    final sanitizedPhone = sanitizePhoneNumber(_phoneController.text.trim());
    final phoneNumber = '${countryCode?.dialCode}$sanitizedPhone';

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _loginWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isError = true;
            _errorMessage = _getFriendlyErrorMessage(e);
          });
          _startErrorTimer();
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FarmerOTPVerification(
                verificationId: verificationId,
                phoneNumber: phoneNumber,
                onVerificationComplete: _loginWithCredential,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = "An unexpected error occurred. Please try again.";
      });
      _startErrorTimer();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithCredential(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FarmerHomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
          _errorMessage = "Login failed. Please try again.";
        });
        _startErrorTimer();
      }
    }
  }

  String _getFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'too-many-requests':
        return "We've temporarily blocked requests from this device. Please try again later.";
      case 'invalid-phone-number':
        return "Please enter a valid phone number";
      case 'quota-exceeded':
        return "SMS quota exceeded. Please try again later.";
      default:
        return "Login failed. Please try again.";
    }
  }

  void _startErrorTimer() {
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _isError = false);
      }
    });
  }

  Future<void> _showCountryPicker() async {
    final code = await countryPicker.showPicker(context: context);
    if (code != null && mounted) {
      setState(() => countryCode = code);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dismiss keyboard when tapping outside
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryGreen,
                AppColors.secondaryGreen,
              ],
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
                    _buildBackButton(context),
                    _buildAnimatedIcon(),
                    const SizedBox(height: 20),
                    _buildTitle(context),
                    const SizedBox(height: 40),
                    _buildPhoneInputRow(),
                    if (_isError) _buildErrorMessage(),
                    const SizedBox(height: 30),
                    _buildSendOtpButton(),
                    const SizedBox(height: 30),
                    _buildSignUpPrompt(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        },
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
    );
  }

  Widget _buildAnimatedIcon() {
    return Animate(
      effects: [
        ScaleEffect(
          duration: 500.ms,
          curve: Curves.elasticOut,
          begin: const Offset(0.8, 0.8),
        ),
        ShimmerEffect(
          delay: 600.ms,
          duration: 1000.ms,
          angle: 0.5,
        ),
      ],
      child: const Icon(
        Icons.agriculture,
        size: 80,
        color: AppColors.pureWhite,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Animate(
      effects: [FadeEffect(duration: 400.ms)],
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "FARMER ",
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
              text: "LOGIN",
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
    );
  }

  Widget _buildPhoneInputRow() {
    return Animate(
      effects: [
        SlideEffect(
          duration: 500.ms,
          begin: const Offset(-1, 0),
          curve: Curves.easeOutCubic,
        ),
        FadeEffect(duration: 500.ms),
      ],
      child: Row(
        children: [
          _buildCountryPicker(),
          const SizedBox(width: 10),
          Expanded(child: _buildPhoneNumberField()),
        ],
      ),
    );
  }

  Widget _buildCountryPicker() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _showCountryPicker,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (countryCode?.flagUri != null)
                Image.asset(
                  countryCode!.flagUri,
                  package: 'fl_country_code_picker',
                  width: 24,
                ),
              const SizedBox(width: 8),
              Text(
                countryCode?.dialCode ?? '+237',
                style: const TextStyle(
                  color: AppColors.pureWhite,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: AppColors.pureWhite.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      style: const TextStyle(color: AppColors.pureWhite),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Enter your phone number';
        }
        if (!isValidCameroonNumber(value)) {
          return 'Enter a valid Cameroon number\nFormat: 6XXXXXXXX or 7XXXXXXXX';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "PHONE NUMBER",
        labelStyle: TextStyle(color: AppColors.pureWhite.withOpacity(0.8)),
        filled: true,
        fillColor: AppColors.pureWhite.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: AppColors.accentYellow, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 16, horizontal: 20),
        errorStyle: const TextStyle(color: AppColors.errorRed),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Animate(
      effects: [ShakeEffect(duration: 600.ms)],
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          _errorMessage ?? "Login failed",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.errorRed,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSendOtpButton() {
    return Animate(
      effects: [
        ScaleEffect(duration: 500.ms, curve: Curves.fastOutSlowIn),
        ShimmerEffect(
          delay: 1000.ms,
          duration: 1000.ms,
          curve: Curves.easeInOut,
        ),
      ],
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentYellow,
          foregroundColor: AppColors.primaryGreen,
          padding: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: AppColors.accentYellow.withOpacity(0.5),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                strokeWidth: 3, color: AppColors.primaryGreen)
            : Text(
                "SEND OTP",
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
  }

  Widget _buildSignUpPrompt(BuildContext context) {
    return Animate(
      effects: [FadeEffect(duration: 700.ms)],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "DON'T HAVE AN ACCOUNT? ",
            style: TextStyle(color: AppColors.pureWhite.withOpacity(0.8)),
          ),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const FarmerSignupOtp())),
            child: Text(
              "SignUp",
              style: TextStyle(
                  color: AppColors.accentYellow, fontSize: 18),
            ),
          )
        ],
      ),
    );
  }
}