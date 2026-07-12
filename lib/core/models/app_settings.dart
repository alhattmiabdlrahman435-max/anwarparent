import 'package:flutter/material.dart';

enum AppFontSize {
  small,
  medium,
  large,
}

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;
  final AppFontSize fontSize;

  const AppSettings({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('ar'),
    this.fontSize = AppFontSize.medium,
  });

  double get fontSizeFactor {
    switch (fontSize) {
      case AppFontSize.small:
        return 0.85;
      case AppFontSize.medium:
        return 1.0;
      case AppFontSize.large:
        return 1.25;
    }
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    AppFontSize? fontSize,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}
