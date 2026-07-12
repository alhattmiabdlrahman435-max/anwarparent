import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/class_schedule.dart';
import '../../../../core/providers/children_provider.dart';
import '../../../../core/providers/schedule_provider.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/extensions/localization_extension.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  int _selectedDayIndex = 0;
  bool _isGridView = false;

  final List<String> _daysKeys = [
    'saturday',
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
  ];

  @override
  void initState() {
    super.initState();
    _determineInitialDay();
    Future.microtask(() {
      if (mounted) {
        ref.read(classSchedulesProvider.notifier).refresh();
      }
    });
  }

  void _determineInitialDay() {
    final now = DateTime.now();
    final weekday = now.weekday;

    // Dart Weekday: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
    switch (weekday) {
      case DateTime.saturday:
        _selectedDayIndex = 0;
        break;
      case DateTime.sunday:
        _selectedDayIndex = 1;
        break;
      case DateTime.monday:
        _selectedDayIndex = 2;
        break;
      case DateTime.tuesday:
        _selectedDayIndex = 3;
        break;
      case DateTime.wednesday:
        _selectedDayIndex = 4;
        break;
      default:
        _selectedDayIndex = 0; // Weekend -> Saturday
        break;
    }
  }

  String _getDayTranslation(BuildContext context, String dayKey) {
    switch (dayKey) {
      case 'saturday':
        return context.loc.saturday;
      case 'sunday':
        return context.loc.sunday;
      case 'monday':
        return context.loc.monday;
      case 'tuesday':
        return context.loc.tuesday;
      case 'wednesday':
        return context.loc.wednesday;
      default:
        return '';
    }
  }

  Color _getPeriodColor(int periodNumber) {
    final colors = [
      const Color(0xFF0D9488), // Teal
      const Color(0xFFEA580C), // Orange
      const Color(0xFFD97706), // Amber
      const Color(0xFF2563EB), // Blue
      const Color(0xFFDC2626), // Red
      const Color(0xFF7C3AED), // Purple
      const Color(0xFF16A34A), // Green
    ];
    return colors[(periodNumber - 1) % colors.length];
  }

  bool _isToday(String dayKey) {
    final now = DateTime.now();
    final weekday = now.weekday;
    String todayKey = '';
    switch (weekday) {
      case DateTime.saturday:
        todayKey = 'saturday';
        break;
      case DateTime.sunday:
        todayKey = 'sunday';
        break;
      case DateTime.monday:
        todayKey = 'monday';
        break;
      case DateTime.tuesday:
        todayKey = 'tuesday';
        break;
      case DateTime.wednesday:
        todayKey = 'wednesday';
        break;
    }
    return dayKey == todayKey;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final primaryColor = isDark ? Colors.white : const Color(0xFF062A5A);

    final currentChild = ref.watch(currentChildProvider);
    final allSchedules = ref.watch(classSchedulesProvider);
    ClassSchedule? schedule;

    if (currentChild != null) {
      try {
        schedule = allSchedules.firstWhere(
          (s) => s.studentId == currentChild.id,
        );
      } catch (_) {
        schedule = null;
      }
    }

    final now = DateTime.now();
    final isWeekend =
        now.weekday == DateTime.thursday || now.weekday == DateTime.friday;

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => ref.read(classSchedulesProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            AppSliverHeader(
              title: context.loc.classSchedule,
              showChildSwitcher: true,
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
                child: Icon(
                  _isGridView
                      ? CupertinoIcons.list_bullet
                      : CupertinoIcons.grid,
                  color: isDark ? Colors.white : const Color(0xFF062A5A),
                ),
              ),
            ),
            if (currentChild == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      context.loc.pleaseSelectChildToViewSchedule,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 16,
                        color: subTextColor,
                      ),
                    ),
                  ),
                ),
              )
            else if (schedule == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      context.loc.noScheduleAddedFor(''),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'GoogleSans',
                        fontSize: 16,
                        color: subTextColor,
                      ),
                    ),
                  ),
                ),
              )
            else ...[
              // Optional Weekend Notice
              if (isWeekend && !_isGridView)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.info,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.loc.weekendNote,
                            style: const TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (!_isGridView) ...[
                // Day Tabs (Saturday to Wednesday)
                SliverToBoxAdapter(
                  child: Container(
                    height: 54,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _daysKeys.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final dayKey = _daysKeys[index];
                        final isSelected = index == _selectedDayIndex;
                        final isTodayDay = _isToday(dayKey);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDayIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                        ? Colors.white
                                        : const Color(0xFF062A5A))
                                  : (isDark
                                        ? const Color(0xFF1E293B)
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? (isDark
                                          ? Colors.white
                                          : const Color(0xFF062A5A))
                                    : (isTodayDay
                                          ? (isDark
                                                ? Colors.white30
                                                : const Color(
                                                    0xFF062A5A,
                                                  ).withValues(alpha: 0.3))
                                          : (isDark
                                                ? Colors.white10
                                                : Colors.grey.withValues(
                                                    alpha: 0.2,
                                                  ))),
                                width: 1.5,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color:
                                        (isDark
                                                ? Colors.black
                                                : const Color(0xFF062A5A))
                                            .withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                children: [
                                  Text(
                                    _getDayTranslation(context, dayKey),
                                    style: TextStyle(
                                      fontFamily: 'GoogleSans',
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? (isDark
                                                ? const Color(0xFF0F172A)
                                                : Colors.white)
                                          : textColor,
                                    ),
                                  ),
                                  if (isTodayDay) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (isDark
                                                  ? const Color(0xFF0F172A)
                                                  : Colors.white)
                                            : Colors.teal,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Timeline List View
                Builder(
                  builder: (context) {
                    final selectedDayKey = _daysKeys[_selectedDayIndex];
                    final daySchedule = schedule!.days.firstWhere(
                      (d) => d.dayKey == selectedDayKey,
                      orElse: () =>
                          ClassScheduleDay(dayKey: selectedDayKey, periods: []),
                    );

                    if (daySchedule.periods.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            context.loc.noScheduleAddedFor(
                              _getDayTranslation(context, selectedDayKey),
                            ),
                            style: TextStyle(
                              fontFamily: 'GoogleSans',
                              color: subTextColor,
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final period = daySchedule.periods[index];
                          final color = _getPeriodColor(period.periodNumber);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.2 : 0.05,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    // Accent color indicator line
                                    Container(width: 6, color: color),
                                    const SizedBox(width: 16),
                                    // Period badge
                                    Container(
                                      width: 40,
                                      height: 40,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          period.periodNumber.toString(),
                                          style: TextStyle(
                                            fontFamily: 'GoogleSans',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Subject & Teacher details
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              context.translateMock(
                                                period.subjectName,
                                              ),
                                              style: TextStyle(
                                                fontFamily: 'GoogleSans',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  CupertinoIcons.person,
                                                  size: 14,
                                                  color: subTextColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  context.translateMock(
                                                    period.teacherName,
                                                  ),
                                                  style: TextStyle(
                                                    fontFamily: 'GoogleSans',
                                                    fontSize: 12,
                                                    color: subTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Timing badge
                                    Container(
                                      margin: const EdgeInsetsDirectional.only(
                                        end: 16,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white10
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            CupertinoIcons.clock,
                                            size: 12,
                                            color: subTextColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${period.startTime} - ${period.endTime}',
                                            style: TextStyle(
                                              fontFamily: 'GoogleSans',
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: subTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }, childCount: daySchedule.periods.length),
                      ),
                    );
                  },
                ),
              ] else ...[
                // Grid View Table
                SliverPadding(
                  padding: const EdgeInsets.all(20.0),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.05,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isDark
                              ? Colors.white10
                              : Colors.grey.withValues(alpha: 0.1),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(),
                          child: DataTable(
                            columnSpacing: 24,
                            headingRowColor: WidgetStateProperty.all(
                              isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(
                                      0xFF062A5A,
                                    ).withValues(alpha: 0.05),
                            ),
                            dataRowColor: WidgetStateProperty.all(cardBgColor),
                            headingTextStyle: TextStyle(
                              fontFamily: 'GoogleSans',
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontSize: 14,
                            ),
                            dataTextStyle: TextStyle(
                              fontFamily: 'GoogleSans',
                              color: textColor,
                              fontSize: 13,
                            ),
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                color: isDark
                                    ? Colors.white10
                                    : Colors.grey.withValues(alpha: 0.1),
                                width: 1,
                              ),
                              verticalInside: BorderSide(
                                color: isDark
                                    ? Colors.white10
                                    : Colors.grey.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            columns: [
                              DataColumn(
                                label: Text(context.loc.home),
                              ), // The "Day" column header
                              ...List.generate(
                                7,
                                (i) => DataColumn(
                                  label: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(context.loc.period(i + 1)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            rows: _daysKeys.map((dayKey) {
                              final daySchedule = schedule!.days.firstWhere(
                                (d) => d.dayKey == dayKey,
                                orElse: () => ClassScheduleDay(
                                  dayKey: dayKey,
                                  periods: [],
                                ),
                              );

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      _getDayTranslation(context, dayKey),
                                      style: const TextStyle(
                                        fontFamily: 'GoogleSans',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ...List.generate(7, (periodIdx) {
                                    final periodNum = periodIdx + 1;
                                    final period = daySchedule.periods
                                        .firstWhere(
                                          (p) => p.periodNumber == periodNum,
                                          orElse: () => const ClassPeriod(
                                            periodNumber: 0,
                                            subjectName: '',
                                            startTime: '',
                                            endTime: '',
                                            teacherName: '',
                                          ),
                                        );

                                    if (period.periodNumber == 0) {
                                      return const DataCell(
                                        Center(child: Text('-')),
                                      );
                                    }

                                    return DataCell(
                                      Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              context.translateMock(
                                                period.subjectName,
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${period.startTime}-${period.endTime}',
                                              style: TextStyle(
                                                fontFamily: 'GoogleSans',
                                                fontSize: 10,
                                                color: subTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
