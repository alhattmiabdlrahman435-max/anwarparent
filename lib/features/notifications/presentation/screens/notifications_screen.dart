import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/extensions/localization_extension.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          AppSliverHeader(title: context.loc.notifications),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildNotificationCard(
                  title: context.loc.generalNotification,
                  message: context.loc.publicHolidayTomorrow,
                  time: context.loc.oneHourAgo,
                  icon: CupertinoIcons.bell_fill,
                  iconColor: Colors.blueAccent,
                  cardColor: cardColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildNotificationCard(
                  title: context.loc.privateMessageFromAdmin,
                  message: context.loc.reviewWithAdmin,
                  time: context.loc.yesterday,
                  icon: CupertinoIcons.person_solid,
                  iconColor: Colors.orangeAccent,
                  cardColor: cardColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isDark: isDark,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
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
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
