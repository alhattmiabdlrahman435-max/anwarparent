import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/localization_extension.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : const Color(0xFF062A5A);
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo Placeholder
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF062A5A), Color(0xFF14448A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF062A5A).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.book_solid,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Text(
                  context.loc.login,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  context.loc.welcomeBack,
                  style: TextStyle(
                    fontSize: 16,
                    color: subTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Username Field
                _buildTextField(
                  label: context.loc.phoneNumberOrUsername,
                  icon: CupertinoIcons.person_solid,
                  isDark: isDark,
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 20),

                // Password Field
                _buildTextField(
                  label: context.loc.password,
                  icon: CupertinoIcons.lock_fill,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  isPassword: true,
                ),

                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: isDark
                          ? Colors.white70
                          : const Color(0xFF062A5A),
                    ),
                    child: Text(
                      context.loc.forgotPassword,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF062A5A), Color(0xFF14448A)],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF062A5A).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              context.loc.login,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required bool isDark,
    required Color primaryColor,
    bool isPassword = false,
  }) {
    return TextFormField(
      obscureText: isPassword && _obscurePassword,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1E293B),
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white60 : const Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        prefixIcon: Icon(
          icon,
          color: isDark ? Colors.white54 : const Color(0xFF062A5A),
          size: 22,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? CupertinoIcons.eye_slash_fill
                      : CupertinoIcons.eye_fill,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: isDark
              ? BorderSide(color: Colors.white.withValues(alpha: 0.1))
              : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: isDark
              ? BorderSide(color: Colors.white.withValues(alpha: 0.1))
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }
}
