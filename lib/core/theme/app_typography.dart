import 'package:flutter/material.dart';

class AppTypography {
  static const fontFamily = 'GoogleSans';

  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 46,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
