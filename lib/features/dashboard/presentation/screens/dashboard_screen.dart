import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/providers/children_provider.dart';
import '../../../../core/models/student.dart';
import '../../../../core/providers/parent_provider.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/student_avatar.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/providers/notifications_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(childrenProvider.notifier).refresh();
        ref.read(notificationsProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final students = ref.watch(childrenProvider);
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = notificationsAsync.maybeWhen(
      data: (list) => list.where((n) => !n.isRead).length,
      orElse: () => 0,
    );

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? theme.scaffoldBackgroundColor
          : const Color(0xFFF8FAFC),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(childrenProvider.notifier).refresh();
          await ref.read(notificationsProvider.notifier).refresh();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            AppSliverHeader(title: context.loc.home, showChildSwitcher: false),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _WelcomeHeader(),
                  const SizedBox(height: 24),

                  _SummaryStats(
                    students: students,
                    isDark: isDark,
                    unreadCount: unreadCount,
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: context.loc.myChildren, isDark: isDark),
                  const SizedBox(height: 16),
                  if (students.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'جاري تحميل الأبناء...',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else
                    ...students.map(
                      (student) => _ChildQuickCard(
                        student: student,
                        isDark: isDark,
                        onTap: () {
                          ref.read(currentChildProvider.notifier).setChild(student);
                          context.push('/grades');
                        },
                      ),
                    ),
                  const SizedBox(height: 24),

                  _SectionTitle(title: context.loc.quickAccess, isDark: isDark),
                  const SizedBox(height: 16),
                  _QuickActions(isDark: isDark, unreadCount: unreadCount),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends ConsumerWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parent = ref.watch(currentParentProvider);
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = context.loc.goodMorning;
    } else if (hour < 17) {
      greeting = context.loc.goodAfternoon;
    } else {
      greeting = context.loc.goodEvening;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF062A5A), Color(0xFF14448A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF062A5A).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: () {
                final normalizedUrl = AppConstants.normalizeUrl(parent.avatarUrl);
                if (normalizedUrl != null && normalizedUrl.isNotEmpty) {
                  if (normalizedUrl.length <= 4) {
                    return Text(
                      normalizedUrl,
                      style: const TextStyle(fontSize: 28),
                    );
                  } else {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        normalizedUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Text(
                          parent.name.isNotEmpty ? parent.name.substring(0, 1) : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'GoogleSans',
                          ),
                        ),
                      ),
                    );
                  }
                } else {
                  return Text(
                    parent.name.isNotEmpty ? parent.name.substring(0, 1) : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'GoogleSans',
                    ),
                  );
                }
              }(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'GoogleSans',
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    context.loc.welcomeParent(parent.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'GoogleSans',
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.loc.parentAccount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'GoogleSans',
                    ),
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

class _SummaryStats extends StatelessWidget {
  const _SummaryStats({
    required this.students,
    required this.isDark,
    required this.unreadCount,
  });

  final List<Student> students;
  final bool isDark;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.family_restroom_rounded,
            value: students.length.toString(),
            label: context.loc.myChildren,
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF062A5A),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.notifications_active_rounded,
            value: unreadCount.toString(),
            label: context.loc.notifications,
            color: const Color(0xFFEF4444),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'GoogleSans',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ChildQuickCard extends StatelessWidget {
  const _ChildQuickCard({
    required this.student,
    required this.isDark,
    required this.onTap,
  });

  final Student student;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            StudentAvatar(
              photoUrl: student.photoUrl,
              name: student.name,
              size: 48,
              isSelected: true,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'GoogleSans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.grade,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'GoogleSans',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.isDark, required this.unreadCount});

  final bool isDark;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.assignment_turned_in_rounded,
                label: context.loc.assignments,
                color: Colors.teal,
                isDark: isDark,
                onTap: () => context.push('/assignments'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.calendar_month_rounded,
                label: context.loc.attendance,
                color: Colors.orange,
                isDark: isDark,
                onTap: () => context.push('/attendance'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.star_rounded,
                label: context.loc.grades,
                color: const Color(0xFFF59E0B),
                isDark: isDark,
                onTap: () => context.push('/grades'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.quiz_rounded,
                label: context.loc.exams,
                color: Colors.purple,
                isDark: isDark,
                onTap: () => context.push('/exams'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.schedule_rounded,
                label: context.loc.classSchedule,
                color: Colors.indigo,
                isDark: isDark,
                onTap: () => context.push('/schedule'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.attach_money_rounded,
                label: context.loc.fees,
                color: Colors.blue,
                isDark: isDark,
                onTap: () => context.push('/fees'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.notifications_active_rounded,
                label: context.loc.notifications,
                color: Colors.red,
                isDark: isDark,
                badgeCount: unreadCount,
                onTap: () => context.push('/notifications'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.assignment_turned_in_rounded,
                label: context.loc.absenceRequestsHistory,
                color: Colors.green,
                isDark: isDark,
                onTap: () => context.push('/absence_history'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.settings_rounded,
                label: context.loc.settings,
                color: Colors.grey,
                isDark: isDark,
                onTap: () => context.push('/settings'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'GoogleSans',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.isDark});
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1E293B),
        fontSize: 18,
        fontWeight: FontWeight.w800,
        fontFamily: 'GoogleSans',
      ),
    );
  }
}
