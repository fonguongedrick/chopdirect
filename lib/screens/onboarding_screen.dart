import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chopdirect/chopdirect_auth/buyer_Auth/buyer_login_otp.dart';
import 'package:chopdirect/chopdirect_auth/farmer_auth/farmer_login_otp.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  // Define our color palette
  static const _darkGreen = Color(0xFF0B6623);
  static const _mediumGreen = Color(0xFF3BB143);
  static const _lightGreen = Color(0xFF8FC31F);
  static const _vibrantYellow = Color(0xFFFFD700);
  static const _softYellow = Color(0xFFFFFACD);
  static const _pureWhite = Colors.white;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_darkGreen, _mediumGreen, _lightGreen],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Green decorative elements
            Positioned(
              top: 50,
              right: 30,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: RotationTransition(
                  turns: _rotateController,
                  child: Icon(
                    Icons.eco,
                    size: 60,
                    color: _pureWhite.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: 20,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Icon(
                  Icons.agriculture,
                  size: 80,
                  color: _pureWhite.withOpacity(0.2),
                ),
              ),
            ),

            // Yellow decorative elements
            Positioned(
              top: 150,
              left: 40,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: RotationTransition(
                  turns: _rotateController,
                  child: Icon(
                    Icons.star,
                    size: 50,
                    color: _vibrantYellow.withOpacity(0.4),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // White logo with green accent
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: _pureWhite.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _pureWhite,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _darkGreen.withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.spa,
                              size: 80,
                              color: _pureWhite,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Yellow badge with white text
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _vibrantYellow.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _vibrantYellow,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _vibrantYellow.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Text(
                                "LEVEL 1: WELCOME",
                                style: TextStyle(
                                  color: _pureWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // White text with green shadow
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'ChopDirect',
                                  style: TextStyle(
                                    color: _pureWhite,
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: _darkGreen.withOpacity(0.8),
                                        offset: const Offset(2, 2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Farm to Buyer, Directly',
                                  style: TextStyle(
                                    color: _pureWhite.withOpacity(0.9),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Green button with white text
                        _buildGameButton(
                          context,
                          "I'm a Farmer",
                          _mediumGreen,
                          const FarmerLoginOtp(),
                          icon: Icons.agriculture,
                          animationDelay: 200,
                        ),
                        const SizedBox(height: 16),

                        // Yellow button with white text
                        _buildGameButton(
                          context,
                          "I'm a Buyer",
                          _vibrantYellow,
                          const BuyerLogIn(),
                          icon: Icons.shopping_cart,
                          animationDelay: 400,
                        ),
                        const SizedBox(height: 32),

                        // Yellow progress indicator with white text
                        _buildProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameButton(
    BuildContext context,
    String text,
    Color color,
    Widget destination, {
    required IconData icon,
    int animationDelay = 0,
  }) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
              0,
              (1 - Curves.easeOut.transform(
                      _fadeController.value - (animationDelay / 1500)))
                  * 20),
          child: Opacity(
            opacity: _fadeController.value > (animationDelay / 1500)
                ? 1.0
                : 0.0,
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  destination,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: _pureWhite, size: 28),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(
                    color: _pureWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                        color: _darkGreen.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.workspace_premium, color: _vibrantYellow, size: 24),
            const SizedBox(width: 8),
            Text(
              "Complete onboarding to earn 100 XP!",
              style: TextStyle(
                color: _softYellow,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                    color: _darkGreen.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 20,
          width: 250,
          decoration: BoxDecoration(
            color: _pureWhite.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: _darkGreen.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Progress bar (yellow)
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(seconds: 2),
                    curve: Curves.elasticOut,
                    width: constraints.maxWidth * 0.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_vibrantYellow, _softYellow],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: _vibrantYellow.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  );
                },
              ),
              // XP text overlay (white)
              Center(
                child: Text(
                  "50/100 XP",
                  style: TextStyle(
                    color: _pureWhite,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                        color: _darkGreen.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}