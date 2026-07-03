import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  AppSettings build() {
    _loadSettings();
    return const AppSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDark') ?? false;
      final languageCode = prefs.getString('languageCode') ?? 'ar';

      state = state.copyWith(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        locale: Locale(languageCode),
      );
    } catch (_) {
      // In case of error, defaults (ar, light theme) returned by build() will be preserved.
    }
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
