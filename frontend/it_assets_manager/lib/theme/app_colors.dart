import 'package:flutter/material.dart';

class AppColors {
  // Zimbabwe Flag / MOHCC Colors
  static const Color zimGreen = Color(0xFF006B3D); // Standard Zimbabwe Green
  static const Color zimYellow = Color(0xFFFFD200); // Standard Zimbabwe Gold
  static const Color zimRed = Color(0xFFD40000); // Standard Zimbabwe Red
  static const Color zimBlack = Color(0xFF000000);
  static const Color zimWhite = Color(0xFFFFFFFF);

  // Application Semantic Colors
  static const Color primary = zimGreen;
  static const Color onPrimary = zimWhite;
  static const Color secondary = zimYellow;
  static const Color onSecondary = zimBlack;
  static const Color error = zimRed;
  static const Color background = Color(
    0xFFF4F6F8,
  ); // Light grey-ish for enterprise apps
  static const Color surface = Colors.white;

  static const Color textMain = Color(0xFF1F2937); // Dark Grey
  static const Color textSecondary = Color(0xFF6B7280); // Medium Grey
}
