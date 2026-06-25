import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;

  const AppSettings({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('ar'),
  });

  AppSettings copyWith({ThemeMode? themeMode, Locale? locale}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

@riverpod
class Settings extends _$Settings {
  @override
  AppSettings build() {
    _loadSettings();
    return const AppSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    final languageCode = prefs.getString('languageCode') ?? 'ar';

    state = state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(languageCode),
    );
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    state = state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }

  Future<void> toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final newLang = state.locale.languageCode == 'ar' ? 'en' : 'ar';
    await prefs.setString('languageCode', newLang);
    state = state.copyWith(locale: Locale(newLang));
  }
}
