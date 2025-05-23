import 'package:chopdirect/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/onboarding_screen.dart';
import 'screens/farmer/farmer_home.dart';
import 'screens/buyer/buyer_home.dart';
import 'screens/auth/registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ChopDirectApp());
}

class ChopDirectApp extends StatelessWidget {
  const ChopDirectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChopDirect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.light(
          primary: Colors.green[800]!,
          secondary: const Color(0xFF8BC34A),
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[800],
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/farmer': (context) => const FarmerHomeScreen(),
        '/buyer': (context) => const BuyerHomeScreen(),
      },
    );
  }
}