import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

 class AuthService{
    signUp(String email, String password) async {
     try {
       UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
         email: email,
         password: password,
       );
       print("User registered: ${userCredential.user?.email}");
     } catch (e) {
       print("Error: $e");
     }
   }

   Future<void> signIn(String email, String password) async {
     try {
       UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
         email: email,
         password: password,
       );
       print("User signed in: ${userCredential.user?.email}");
     } catch (e) {
       print("Login error: $e");
     }
   }

   Future<void> signOut() async {
     await FirebaseAuth.instance.signOut();
     print("User signed out");
   }
 }