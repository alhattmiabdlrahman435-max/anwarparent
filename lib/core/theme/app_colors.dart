import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary
  static const Color primary = Color(0xFF062A5A);
  static const Color accent = Color(0xFFFFD230);
  static const Color primaryGradient = Color(0xFF0083DA);

  // Surface Colors
  static const Color surfaceLight = Color(0xFFF7F9FC);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceAltLight = Colors.white;
  static const Color surfaceAltDark = Color(0xFF1E293B);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  // Missing properties from Settings integration
  static const Color backgroundDark = surfaceDark;
  static const Color secondary = accent;
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
}
