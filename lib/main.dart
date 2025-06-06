import 'package:chopdirect/api/firebase_api.dart';
import 'package:chopdirect/screens/auth/payment_plan.dart';
import 'package:chopdirect/screens/buyer/buyer_editable%20content/buyer_Edit_profile.dart';
import 'package:chopdirect/screens/buyer/buyer_services/buyer_storage.dart';
import 'package:chopdirect/screens/buyer/checkout.dart';
import 'package:chopdirect/screens/buyer/notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/farmer/farmer_home.dart';
import 'screens/buyer/buyer_home.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/auth/pending_approval.dart';
import 'screens/auth/account_suspended.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  // await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
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
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[400]!)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: AuthWrapper(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/farmer': (context) => const FarmerHomeScreen(),
        '/buyer': (context) => const BuyerHomeScreen(),
        '/editProfile': (context) => BuyerEditProfile(),
        '/checkout': (context) => const CheckoutScreen(),
        '/notifications': (context) => const Notifications(),
        '/pending_approval': (context) => const PendingApprovalScreen(),
        '/account_suspended': (context) => const AccountSuspendedScreen(),
    '/payment_plan': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    return PaymentPlanScreen(
    farmerId: args['farmerId'],
    farmName: args['farmName'],
    );},
        // '/checkout': (context) => const CheckoutScreen(),
        "/editProfile": (context) => BuyerEditProfile(),
        // "/checkout": (context) => const CheckoutScreen(),
        "/notifications": (context) => const Notifications(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;

          if (user == null) {
            return const OnboardingScreen();
          }

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users_chopdirect')
                .doc(user.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.done) {
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final role = userData['role'] ?? 'buyer';
                  final status = userData['status'] ?? 'pending';

                  if (status == 'suspended') {
                    return const AccountSuspendedScreen();
                  } else if (status == 'pending') {
                    return const PendingApprovalScreen();
                  }

                  if (role == 'farmer' && userData['paymentPlan'] == null) {
                    return PaymentPlanScreen(
                      farmerId: user.uid,
                      farmName: userData['farmName'] ?? 'Your Farm',
                    );
                  }

                  return role == 'farmer'
                      ? const FarmerHomeScreen()
                      : const BuyerHomeScreen();
                }
                // If user doc doesn't exist, log them out
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FirebaseAuth.instance.signOut();
                });
                return const OnboardingScreen();
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}