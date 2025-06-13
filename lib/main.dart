import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'screens/buyer/buyer_editable%20content/buyer_Edit_profile.dart';
import 'screens/buyer/buyer_services/buyer_storage.dart';

final navigatorKey = GlobalKey<NavigatorState>();

/// ✅ Fetches and saves FCM Token for the authenticated user in Firestore
Future<void> saveFCMToken() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    User? user = FirebaseAuth.instance.currentUser;
    if (token != null && user != null) {
      await FirebaseFirestore.instance.collection('users_chopdirect').doc(user.uid).update({
        'fcmToken': token,
      });

      debugPrint("✅ FCM Token saved successfully: $token");
    } else {
      debugPrint("⚠️ Failed to get FCM Token or User is null.");
    }
  } catch (e) {
    debugPrint("❌ Error saving FCM Token: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  await Hive.initFlutter();
  await Hive.openBox("cart");
Future<void> _setupFCM() async {
  // Request permissions
  await FirebaseMessaging.instance.requestPermission();
  
  // Get token and save to user's document
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': token});
    }
  }
  
  // Handle token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': newToken});
    }
  });
}


  // ✅ Fetch and save FCM Token on startup
  saveFCMToken();

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
      home: const AuthWrapper(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/farmer': (context) => const FarmerHomeScreen(),
        '/buyer': (context) => const BuyerHomeScreen(),
        '/editProfile': (context) => BuyerEditProfile(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  /// ✅ Fetch the authenticated user's role (Farmer or Buyer) and save FCM Token
  Future<String?> _getUserRole(User user) async {
    try {
      // ✅ Save FCM Token whenever user logs in
      await saveFCMToken();

      DocumentSnapshot farmerDoc = await FirebaseFirestore.instance
          .collection('farmers_chopdirect')
          .doc(user.uid)
          .get();
      if (farmerDoc.exists) {
        return 'Farmer';
      }

      DocumentSnapshot buyerDoc = await FirebaseFirestore.instance
          .collection('users_chopdirect')
          .doc(user.uid)
          .get();
      if (buyerDoc.exists) {
        return 'Buyer';
      }
    } catch (e) {
      debugPrint('❌ Error fetching user role: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ✅ While waiting for authentication, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ If a user is logged in, determine their role.
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<String?>(
            future: _getUserRole(snapshot.data!),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (roleSnapshot.hasData) {
                final role = roleSnapshot.data;
                if (role == 'Farmer') {
                  return const FarmerHomeScreen();
                } else if (role == 'Buyer') {
                  return const BuyerHomeScreen();
                }
              }

              // ❌ If role is null or any other case, sign out and route to onboarding.
              FirebaseAuth.instance.signOut();
              return const OnboardingScreen();
            },
          );
        }

        // 🚀 If no user is logged in, show onboarding screen.
        return const OnboardingScreen();
      },
    );
  }
}
