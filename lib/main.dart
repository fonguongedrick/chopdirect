import 'package:chopdirect/api/firebase_api.dart';
import 'package:chopdirect/screens/buyer/buyer_editable%20content/buyer_Edit_profile.dart';
import 'package:chopdirect/screens/buyer/buyer_services/buyer_storage.dart';
import 'package:chopdirect/screens/buyer/checkout.dart';
import 'package:chopdirect/screens/buyer/notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/farmer/farmer_home.dart';
import 'screens/buyer/buyer_home.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // ✅ Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // 👈 Use PlayIntegrity for release
    appleProvider: AppleProvider.debug,     // 👈 Use AppleProvider.appAttest for iOS release
  );

  await Hive.initFlutter();
  await Hive.openBox("cart");
  await FirebaseApi().initNotification();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => StorageServices()),
    ],
    child: const ChopDirectApp(),
  ));
}

class ChopDirectApp extends StatelessWidget {
  const ChopDirectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/farmer': (context) => const FarmerHomeScreen(),
        '/buyer': (context) => const BuyerHomeScreen(),
        '/editProfile': (context) => BuyerEditProfile(),
        '/checkout': (context) => const CheckoutScreen(),
        "/editProfile": (context) => BuyerEditProfile(),
        "/checkout": (context) => const CheckoutScreen(),
        "/notifications": (context) => const Notifications(),
      },
    );
  }
}
