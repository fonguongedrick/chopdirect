import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../buyer/buyer_home.dart';
import '../farmer/farmer_home.dart';
import '../onboarding_screen.dart';


class HomeRouter extends StatelessWidget {
  const HomeRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Listen to the auth state changes so we know if a user is logged in.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // While waiting for the Firebase auth state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If no user is logged in, show the onboarding screen.
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const OnboardingScreen();
        }

        // A user is logged in; now fetch the user document from Firestore.
        final currentUser = authSnapshot.data!;
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection("users_chopdirect")
              .doc(currentUser.uid) // Ensure you save documents with the user's UID as their document ID.
              .get(),
          builder: (context, userDocSnapshot) {
            if (userDocSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // If we don't have a user document, you can default to one home screen (buyer for example)
            if (!userDocSnapshot.hasData || !userDocSnapshot.data!.exists) {
              return const BuyerHomeScreen();
            }

            final userData = userDocSnapshot.data!.data();
            final userType = userData?["userType"] ?? "buyer";

            // Route according to the userType value
            if (userType == "farmer") {
              return  FarmerHomeScreen();
            } else {
              return  BuyerHomeScreen();
            }
          },
        );
      },
    );
  }
}
