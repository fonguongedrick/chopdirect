import 'dart:async';
import 'package:chopdirect/chopdirect_auth/farmer_auth/farmer_login_otp.dart';
import 'package:chopdirect/chopdirect_auth/farmer_auth/farmer_otp_verification.dart';
import 'package:chopdirect/constants/constanst.dart';
import 'package:chopdirect/screens/farmer/farmer_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';

class FarmerSignupOtp extends StatefulWidget {
  const FarmerSignupOtp({super.key});

  @override
  State<FarmerSignupOtp> createState() => _FarmerSignUpState();
}

class _FarmerSignUpState extends State<FarmerSignupOtp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
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
              _showError("Error during verification: $e");
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _showError(_getFriendlyErrorMessage(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FarmerOTPVerification(
                  verificationId: verificationId,
                  phoneNumber: phoneNumber,
                  onVerificationComplete: (PhoneAuthCredential credential) async {
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
                        _showError("Error during verification: $e");
                      }
                    }
                  },
                ),
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      _showError("An unexpected error occurred. Please try again.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() {
        _isError = true;
        _errorMessage = message;
      });
      _startErrorTimer();
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
        return "Verification failed. Please try again.";
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnimatedIcon(),
                      const SizedBox(height: 20),
                      _buildTitle(context),
                      const SizedBox(height: 40),
                      _buildPhoneInputRow(),
                      if (_isError) _buildErrorMessage(),
                      const SizedBox(height: 30),
                      _buildSendOtpButton(),
                      const SizedBox(height: 30),
                      _buildLoginPrompt(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return const Icon(
      Icons.agriculture,
      size: 80,
      color: AppColors.pureWhite,
    )
        .animate()
        .scale(duration: 500.ms, curve: Curves.elasticOut)
        .shimmer(delay: 600.ms, duration: 1000.ms);
  }

  Widget _buildTitle(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "REGISTER FOR ",
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
            text: "ChopDirect",
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
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPhoneInputRow() {
    return Row(
      children: [
        _buildCountryPicker(),
        const SizedBox(width: 10),
        Expanded(child: _buildPhoneNumberField()),
      ],
    )
        .animate()
        .slideX(duration: 500.ms, begin: -1, curve: Curves.easeOutCubic)
        .fadeIn(duration: 500.ms);
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
          borderSide: BorderSide(color: AppColors.accentYellow, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        errorStyle: const TextStyle(color: AppColors.errorRed),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        _errorMessage ?? "Verification failed",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.errorRed,
          fontWeight: FontWeight.bold,
        ),
      ).animate().shake(duration: 600.ms),
    );
  }

  Widget _buildSendOtpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentYellow,
          foregroundColor: AppColors.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
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
            : const Text(
                "SEND OTP",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
      )
          .animate()
          .scale(duration: 500.ms, curve: Curves.fastOutSlowIn)
          .shimmer(delay: 1000.ms, duration: 1000.ms),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "ALREADY HAVE AN ACCOUNT? ",
          style: TextStyle(color: AppColors.pureWhite.withOpacity(0.8)),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FarmerLoginOtp()),
          ),
          child: Text(
            "LOGIN",
            style: TextStyle(
              color: AppColors.accentYellow,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 700.ms);
  }
}