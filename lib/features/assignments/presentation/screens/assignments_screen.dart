import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/providers/children_provider.dart';
import '../../../../core/providers/assignments_provider.dart';
import '../../../../core/models/assignment.dart';
import '../../../../core/extensions/localization_extension.dart';

class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _getStartOfWeek(DateTime date) {
    int daysToSubtract = (date.weekday - DateTime.saturday) % 7;
    if (daysToSubtract < 0) daysToSubtract += 7;
    return date.subtract(Duration(days: daysToSubtract));
  }

  List<DateTime> _getWeekDays(DateTime startOfWeek) {
    return List.generate(5, (index) {
      return startOfWeek.add(Duration(days: index));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    final currentChild = ref.watch(currentChildProvider);
    // Assignments are fetched below using the notifier.

    List<Assignment> dailyAssignments = [];
    if (currentChild != null) {
      dailyAssignments = ref
          .read(assignmentsProvider.notifier)
          .getAssignmentsForDate(currentChild.id, selectedDate);
    }

    final weekDays = _getWeekDays(_getStartOfWeek(_focusedDate));

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          AppSliverHeader(title: context.loc.schoolAssignments, showChildSwitcher: true),

          // Custom Calendar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
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
                child: Column(
                  children: [
                    // Header (Month + Arrows)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF062A5A),
                          ),
                          onPressed: () {
                            setState(() {
                              _focusedDate = _focusedDate.add(
                                const Duration(days: 7),
                              );
                            });
                          },
                        ),
                        Text(
                          DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode)
                              .format(_focusedDate),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF062A5A),
                          ),
                          onPressed: () {
                            setState(() {
                              _focusedDate = _focusedDate.subtract(
                                const Duration(days: 7),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Days Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: weekDays.map((day) {
                        final isSelected = isSameDay(selectedDate, day);
                        final isToday = isSameDay(DateTime.now(), day);
                        final dayName = DateFormat('E', Localizations.localeOf(context).languageCode).format(day);
                        final dayNum = day.day.toString();

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = day;
                              _focusedDate = day;
                            });
                          },
                          child: Container(
                            color: Colors.transparent, // Expand tap area
                            child: Column(
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? (isDark
                                              ? Colors.white
                                              : const Color(0xFF062A5A))
                                        : (isToday
                                              ? (isDark
                                                    ? Colors.white.withValues(
                                                        alpha: 0.15,
                                                      )
                                                    : const Color(
                                                        0xFF062A5A,
                                                      ).withValues(alpha: 0.15))
                                              : Colors.transparent),
                                  ),
                                  child: Center(
                                    child: Text(
                                      dayNum,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected || isToday
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? (isDark
                                                  ? const Color(0xFF0F172A)
                                                  : Colors.white)
                                            : (isDark
                                                  ? Colors.white
                                                  : Colors.black87),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content Area
          if (currentChild == null)
            SliverFillRemaining(
              child: Center(child: Text(context.loc.pleaseSelectStudent)),
            )
          else if (dailyAssignments.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.doc_text_search,
                      size: 64,
                      color: isDark ? Colors.white38 : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.loc.noAssignmentsForToday,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildAssignmentCard(
                    assignment: dailyAssignments[index],
                    isDark: isDark,
                  );
                }, childCount: dailyAssignments.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard({
    required Assignment assignment,
    required bool isDark,
  }) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFF062A5A).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              CupertinoIcons.book_fill,
              color: isDark ? Colors.white : const Color(0xFF062A5A),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translateMock(assignment.subjectName),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.translateMock(assignment.content),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: 14,
                      color: subTextColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('yyyy-MM-dd').format(assignment.date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: subTextColor,
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
}
