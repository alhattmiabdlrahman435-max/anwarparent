import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/extensions/localization_extension.dart';

import 'about_app_screen.dart';
import 'privacy_policy_screen.dart';
import 'contact_us_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = settings.themeMode == ThemeMode.dark;
    final isArabic = settings.locale.languageCode == 'ar';
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          AppSliverHeader(
            title: context.loc.settings,
            showChildSwitcher: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Section
                  _SectionHeader(title: context.loc.account),
                  const SizedBox(height: 16),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: PhosphorIcons.userCircle(
                          PhosphorIconsStyle.duotone,
                        ),
                        title: context.loc.profile,
                        subtitle: context.loc.editProfile,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // App Settings Section
                  _SectionHeader(title: context.loc.app),
                  const SizedBox(height: 16),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: isDark
                            ? PhosphorIcons.moonStars(
                                PhosphorIconsStyle.duotone,
                              )
                            : PhosphorIcons.sun(PhosphorIconsStyle.duotone),
                        title: context.loc.appearance,
                        subtitle: isDark
                            ? context.loc.dark
                            : context.loc.light,
                        trailing: _SegmentedToggle(
                          value: isDark,
                          onChanged: (v) {
                            if (v != isDark) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .toggleTheme(v);
                            }
                          },
                          leftLabel: context.loc.light,
                          rightLabel: context.loc.dark,
                          leftIcon: PhosphorIcons.sun(PhosphorIconsStyle.bold),
                          rightIcon: PhosphorIcons.moonStars(
                            PhosphorIconsStyle.bold,
                          ),
                        ),
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: PhosphorIcons.translate(
                          PhosphorIconsStyle.duotone,
                        ),
                        title: context.loc.language,
                        trailing: _SegmentedToggle(
                          value:
                              !isArabic, // False (Left) = Arabic, True (Right) = English
                          onChanged: (targetIsEnglish) {
                            if (targetIsEnglish == isArabic) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .toggleLanguage();
                            }
                          },
                          leftLabel: context.loc.arabic,
                          rightLabel: context.loc.english,
                          leftIcon: PhosphorIcons.translate(
                            PhosphorIconsStyle.bold,
                          ),
                          rightIcon: PhosphorIcons.textAa(
                            PhosphorIconsStyle.bold,
                          ),
                        ),
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: PhosphorIcons.bellSimple(
                          PhosphorIconsStyle.duotone,
                        ),
                        title: context.loc.notifications,
                        subtitle: context.loc.activitiesAndMessages,
                        trailing: Switch.adaptive(
                          value: notificationsEnabled,
                          activeTrackColor: AppColors.primary,
                          onChanged: (v) =>
                              setState(() => notificationsEnabled = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Support Section
                  _SectionHeader(title: context.loc.support),
                  const SizedBox(height: 16),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: PhosphorIcons.question(
                          PhosphorIconsStyle.duotone,
                        ),
                        title: context.loc.helpCenter,
                        onTap: () {},
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: PhosphorIcons.phoneCall(
                          PhosphorIconsStyle.duotone,
                        ),
                        title: context.loc.contactUs,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ContactUsScreen(),
                          ),
                        ),
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: PhosphorIcons.info(PhosphorIconsStyle.duotone),
                        title: context.loc.aboutApp,
                        subtitle: 'v2.0.0',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AboutAppScreen(),
                          ),
                        ),
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: PhosphorIcons.shieldCheck(
                          PhosphorIconsStyle.duotone,
                        ),
                        title: context.loc.privacyPolicy,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(context.loc.logout),
                            content: Text(
                              context.loc.logoutConfirmation,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(context.loc.cancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.go('/login');
                                },
                                child: Text(
                                  context.loc.logout,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.diagonal3Values(
                              Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0,
                              1.0,
                              1.0,
                            ),
                            child: const Icon(Icons.logout_rounded, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            context.loc.logout,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.border,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDark ? Colors.white : AppColors.primary,
                  size: 22,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white60
                              : AppColors.textSecondary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 1,
      indent: 64,
      endIndent: 0,
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : AppColors.border.withValues(alpha: 0.5),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    required this.value,
    required this.onChanged,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftIcon,
    required this.rightIcon,
  });

  final bool value; // false = left, true = right
  final ValueChanged<bool> onChanged;
  final String leftLabel;
  final String rightLabel;
  final IconData leftIcon;
  final IconData rightIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(
            context: context,
            isSelected: !value,
            label: leftLabel,
            icon: leftIcon,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: 4),
          _buildSegment(
            context: context,
            isSelected: value,
            label: rightLabel,
            icon: rightIcon,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required BuildContext context,
    required bool isSelected,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF334155) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? (isDark ? Colors.white : AppColors.primary)
                  : (isDark ? Colors.white38 : Colors.grey),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.textPrimary)
                    : (isDark ? Colors.white38 : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
