// lib/constants/app_constants.dart

import 'package:flutter/material.dart';

class AppColors {
  static const primaryGreen = Color(0xFF2E7D32);
  static const secondaryGreen = Color(0xFF7CB342);
  static const accentYellow = Color(0xFFFFEB3B);
  static const pureWhite = Colors.white;
  static const errorRed = Color(0xFFFFCDD2);
}

class AppRegex {
  static final email = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$"
  );
  
  static final phone = RegExp(
    r'^\+?[\d\s-]{7,15}$'  // Allows optional +, digits, spaces, hyphens, 7-15 chars
  );
}