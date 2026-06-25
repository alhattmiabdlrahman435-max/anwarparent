import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/exam_schedule.dart';
import '../../../../core/providers/children_provider.dart';
import '../../../../core/providers/exams_provider.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/extensions/localization_extension.dart';

class ExamsScreen extends ConsumerStatefulWidget {
  const ExamsScreen({super.key});

  @override
  ConsumerState<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends ConsumerState<ExamsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ExamPeriod _selectedPeriod = ExamPeriod.month1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // trigger rebuild to show correct exams for the term
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final primaryColor = isDark ? Colors.white : const Color(0xFF062A5A);
    final unselectedColor = isDark ? Colors.white54 : const Color(0xFF64748B);

    final currentChild = ref.watch(currentChildProvider);

    List<ExamSchedule> studentExams = [];
    if (currentChild != null) {
      studentExams = ref
          .read(examsProvider.notifier)
          .getExamsForStudent(currentChild.id);
    }

    final currentTerm = _tabController.index == 0
        ? ExamTerm.first
        : ExamTerm.second;

    // Find the schedule for the current term and selected period
    final currentSchedule = studentExams
        .where((e) => e.term == currentTerm && e.period == _selectedPeriod)
        .toList();

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          AppSliverHeader(
            title: context.loc.exams,
            showChildSwitcher: true,
          ),
          if (currentChild == null)
            SliverFillRemaining(
              child: Center(child: Text(context.loc.pleaseSelectChildToViewExams)),
            )
          else ...[
            // Terms Tabs
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(26),
                    border: isDark
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          )
                        : null,
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: isDark
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            )
                          : null,
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent, // Removes the grey line
                    labelColor: primaryColor,
                    unselectedLabelColor: unselectedColor,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'GoogleSans',
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'GoogleSans',
                    ),
                    tabs: [
                      Tab(text: context.loc.firstSemester),
                      Tab(text: context.loc.secondSemester),
                    ],
                  ),
                ),
              ),
            ),

            // Periods Selector
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: ExamPeriod.values.length,
                  itemBuilder: (context, index) {
                    final period = ExamPeriod.values[index];
                    final isSelected = period == _selectedPeriod;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        showCheckmark: false,
                        label: Text(
                          context.translateMock(period.displayName),
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.white54
                                      : const Color(0xFF64748B)),
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedPeriod = period);
                          }
                        },
                        selectedColor: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : const Color(0xFF062A5A),
                        backgroundColor: isDark
                            ? Colors.transparent
                            : Colors.white,
                        elevation: isSelected && !isDark ? 4 : 0,
                        shadowColor: primaryColor.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: isSelected
                                ? (isDark
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.transparent)
                                : (isDark
                                      ? Colors.white12
                                      : Colors.grey.shade200),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Exams Content
            SliverPadding(
              padding: const EdgeInsets.only(top: 16),
              sliver: currentSchedule.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.doc_text_search,
                              size: 64,
                              color: isDark ? Colors.white24 : Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.loc.noScheduleAddedFor(context.translateMock(_selectedPeriod.displayName)),
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? Colors.white60
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final schedule = currentSchedule.first;
                          final subject = schedule.subjects[index];
                          return _buildExamSubjectCard(
                            subject,
                            isDark,
                            primaryColor,
                          );
                        },
                        childCount: currentSchedule.isNotEmpty
                            ? currentSchedule.first.subjects.length
                            : 0,
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  String _getSubjectName(BuildContext context, String subjectName) {
    return context.translateMock(subjectName);
  }

  String _getNoteTranslation(BuildContext context, String note) {
    return context.translateMock(note);
  }

  Widget _buildExamSubjectCard(
    ExamSubject subject,
    bool isDark,
    Color primaryColor,
  ) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0xFF062A5A).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Date & Day Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.05),
                      ]
                    : [
                        const Color(0xFF062A5A),
                        const Color(0xFF062A5A).withValues(alpha: 0.85),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: isDark
                  ? Border.all(color: Colors.white.withValues(alpha: 0.1))
                  : null,
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: const Color(0xFF062A5A).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat(
                    'dd',
                    Localizations.localeOf(context).languageCode,
                  ).format(subject.date),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  DateFormat(
                    'MMM',
                    Localizations.localeOf(context).languageCode,
                  ).format(subject.date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat(
                      'EEEE',
                      Localizations.localeOf(context).languageCode,
                    ).format(subject.date),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Subject Info & Note
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getSubjectName(context, subject.subjectName),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.pin_fill,
                      size: 14,
                      color: isDark
                          ? Colors.orange.shade300
                          : const Color(0xFFEA580C),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getNoteTranslation(context, subject.note),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
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
