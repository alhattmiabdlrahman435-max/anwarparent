import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/localization_extension.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = 'inquiry'; // 'inquiry', 'complaint', 'suggestion'
  bool _isSubmitting = false;

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح الرابط')),
        );
      }
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(url);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر إجراء المكالمة')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate api call
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 28),
            const SizedBox(width: 8),
            const Text('تم الإرسال بنجاح'),
          ],
        ),
        content: const Text('شكراً لتواصلك معنا. تم استلام رسالتك وسيتم الرد عليك في أقرب وقت ممكن.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _nameController.clear();
              _phoneController.clear();
              _messageController.clear();
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final cardColor = isDark ? AppColors.surfaceAltDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          context.loc.contactUs,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            Text(
              'يسعدنا تواصلكم واستقبال مقترحاتكم',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.accent : AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('أرقام التواصل والاستفسار', isDark),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white10 : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  _buildContactRow(
                    icon: Icons.school_rounded,
                    title: 'مبنى البنين (اتصال مباشر)',
                    value: '03 266118',
                    textColor: textColor,
                    subTextColor: subTextColor,
                    isDark: isDark,
                    isLtr: true,
                    onTap: () => _makeCall('03266118'),
                  ),
                  const Divider(height: 20, thickness: 0.5),
                  _buildContactRow(
                    icon: Icons.school_rounded,
                    title: 'مبنى البنات (اتصال مباشر)',
                    value: '03 266117',
                    textColor: textColor,
                    subTextColor: subTextColor,
                    isDark: isDark,
                    isLtr: true,
                    onTap: () => _makeCall('03266117'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Locations Card
            _buildSectionTitle('مواقع فروعنا الجغرافية', isDark),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white10 : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  _buildContactRow(
                    icon: Icons.location_on_rounded,
                    title: 'مبنى البنين',
                    value: 'شارع الشهداء، تقاطع الأربعين، بجوار كلية المجتمع.',
                    textColor: textColor,
                    subTextColor: subTextColor,
                    isDark: isDark,
                  ),
                  const Divider(height: 20, thickness: 0.5),
                  _buildContactRow(
                    icon: Icons.location_on_rounded,
                    title: 'مبنى البنات',
                    value: 'شارع 7 يوليو.',
                    textColor: textColor,
                    subTextColor: subTextColor,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Social Media & Channels Card
            _buildSectionTitle('تابعونا واشتركوا في منصاتنا', isDark),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white10 : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  _buildContactRow(
                    icon: Icons.chat_rounded,
                    title: 'قناة الواتساب الرسمية',
                    value: 'انقر هنا للاشتراك ومتابعة الأخبار',
                    textColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
                    subTextColor: subTextColor,
                    isDark: isDark,
                    onTap: () => _launchUrl('https://whatsapp.com/channel/0029Vaiuwh5CBtx6Zj172p1M'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  ),
                  const Divider(height: 20, thickness: 0.5),
                  _buildContactRow(
                    icon: Icons.facebook_rounded,
                    title: 'صفحة فيسبوك الرسمية',
                    value: 'انقر هنا لزيارة الصفحة الرسمية للمدارس',
                    textColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
                    subTextColor: subTextColor,
                    isDark: isDark,
                    onTap: () => _launchUrl('https://www.facebook.com/ANWARALOLA'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  ),
                  const Divider(height: 20, thickness: 0.5),
                  _buildContactRow(
                    icon: Icons.telegram_rounded,
                    title: 'قناة التلجرام',
                    value: 'انقر هنا للانضمام إلى القناة التفاعلية',
                    textColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
                    subTextColor: subTextColor,
                    isDark: isDark,
                    onTap: () => _launchUrl('https://t.me/+RZemwA4uzvt76hc_'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Message Form
            Text(
              'أرسل رسالة مباشرة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white10 : AppColors.border,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Message type dropdown / segmented
                    Row(
                      children: [
                        _buildTypeSegment('inquiry', 'استفسار'),
                        const SizedBox(width: 8),
                        _buildTypeSegment('suggestion', 'مقترح'),
                        const SizedBox(width: 8),
                        _buildTypeSegment('complaint', 'شكوى'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Name
                    _buildFormTextField(
                      controller: _nameController,
                      label: 'الاسم الكامل',
                      icon: Icons.person_outline,
                      isDark: isDark,
                      validator: (value) => value!.isEmpty ? 'الرجاء إدخال الاسم' : null,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    _buildFormTextField(
                      controller: _phoneController,
                      label: 'رقم الهاتف',
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                      isDark: isDark,
                      validator: (value) => value!.isEmpty ? 'الرجاء إدخال رقم الهاتف' : null,
                    ),
                    const SizedBox(height: 16),

                    // Message
                    _buildFormTextField(
                      controller: _messageController,
                      label: 'مضمون الرسالة',
                      icon: Icons.chat_bubble_outline,
                      maxLines: 4,
                      isDark: isDark,
                      validator: (value) => value!.isEmpty ? 'الرجاء إدخال نص الرسالة' : null,
                    ),
                    const SizedBox(height: 24),

                    // Send Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'إرسال الرسالة',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String title,
    required String value,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
    bool isLtr = false,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final rowContent = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : AppColors.primary.withValues(alpha: 0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.accent : AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: subTextColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'GoogleSans',
                ),
              ),
              const SizedBox(height: 2.5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'GoogleSans',
                ),
                textDirection: isLtr ? TextDirection.ltr : null,
              ),
            ],
          ),
        ),
        // ignore: use_null_aware_elements
        if (trailing != null) trailing,
      ],
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: rowContent,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: rowContent,
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.accent : AppColors.primary,
          fontFamily: 'GoogleSans',
        ),
      ),
    );
  }

  Widget _buildTypeSegment(String type, String label) {
    final isSelected = _selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
          fontSize: 13.5,
        ),
        floatingLabelStyle: TextStyle(
          color: isDark ? Colors.white : AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? Colors.white38 : Colors.black38,
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        filled: true,
        fillColor: isDark ? Colors.black26 : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white : AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
