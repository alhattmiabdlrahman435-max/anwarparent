import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/localization_extension.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(url);
    } catch (_) {}
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final String cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri url = Uri.parse("https://wa.me/967$cleanPhone");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
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
          context.loc.helpCenter,
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
            // Header Image/Icon
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.headset(PhosphorIconsStyle.duotone),
                  size: 48,
                  color: isDark ? AppColors.accent : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'الدعم الفني ومركز المساعدة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'يسعدنا تقديم الدعم الفني لك وحل أي مشاكل تواجهك في استخدام التطبيق.',
              style: TextStyle(
                fontSize: 14,
                color: subTextColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Silicon Apex Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white10 : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '< >',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
                            fontFamily: 'GoogleSans',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Silicon Apex (SA)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                fontFamily: 'GoogleSans',
                              ),
                            ),
                            Text(
                              'الجهة المطورة للتطبيق',
                              style: TextStyle(
                                fontSize: 12,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30, thickness: 0.5),
                  Text(
                    'سيلكون أبكس (Silicon Apex) هي شركة برمجية متخصصة في تطوير الأنظمة والتطبيقات والحلول الرقمية المتكاملة، وتعد المطور الرسمي لنظام و تطبيقات مدارس انوار العلى.',
                    style: TextStyle(
                      fontSize: 14,
                      color: subTextColor,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                  
                  // Contact details
                  _buildSupportItem(
                    context: context,
                    icon: PhosphorIcons.phone(PhosphorIconsStyle.duotone),
                    title: 'رقم الهاتف',
                    value: '733271647',
                    isLtr: true,
                    onTap: () => _makeCall('733271647'),
                    actionIcon: Icons.phone_in_talk_rounded,
                    actionColor: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildSupportItem(
                    context: context,
                    icon: PhosphorIcons.whatsappLogo(PhosphorIconsStyle.duotone),
                    title: 'مراسلة عبر الواتساب',
                    value: '733271647',
                    isLtr: true,
                    onTap: () => _openWhatsApp('733271647'),
                    actionIcon: Icons.chat_bubble_outline_rounded,
                    actionColor: const Color(0xFF25D366),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    required IconData actionIcon,
    required Color actionColor,
    bool isLtr = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.border,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: isDark ? AppColors.accent : AppColors.primary, size: 24),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: subTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
            fontFamily: 'GoogleSans',
          ),
          textDirection: isLtr ? TextDirection.ltr : null,
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: actionColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            actionIcon,
            color: actionColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}
