import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/providers/children_provider.dart';
import '../../../../core/models/student.dart';
import '../../../../core/widgets/student_avatar.dart';
import '../../../../core/providers/attendance_provider.dart';
import '../../../../core/models/attendance.dart';
import '../../../../core/extensions/localization_extension.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(attendanceDataProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    final kids = ref.watch(childrenProvider);
    final currentChild = ref.watch(currentChildProvider);
    final attendanceRecords = ref.watch(attendanceDataProvider);

    AttendanceRecord? record;
    if (currentChild != null && attendanceRecords.isNotEmpty) {
      try {
        record = attendanceRecords.firstWhere((r) => r.studentId == currentChild.id);
      } catch (_) {
        record = null;
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(childrenProvider.notifier).refresh();
          await ref.read(attendanceDataProvider.notifier).refresh();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            AppSliverHeader(title: context.loc.attendanceRecord, showChildSwitcher: false),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Title
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    context.loc.children,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Children List
                ...kids.map(
                  (kid) => _buildChildSelectionCard(
                    child: kid,
                    isSelected: currentChild?.id == kid.id,
                    isDark: isDark,
                    cardColor: cardColor,
                    textColor: textColor,
                  ),
                ),

                const SizedBox(height: 24),

                if (kids.isNotEmpty && attendanceRecords.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (record != null) ...[
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          count: record.presentDays,
                          label: context.loc.attendanceDays,
                          icon: CupertinoIcons.checkmark_alt_circle_fill,
                          iconColor: Colors.green,
                          isDark: isDark,
                          cardColor: cardColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          count: record.absentDays,
                          label: context.loc.absenceDays,
                          icon: CupertinoIcons.xmark_circle_fill,
                          iconColor: Colors.redAccent,
                          isDark: isDark,
                          cardColor: cardColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Custom Calendar
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Calendar Header
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
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
                                  final isAr = Localizations.localeOf(context).languageCode == 'ar';
                                  setState(() {
                                    if (isAr) {
                                      // في اللغة العربية، السير باتجاه اليسار يعني الانتقال للمستقبل (الشهر القادم)
                                      _focusedDay = DateTime(
                                        _focusedDay.year,
                                        _focusedDay.month + 1,
                                        1,
                                      );
                                    } else {
                                      // في اللغة الإنجليزية، السير باتجاه اليسار يعني الانتقال للماضي (الشهر السابق)
                                      _focusedDay = DateTime(
                                        _focusedDay.year,
                                        _focusedDay.month - 1,
                                        1,
                                      );
                                    }
                                  });
                                },
                              ),
                              Text(
                                DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode).format(_focusedDay),
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
                                  final isAr = Localizations.localeOf(context).languageCode == 'ar';
                                  setState(() {
                                    if (isAr) {
                                      // في اللغة العربية، السير باتجاه اليمين يعني الانتقال للماضي (الشهر السابق)
                                      _focusedDay = DateTime(
                                        _focusedDay.year,
                                        _focusedDay.month - 1,
                                        1,
                                      );
                                    } else {
                                      // في اللغة الإنجليزية، السير باتجاه اليمين يعني الانتقال للمستقبل (الشهر القادم)
                                      _focusedDay = DateTime(
                                        _focusedDay.year,
                                        _focusedDay.month + 1,
                                        1,
                                      );
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCustomCalendarGrid(record, isDark),
                      ],
                    ),
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(context.loc.pleaseSelectStudentToViewAttendance),
                    ),
                  ),

                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildCustomCalendarGrid(AttendanceRecord record, bool isDark) {
    // 5 days: Sat, Sun, Mon, Tue, Wed
    final daysOfWeek = [context.loc.saturday, context.loc.sunday, context.loc.monday, context.loc.tuesday, context.loc.wednesday];

    // Get all days in the month
    final int daysInMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
    ).day;

    List<List<DateTime?>> weeks = [];
    List<DateTime?> currentWeek = List.filled(5, null);

    for (int i = 1; i <= daysInMonth; i++) {
      DateTime date = DateTime(_focusedDay.year, _focusedDay.month, i);
      if (date.weekday == DateTime.thursday ||
          date.weekday == DateTime.friday) {
        continue; // Skip Thu, Fri
      }

      int colIndex;
      if (date.weekday == DateTime.saturday) {
        colIndex = 0;
      } else if (date.weekday == DateTime.sunday) {
        colIndex = 1;
      } else {
        colIndex = date.weekday + 1; // Mon=2, Tue=3, Wed=4
      }

      currentWeek[colIndex] = date;

      if (colIndex == 4 || i == daysInMonth) {
        weeks.add(List.from(currentWeek));
        currentWeek = List.filled(5, null);
      }
    }

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: daysOfWeek
              .map(
                (day) => Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        // Grid
        ...weeks.map(
          (week) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: week.map((date) {
                if (date == null) {
                  return const Expanded(child: SizedBox(height: 40));
                }
                return Expanded(
                  child: Center(
                    child: _buildCalendarCell(date, record, isDark),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCell(
    DateTime day,
    AttendanceRecord record,
    bool isDark,
  ) {
    bool? isPresent;
    for (var entry in record.attendanceData.entries) {
      if (entry.key.year == day.year &&
          entry.key.month == day.month &&
          entry.key.day == day.day) {
        isPresent = entry.value;
        break;
      }
    }

    Color? bgColor;
    Color textColor = isDark ? Colors.white : Colors.black87;

    if (isPresent == true) {
      bgColor = Colors.green.withValues(alpha: 0.15);
      textColor = Colors.green[700]!;
    } else if (isPresent == false) {
      bgColor = Colors.redAccent.withValues(alpha: 0.15);
      textColor = Colors.redAccent[700]!;
    }

    if (isDark && isPresent != null) {
      textColor = isPresent ? Colors.greenAccent : Colors.redAccent;
    }

    final isToday =
        day.year == DateTime.now().year &&
        day.month == DateTime.now().month &&
        day.day == DateTime.now().day;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: isToday && bgColor == null
            ? Border.all(
                color: isDark ? Colors.white54 : const Color(0xFF062A5A),
                width: 1.5,
              )
            : null,
      ),
      child: Center(
        child: Text(
          day.day.toString(),
          style: TextStyle(
            color: textColor,
            fontWeight: isPresent != null || isToday
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChildSelectionCard({
    required Student child,
    required bool isSelected,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
  }) {
    final primaryColor = isDark ? Colors.white : const Color(0xFF062A5A);

    return GestureDetector(
      onTap: () {
        ref.read(currentChildProvider.notifier).setChild(child);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.08) : cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark
                      ? Colors.white12
                      : Colors.grey.withValues(alpha: 0.2)),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isDark || isSelected
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            StudentAvatar(
              photoUrl: child.photoUrl,
              name: child.name,
              size: 36,
              isSelected: isSelected,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                child.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? primaryColor : textColor,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : Colors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required int count,
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.1),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 24),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
