import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/providers/parent_provider.dart';
import '../utils/constants.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentRoute = GoRouterState.of(context).uri.toString();
    final parent = ref.watch(currentParentProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Premium: Dark text for light mode, White text for dark mode
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final drawerBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final primaryColor = const Color(0xFF062A5A);

    return Drawer(
      elevation: 10,
      backgroundColor: drawerBg,
      // Premium: Rounded corners on the end
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.horizontal(
          end: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------------- HEADER ----------------
          Container(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 12,
              bottom: 16,
            ),
            // Unified Background: No gradient, matches drawerBg
            decoration: BoxDecoration(
              color: drawerBg,
              borderRadius: const BorderRadiusDirectional.only(
                bottomEnd: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      // Profile tap
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // Border color adapted
                            border: Border.all(
                              color: isDark
                                  ? Colors.white24
                                  : primaryColor.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: primaryColor.withValues(
                              alpha: 0.2,
                            ),
                            child: () {
                              final normalizedUrl = AppConstants.normalizeUrl(parent.avatarUrl);
                              if (normalizedUrl != null && normalizedUrl.isNotEmpty) {
                                if (normalizedUrl.length <= 4) {
                                  return Text(
                                    normalizedUrl,
                                    style: const TextStyle(fontSize: 40),
                                  );
                                } else {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(42),
                                    child: Image.network(
                                      normalizedUrl,
                                      width: 84,
                                      height: 84,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(
                                        CupertinoIcons.person_solid,
                                        size: 45,
                                        color: isDark ? Colors.white : primaryColor,
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                return Icon(
                                  CupertinoIcons.person_solid,
                                  size: 45,
                                  color: isDark ? Colors.white : primaryColor,
                                );
                              }
                            }(),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.amber, // Accent color
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    parent.name.isNotEmpty ? context.translateMock(parent.name) : 'Parent Name',
                    style: TextStyle(
                      color: textColor, // Adaptive Color
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.loc.parentAccount,
                      style: TextStyle(
                        color: subTextColor, // Adaptive Color
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------------- MENU ----------------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 24, left: 16, right: 16),
              children: [
                _DrawerItem(
                  title: context.loc.home,
                  icon: CupertinoIcons.home,
                  route: '/dashboard',
                  currentRoute: currentRoute,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onTap: () => _navigate(context, currentRoute, '/dashboard'),
                ),
                _DrawerItem(
                  title: context.loc.schoolAssignments,
                  icon: CupertinoIcons.book,
                  route: '/assignments',
                  currentRoute: currentRoute,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onTap: () => _navigate(context, currentRoute, '/assignments'),
                ),
                _DrawerItem(
                  title: context.loc.grades,
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  route: '/grades',
                  currentRoute: currentRoute,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onTap: () => _navigate(context, currentRoute, '/grades'),
                ),
                _DrawerItem(
                  title: context.loc.attendanceRecord,
                  icon: Icons.history_rounded,
                  route: '/attendance',
                  currentRoute: currentRoute,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onTap: () => _navigate(context, currentRoute, '/attendance'),
                ),
                _DrawerItem(
                  title: context.loc.absenceRequest,
                  icon: Icons.edit_calendar_rounded,
                  route: '/absence_request',
                  currentRoute: currentRoute,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onTap: () =>
                      _navigate(context, currentRoute, '/absence_request'),
                ),
                _DrawerItem(
                  title: context.loc.absenceRequestsHistory,
                  icon: Icons.assignment_turned_in_rounded,
                  route: '/absence_history',
                  currentRoute: currentRoute,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onTap: () =>
                      _navigate(context, currentRoute, '/absence_history'),
                ),
                _DrawerItem(
                  title: context.loc.classSchedule,
                  icon: CupertinoIcons.calendar_today,
                  route: '/schedule',
                  currentRoute: currentRoute,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onTap: () => _navigate(context, currentRoute, '/schedule'),
                ),
                _DrawerItem(
                  title: context.loc.exams,
                  icon: CupertinoIcons.doc_text_search,
                  route: '/exams',
                  currentRoute: currentRoute,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onTap: () => _navigate(context, currentRoute, '/exams'),
                ),
                _DrawerItem(
                  title: context.loc.fees,
                  icon: CupertinoIcons.creditcard,
                  route: '/fees',
                  currentRoute: currentRoute,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onTap: () => _navigate(context, currentRoute, '/fees'),
                ),
                _DrawerItem(
                  title: context.loc.alerts,
                  icon: CupertinoIcons.exclamationmark_shield_fill,
                  route: '/alerts',
                  currentRoute: currentRoute,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onTap: () => _navigate(context, currentRoute, '/alerts'),
                ),
                _DrawerItem(
                  title: context.loc.notifications,
                  icon: CupertinoIcons.bell,
                  route: '/notifications',
                  currentRoute: currentRoute,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onTap: () =>
                      _navigate(context, currentRoute, '/notifications'),
                ),
                _DrawerItem(
                  title: context.loc.settings,
                  icon: CupertinoIcons.gear_alt,
                  route: '/settings',
                  currentRoute: currentRoute,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onTap: () => _navigate(context, currentRoute, '/settings'),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SafeArea(
              top: false,
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(context.loc.logout),
                      content: Text(context.loc.logoutConfirmation),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(context.loc.cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
                            Navigator.pop(context); // Close drawer
                            context.go('/');
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
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.redAccent[100] : Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: (isDark ? Colors.redAccent[100]! : Colors.red)
                          .withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  backgroundColor: isDark
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.05), // Premium soft background
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
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(
    BuildContext context,
    String currentRoute,
    String targetRoute,
  ) {
    Navigator.pop(context);
    if (currentRoute != targetRoute) {
      context.go(targetRoute);
    }
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.currentRoute,
    required this.isDark,
    required this.primaryColor,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final String route;
  final String currentRoute;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = currentRoute == route && route != '/';

    final Color backgroundColor = isSelected
        ? (isDark
              ? Colors.white.withValues(alpha: 0.1)
              : primaryColor.withValues(alpha: 0.08))
        : Colors.transparent;

    final Color foregroundColor = isSelected
        ? (isDark ? Colors.amber : primaryColor)
        : (isDark ? Colors.white70 : const Color(0xFF64748B));

    final FontWeight fontWeight = isSelected
        ? FontWeight.w700
        : FontWeight.w500;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 4,
      ), // Tighter spacing for "Simple" look
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          dense: true, // Compact
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Slightly smaller radius
          ),
          tileColor: backgroundColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2, // Minimal vertical padding
          ),
          minLeadingWidth: 24, // Tighter icon-text gap
          leading: Icon(
            icon,
            color: foregroundColor,
            size: 22, // Slightly smaller icons
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: fontWeight,
              color: foregroundColor,
              fontSize: 14, // Modern sleek size
            ),
          ),
          trailing: isSelected
              ? Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: foregroundColor,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
