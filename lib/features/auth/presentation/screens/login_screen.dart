import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/providers/settings_provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'الرجاء إدخال اسم المستخدم وكلمة المرور'
                : 'Please enter username and password',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await ref.read(authProvider.notifier).login(username, password);
    
    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (authState.value == true) {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force dark theme colors based on the design
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1522) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E2636) : Colors.white;
    final fieldColor = isDark ? const Color(0xFF2C3545) : const Color(0xFFF1F5F9);
    final primaryColor = const Color(0xFF062A5A);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    
    final settings = ref.watch(settingsProvider);
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final isDarkMode = settings.themeMode == ThemeMode.dark || 
                      (settings.themeMode == ThemeMode.system && isDark);

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: Stack(
            children: [
            // Top left icons
            Positioned(
              top: 16,
              left: 16,
              child: Row(
                children: [
                  _buildTopIconButton(
                    icon: CupertinoIcons.globe,
                    isDark: isDark,
                    onPressed: () {
                      ref.read(settingsProvider.notifier).toggleLanguage();
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildTopIconButton(
                    icon: isDarkMode ? CupertinoIcons.sun_max : CupertinoIcons.moon,
                    isDark: isDark,
                    onPressed: () {
                      ref.read(settingsProvider.notifier).toggleTheme(!isDarkMode);
                    },
                  ),
                ],
              ),
            ),
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo
                    Center(
                      child: Container(
                        width: 110,
                        height: 110,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white, // White background to blend with the logo's white background
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black12,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/icons/app_icon.jpeg',
                            fit: BoxFit.contain, // Changed to contain to avoid squeezing
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'رياض و مدارس انوار العلى النموذجية',
                      style: TextStyle(
                        fontSize: 20, // slightly smaller to fit the longer text better
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Login Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            context.loc.login, // Instead of hardcoded, if available, otherwise welcomeBack
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.loc.welcomeBack,
                            style: TextStyle(
                              fontSize: 14,
                              color: subTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // National ID Field
                          _buildTextField(
                            controller: _usernameController,
                            label: context.loc.nationalId,
                            icon: CupertinoIcons.creditcard,
                            fillColor: fieldColor,
                            textColor: textColor,
                            hintColor: subTextColor,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          _buildTextField(
                            controller: _passwordController,
                            label: context.loc.password,
                            icon: CupertinoIcons.lock_fill,
                            fillColor: fieldColor,
                            textColor: textColor,
                            hintColor: subTextColor,
                            isPassword: true,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 16),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                foregroundColor: primaryColor,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                context.loc.forgotPassword,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isDark ? Colors.blueAccent[100] : primaryColor,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Login Button
                          SizedBox(
                            height: 56,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          context.loc.login,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward, size: 20),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTopIconButton({
    required IconData icon, 
    required bool isDark,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: isDark ? Colors.white70 : const Color(0xFF1E293B), size: 20),
        onPressed: onPressed,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(10),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color fillColor,
    required Color textColor,
    required Color hintColor,
    required bool isDark,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: hintColor,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        floatingLabelStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF062A5A),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark ? Colors.transparent : Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(
            icon,
            color: hintColor,
            size: 22,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: isPassword
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? CupertinoIcons.eye_slash_fill
                        : CupertinoIcons.eye_fill,
                    color: hintColor,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.12),
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.12),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: isDark ? Colors.white : const Color(0xFF062A5A),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

