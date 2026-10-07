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

  void _showForgotPasswordSheet() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nationalIdController = TextEditingController(text: _usernameController.text.trim());
    bool isSubmitting = false;
    String? localError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
            final cardBg = isDark ? const Color(0xFF1E2636) : Colors.white;
            final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
            final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

            Future<void> submitReset() async {
              final id = nationalIdController.text.trim();
              if (id.isEmpty) {
                setSheetState(() {
                  localError = isArabic 
                      ? 'الرجاء إدخال الرقم المدني / الوطني' 
                      : 'Please enter Civil / National ID';
                });
                return;
              }

              setSheetState(() {
                isSubmitting = true;
                localError = null;
              });

              try {
                final result = await ref
                    .read(authProvider.notifier)
                    .resetPasswordWithNationalId(id);

                if (!bottomSheetContext.mounted || !mounted) return;
                Navigator.of(bottomSheetContext).pop();

                // Pre-fill fields on the login screen
                _usernameController.text = id;
                _passwordController.text = result['default_password'] ?? '12345678';

                // Show success modal dialog with the default password
                _showResetSuccessDialog(
                  parentName: result['parent_name'] ?? '',
                  nationalId: id,
                  defaultPassword: result['default_password'] ?? '12345678',
                );
              } catch (e) {
                setSheetState(() {
                  isSubmitting = false;
                  final errStr = e.toString().replaceAll('Exception: ', '');
                  localError = errStr;
                });
              }
            }

            return Container(
              padding: EdgeInsets.only(
                bottom: bottomPadding + 24,
                top: 16,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Drag indicator
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Icon & Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF062A5A).withValues(alpha: isDark ? 0.25 : 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF062A5A).withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.lock_shield_fill,
                            color: Color(0xFF062A5A),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? 'استعادة كلمة المرور' : 'Reset Password',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isArabic
                                    ? 'استعادة كلمة المرور الافتراضية لحساب ولي الأمر'
                                    : 'Restore default password for parent account',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(bottomSheetContext).pop(),
                          icon: Icon(
                            CupertinoIcons.xmark_circle_fill,
                            color: subTextColor.withValues(alpha: 0.5),
                            size: 24,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Instruction note
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            CupertinoIcons.info_circle_fill,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isArabic
                                  ? 'أدخل رقم الهوية / الرقم المدني لولي الأمر، وسيقوم النظام بتصفير كلمة المرور إلى الرمز الافتراضي (12345678).'
                                  : 'Enter parent Civil / National ID to reset the account password back to default (12345678).',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? Colors.amber[100] : const Color(0xFF92400E),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Input Field
                    Text(
                      isArabic ? 'الرقم المدني / الوطني لولي الأمر' : 'Civil / National ID',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nationalIdController,
                      keyboardType: TextInputType.text,
                      autofocus: true,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: isArabic ? 'مثال: 1010305738' : 'e.g. 1010305738',
                        hintStyle: TextStyle(
                          color: subTextColor.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2C3545) : const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        prefixIcon: Icon(
                          CupertinoIcons.person_badge_minus,
                          color: subTextColor,
                          size: 20,
                        ),
                        suffixIcon: nationalIdController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  nationalIdController.clear();
                                  setSheetState(() {});
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF062A5A), width: 1.5),
                        ),
                      ),
                      onChanged: (_) {
                        if (localError != null) {
                          setSheetState(() => localError = null);
                        } else {
                          setSheetState(() {});
                        }
                      },
                    ),

                    // Error text if any
                    if (localError != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                localError!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Reset Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : submitReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF062A5A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(CupertinoIcons.arrow_counterclockwise, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    isArabic ? 'استعادة كلمة المرور' : 'Reset Password',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showResetSuccessDialog({
    required String parentName,
    required String nationalId,
    required String defaultPassword,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E2636) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: cardBg,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green checkmark badge
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.checkmark_seal_fill,
                      color: Colors.green,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  isArabic ? 'تمت استعادة كلمة المرور بنجاح!' : 'Password Reset Successfully!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                if (parentName.isNotEmpty) ...[
                  Text(
                    parentName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF062A5A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                ],

                // Box showing default password
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C3545) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isArabic ? 'كلمة المرور الافتراضية لحسابك:' : 'Your default password:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: subTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF062A5A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          defaultPassword,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                Text(
                  isArabic
                      ? 'تم إدراج بيانات الدخول تلقائياً. يمكنك الآن تسجيل الدخول مباشرة وتعديل كلمة المرور من ملفك الشخصي لاحقاً.'
                      : 'Credentials have been filled automatically. You can now log in and change your password in your profile anytime.',
                  style: TextStyle(
                    fontSize: 12,
                    color: subTextColor,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 22),

                // Button: Log In Now
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _handleLogin();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF062A5A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isArabic ? 'تسجيل الدخول الآن' : 'Log In Now',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                              onPressed: _showForgotPasswordSheet,
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

