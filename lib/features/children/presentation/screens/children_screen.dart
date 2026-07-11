import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/children_provider.dart';
import '../../../../core/models/student.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/widgets/student_avatar.dart';
import '../../../../core/extensions/localization_extension.dart';

class ChildrenScreen extends ConsumerWidget {
  const ChildrenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final primaryColor = const Color(0xFF062A5A);

    final students = ref.watch(childrenProvider);
    final currentChild = ref.watch(currentChildProvider);

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          AppSliverHeader(
            title: context.loc.myChildren,
            showChildSwitcher: false,
          ),
          if (students.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.family_restroom_rounded,
                      size: 64,
                      color: isDark ? Colors.white24 : Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.loc.noRegisteredStudents,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final student = students[index];
                    final isSelected = currentChild?.id == student.id;
                    return _buildChildCard(
                      context: context,
                      ref: ref,
                      student: student,
                      isSelected: isSelected,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    );
                  },
                  childCount: students.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildChildCard({
    required BuildContext context,
    required WidgetRef ref,
    required Student student,
    required bool isSelected,
    required bool isDark,
    required Color primaryColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final activeBorderColor = isDark ? Colors.amber : primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? activeBorderColor
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15)),
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? (isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : activeBorderColor.withValues(alpha: 0.08))
                : (isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : const Color(0xFF062A5A).withValues(alpha: 0.04)),
            blurRadius: isSelected ? 20 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Upper Section: Child Profile Info (RTL Flow)
          InkWell(
            onTap: () {
              ref.read(currentChildProvider.notifier).setChild(student);
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  // Right: Avatar with Grade-based Gradient
                  StudentAvatar(
                    photoUrl: student.photoUrl,
                    name: student.name,
                    size: 56,
                    isSelected: isSelected,
                  ),
                  const SizedBox(width: 16),
                  
                  // Middle: Name and Grade (Aligned Right)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: [
                        Text(
                          student.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontFamily: 'GoogleSans',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(
                              Icons.school_rounded,
                              size: 14,
                              color: subTextColor.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              student.grade,
                              style: TextStyle(
                                fontSize: 12,
                                color: subTextColor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'GoogleSans',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Left: Selection / Activation Toggle (RTL layout places it on left)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF22C55E)
                            : (isDark ? Colors.white24 : Colors.grey.shade300),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.rtl,
                      children: [
                        if (isSelected) ...[
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: Color(0xFF22C55E),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          isSelected ? 'النشط' : 'تنشيط',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFF22C55E)
                                : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                            fontFamily: 'GoogleSans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, indent: 20, endIndent: 20),

          // Lower Section: 3x2 Grid Quick Actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      context.loc.quickAccess,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: subTextColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Row 1: Assignments, Attendance, Grades
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: _buildGridActionItem(
                        context: context,
                        ref: ref,
                        student: student,
                        icon: Icons.assignment_turned_in_rounded,
                        label: context.loc.assignments,
                        color: Colors.teal,
                        route: '/assignments',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildGridActionItem(
                        context: context,
                        ref: ref,
                        student: student,
                        icon: Icons.calendar_month_rounded,
                        label: context.loc.attendance,
                        color: Colors.orange,
                        route: '/attendance',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildGridActionItem(
                        context: context,
                        ref: ref,
                        student: student,
                        icon: Icons.star_rounded,
                        label: context.loc.grades,
                        color: const Color(0xFFF59E0B),
                        route: '/grades',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Row 2: Exams, Fees, Dashboard (Home)
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: _buildGridActionItem(
                        context: context,
                        ref: ref,
                        student: student,
                        icon: Icons.book_rounded,
                        label: context.loc.exams,
                        color: Colors.purple,
                        route: '/exams',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildGridActionItem(
                        context: context,
                        ref: ref,
                        student: student,
                        icon: Icons.attach_money_rounded,
                        label: context.loc.fees,
                        color: Colors.blue,
                        route: '/fees',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildGridActionItem(
                        context: context,
                        ref: ref,
                        student: student,
                        icon: Icons.home_rounded,
                        label: context.loc.home,
                        color: Colors.indigo,
                        route: '/dashboard',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridActionItem({
    required BuildContext context,
    required WidgetRef ref,
    required Student student,
    required IconData icon,
    required String label,
    required Color color,
    required String route,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Select student and navigate
          ref.read(currentChildProvider.notifier).setChild(student);
          context.push(route);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.08 : 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.15 : 0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'GoogleSans',
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
