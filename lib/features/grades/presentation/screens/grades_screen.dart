import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/providers/children_provider.dart';
import '../../../../core/providers/grades_provider.dart';
import '../../../../core/models/grade.dart';
import '../../../../core/extensions/localization_extension.dart';

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  int _selectedTerm = 1;

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'function':
        return CupertinoIcons.function;
      case 'lab_flask':
        return CupertinoIcons.lab_flask;
      case 'book':
        return CupertinoIcons.book;
      default:
        return CupertinoIcons.doc_text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    final currentChild = ref.watch(currentChildProvider);
    final grades = ref.watch(gradesProvider);
    List<SubjectGrade> subjects = [];
    if (currentChild != null) {
      subjects = grades.where((g) => g.studentId == currentChild.id).toList();
    }

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => ref.read(gradesProvider.notifier).refresh(),
        child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          AppSliverHeader(title: context.loc.gradesAndAnalytics, showChildSwitcher: true),

          // Term Selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                  children: [
                    _buildTermTab(1, context.loc.firstSemester, isDark),
                    _buildTermTab(2, context.loc.secondSemester, isDark),
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
          else if (subjects.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.doc_chart,
                      size: 64,
                      color: isDark ? Colors.white38 : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.loc.noGradesYet,
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildExpandableSubjectCard(
                    subject: subjects[index],
                    isDark: isDark,
                  );
                }, childCount: subjects.length),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
       ),
      ),
    );
  }

  Widget _buildTermTab(int term, String label, bool isDark) {
    final isSelected = _selectedTerm == term;
    final primaryColor = const Color(0xFF062A5A);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTerm = term;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white54 : Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSubjectCard({
    required SubjectGrade subject,
    required bool isDark,
  }) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    final termData = _selectedTerm == 1 ? subject.term1 : subject.term2;

    // Calculate percentage (total is out of 50 per term)
    // to show as percentage out of 100%, we multiply by 2.
    final percentage = (termData.total * 2)
        .toStringAsFixed(1)
        .replaceAll('.0', '');

    final bool isHigh = termData.total >= 40; // 80% and above
    final gradeColor = isHigh
        ? (isDark ? Colors.greenAccent : Colors.green)
        : (isDark ? Colors.orangeAccent : Colors.orange);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: isDark ? Colors.white : const Color(0xFF062A5A),
          collapsedIconColor: isDark ? Colors.white70 : Colors.grey[400],
          tilePadding: const EdgeInsets.all(16),
          title: Row(
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
                  _getIconData(subject.iconName),
                  color: isDark ? Colors.white : const Color(0xFF062A5A),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  subject.subjectName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: gradeColor,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Months
                  _buildMonthRow(
                    termData.month1,
                    isDark,
                    textColor,
                    subTextColor,
                  ),
                  const SizedBox(height: 12),
                  _buildMonthRow(
                    termData.month2,
                    isDark,
                    textColor,
                    subTextColor,
                  ),
                  const SizedBox(height: 12),
                  _buildMonthRow(
                    termData.month3,
                    isDark,
                    textColor,
                    subTextColor,
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Outcomes and Exams
                  _buildSummaryRow(
                    context.loc.finalResultNote,
                    termData.outcome.toStringAsFixed(2),
                    '20',
                    textColor,
                    subTextColor,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    context.loc.midTermFinalExam,
                    termData.termExam.toStringAsFixed(1).replaceAll('.0', ''),
                    '30',
                    textColor,
                    subTextColor,
                  ),
                  const SizedBox(height: 16),

                  // Total Term
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFF062A5A).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.loc.totalTermGrades,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF062A5A),
                          ),
                        ),
                        Text(
                          '${termData.total.toStringAsFixed(1).replaceAll('.0', '')} / 50',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF062A5A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Total Year (Term 1 + Term 2)
                  if (subject.term1.total > 0 && subject.term2.total > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: gradeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: gradeColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.loc.totalYearlyGrades,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: gradeColor,
                            ),
                          ),
                          Text(
                            '${subject.yearlyTotal.toStringAsFixed(1).replaceAll('.0', '')} / 100',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: gradeColor,
                            ),
                          ),
                        ],
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

  Widget _buildMonthRow(
    MonthlyGrade month,
    bool isDark,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.02)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                month.monthName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                '${month.total.toStringAsFixed(0)} / 100',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF062A5A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGradeDetailItem(context.loc.homework, month.homework, 15, subTextColor),
              _buildGradeDetailItem(
                context.loc.attendanceBehavior,
                month.attendance,
                15,
                subTextColor,
              ),
              _buildGradeDetailItem(context.loc.behavior, month.behavior, 10, subTextColor),
              _buildGradeDetailItem(context.loc.oral, month.oral, 10, subTextColor),
              _buildGradeDetailItem(context.loc.written, month.written, 50, subTextColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradeDetailItem(
    String label,
    double grade,
    int maxGrade,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${grade.toStringAsFixed(0)}/$maxGrade',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String grade,
    String maxGrade,
    Color textColor,
    Color subTextColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: subTextColor,
            ),
          ),
        ),
        Text(
          '$grade / $maxGrade',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
