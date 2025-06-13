import 'package:chopdirect/chopdirect_auth/farmer_auth/farmer_profile_setup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';

class FarmerOTPVerification extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final Function(PhoneAuthCredential) onVerificationComplete;

  const FarmerOTPVerification({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.onVerificationComplete,
  });

  @override
  State<FarmerOTPVerification> createState() => _FarmerOTPVerificationState();
}

class _FarmerOTPVerificationState extends State<FarmerOTPVerification> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isError = false;
  String? _errorMessage;
  int _resendCooldown = 45;
  bool _canResend = false;
  Timer? _resendTimer;
  String _currentVerificationId = '';

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCooldown = 45;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = null;
      _otpController.clear();
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Do nothing here; user should enter the code manually.
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isError = true;
            _errorMessage = "Resend failed: ${e.message}";
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _currentVerificationId = verificationId;
          });
          _startResendTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _currentVerificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = "Resend error: ${e.toString()}";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOTP() async {
    if (_isLoading) return; // Prevent double submission

    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = null;
    });

    try {
      final smsCode = _otpController.text.trim();
      if (smsCode.length != 6) {
        setState(() {
          _isError = true;
          _errorMessage = "Please enter the 6-digit OTP code.";
        });
        return;
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _currentVerificationId,
        smsCode: smsCode,
      );

      // Only call the callback if you want to allow parent to handle navigation.
      // Otherwise, handle sign-in here.
      // widget.onVerificationComplete(credential);

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Only call the callback after successful sign-in (if needed)
      widget.onVerificationComplete(credential);

      // If new user, create Firestore doc
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        String userId = userCredential.user!.uid;
        await FirebaseFirestore.instance
            .collection("farmers_chopdirect")
            .doc(userId)
            .set({
          'userId': userId,
          'phone': widget.phoneNumber,
          'role': 'Farmer',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FarmerProfileSetUp()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = "Verification failed: ${e.message}";
      });
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = "An error occurred. Please try again.";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCountdownTimer() {
    double progress = _resendCooldown / 45;
    Color timerColor = _resendCooldown > 15
        ? Colors.green
        : _resendCooldown > 5
            ? Colors.orange
            : Colors.red;

    String timerMessage = _resendCooldown > 30
        ? "Ready soon!"
        : _resendCooldown > 15
            ? "Almost there!"
            : "Hang tight!";

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _resendCooldown.toString(),
                key: ValueKey<int>(_resendCooldown),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: timerColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          timerMessage,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "seconds until you can resend",
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[300]!),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        backgroundColor: Colors.green[800],
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF7CB342),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated verification icon
                Animate(
                  effects: [
                    ScaleEffect(
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                    ShimmerEffect(
                      delay: 300.ms,
                      duration: 1000.ms,
                    ),
                  ],
                  child: const Icon(
                    Icons.verified_user,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Verification title with fade animation
                Animate(
                  effects: [FadeEffect(duration: 400.ms)],
                  child: Text(
                    "Verify Your Number",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 10),

                // Phone number display with slide animation
                Animate(
                  effects: [SlideEffect(duration: 500.ms, begin: const Offset(0, -0.2))],
                  child: Text(
                    "Enter OTP sent to ${widget.phoneNumber}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Pinput OTP fields with scale animation
                Animate(
                  effects: [ScaleEffect(duration: 500.ms, curve: Curves.easeOutBack)],
                  child: Pinput(
                    length: 6,
                    controller: _otpController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: Colors.green[700]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                          )
                        ],
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyWith(
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                      ),
                    ),
                    showCursor: true,
                    onCompleted: (pin) => _verifyOTP(),
                  ),
                ),
                const SizedBox(height: 20),

                // Error message
                if (_isError)
                  Animate(
                    effects: [ShakeEffect(duration: 600.ms)],
                    child: Text(
                      _errorMessage ?? "Verification failed",
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 30),

                // Verify Button with pulse animation
                Animate(
                  effects: [
                    ScaleEffect(duration: 500.ms),
                  ],
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEB3B),
                      foregroundColor: Colors.green[800],
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            strokeWidth: 3, color: Colors.green)
                        : const Text(
                            "VERIFY OTP",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),

                // Resend Section with countdown timer
                Column(
                  children: [
                    Text(
                      "Didn't receive the code?",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (!_canResend) _buildCountdownTimer(),

                    const SizedBox(height: 20),

                    // Resend button with conditional appearance
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _canResend
                          ? ElevatedButton(
                              key: const ValueKey('resend-enabled'),
                              onPressed: _resendOTP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              child: const Text(
                                "RESEND OTP",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : TextButton(
                              key: const ValueKey('resend-disabled'),
                              onPressed: null,
                              child: Text(
                                "Resend OTP",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}