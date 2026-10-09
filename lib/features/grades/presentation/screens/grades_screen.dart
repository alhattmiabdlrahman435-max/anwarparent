import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/providers/children_provider.dart';
import '../../../../core/providers/grades_provider.dart';
import '../../../../core/models/grade.dart';
import '../../../../core/models/student.dart';
import '../../../../core/extensions/localization_extension.dart';

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  int _selectedTerm = 1;
  int _viewMode = 0; // 0: تفصيل المواد, 1: إشعار نتيجة منتصف العام

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(gradesProvider.notifier).refresh();
      }
    });
  }

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

    final gradesStatus = ref.watch(gradesStatusProvider);
    final isFromCache = gradesStatus['isFromCache'] == true;
    final lastUpdated = gradesStatus['lastUpdated'] as DateTime?;

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

          // Cache status banner
          if (isFromCache)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF332A00) : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF785E00) : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.cloud_download,
                        size: 18,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          lastUpdated != null
                              ? 'عرض مؤقت من الذاكرة المحلية (${lastUpdated.hour.toString().padLeft(2, '0')}:${lastUpdated.minute.toString().padLeft(2, '0')}) - جارٍ الاتصال بالسيرفر...'
                              : 'عرض مؤقت من الذاكرة المحلية - جارٍ الاتصال بالسيرفر...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

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

          // View Mode Selector (Only shown for Term 1 when grades exist)
          if (_selectedTerm == 1 && currentChild != null && subjects.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _viewMode = 0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _viewMode == 0
                                  ? const Color(0xFF062A5A)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.list_bullet,
                                  size: 16,
                                  color: _viewMode == 0
                                      ? Colors.white
                                      : (isDark ? Colors.white54 : Colors.grey[600]),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'تفصيل المواد 📊',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _viewMode == 0 ? FontWeight.bold : FontWeight.w600,
                                    color: _viewMode == 0
                                        ? Colors.white
                                        : (isDark ? Colors.white54 : Colors.grey[600]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _viewMode = 1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _viewMode == 1
                                  ? const Color(0xFF062A5A)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.doc_plaintext,
                                  size: 16,
                                  color: _viewMode == 1
                                      ? Colors.white
                                      : (isDark ? Colors.white54 : Colors.grey[600]),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'إشعار النتيجة 📜',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _viewMode == 1 ? FontWeight.bold : FontWeight.w600,
                                    color: _viewMode == 1
                                        ? Colors.white
                                        : (isDark ? Colors.white54 : Colors.grey[600]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
          else if (_selectedTerm == 1 && _viewMode == 1)
            SliverToBoxAdapter(
              child: _buildMidtermReportCard(
                student: currentChild,
                subjects: subjects,
                isDark: isDark,
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
                          textDirection: TextDirection.ltr,
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
                          Flexible(
                            child: Text(
                              context.loc.totalYearlyGrades,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: gradeColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${subject.yearlyTotal.toStringAsFixed(1).replaceAll('.0', '')} / 100',
                            textDirection: TextDirection.ltr,
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
              Flexible(
                child: Text(
                  month.monthName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${month.total.toStringAsFixed(0)} / 100',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF062A5A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGradeDetailItem(context.loc.homework, month.homework, 15, subTextColor),
                const SizedBox(width: 8),
                _buildGradeDetailItem(
                  context.loc.attendanceBehavior,
                  month.attendance,
                  15,
                  subTextColor,
                ),
                const SizedBox(width: 8),
                _buildGradeDetailItem(context.loc.behavior, month.behavior, 10, subTextColor),
                const SizedBox(width: 8),
                _buildGradeDetailItem(context.loc.oral, month.oral, 10, subTextColor),
                const SizedBox(width: 8),
                _buildGradeDetailItem(context.loc.written, month.written, 50, subTextColor),
              ],
            ),
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
          textDirection: TextDirection.ltr,
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
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMidtermReportCard({
    required Student student,
    required List<SubjectGrade> subjects,
    required bool isDark,
  }) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final primaryColor = const Color(0xFF062A5A);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    // Calculate totals for Term 1 (outcome + termExam)
    double totalObtained = 0.0;
    final int subjectCount = subjects.length;

    for (final s in subjects) {
      totalObtained += s.term1.total;
    }

    final double maxTotal = subjectCount * 50.0;
    final double overallPercentage = maxTotal > 0 ? (totalObtained / maxTotal) * 100 : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 1.5),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: School Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? primaryColor.withValues(alpha: 0.3)
                  : primaryColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.doc_plaintext,
                      color: isDark ? Colors.white : primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'رياض ومدارس أنوار العُلا الدولية النموذجية',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : primaryColor,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'إشعار نتيجة منتصف العام - الفصل الدراسي الأول',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Student Info Block
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اسم الطالب:',
                        style: TextStyle(fontSize: 11, color: subTextColor, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        student.name,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: borderColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الصف / المرحلة:',
                        style: TextStyle(fontSize: 11, color: subTextColor, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        student.grade.isNotEmpty ? student.grade : 'غير محدد',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'المادة',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'المحصلة (20)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'النهائي (30)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'المجموع (50)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'التقدير',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: subjects.asMap().entries.map((entry) {
                final idx = entry.key;
                final sub = entry.value;
                final term1 = sub.term1;
                final isEven = idx % 2 == 0;
                final rowBg = isEven
                    ? (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.withValues(alpha: 0.03))
                    : Colors.transparent;
                final appreciation = _getGradeAppreciation(term1.total);
                final appreciationColor = _getGradeAppreciationColor(term1.total, isDark);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  decoration: BoxDecoration(
                    color: rowBg,
                    border: idx < subjects.length - 1
                        ? Border(bottom: BorderSide(color: borderColor.withValues(alpha: 0.5)))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          sub.subjectName,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          term1.outcome.toStringAsFixed(1).replaceAll('.0', ''),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          term1.termExam.toStringAsFixed(1).replaceAll('.0', ''),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          term1.total.toStringAsFixed(1).replaceAll('.0', ''),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          appreciation,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: appreciationColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Total Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFF062A5A), const Color(0xFF0B4386)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المجموع العام لمنتصف العام',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalObtained.toStringAsFixed(1).replaceAll('.0', '')} / ${maxTotal.toStringAsFixed(0)}',
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'النسبة المئوية',
                        style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${overallPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: borderColor),
          const SizedBox(height: 12),

          // Official Footer Signatures
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSignatureItem('مربي الفصل', subTextColor),
              _buildSignatureItem('المرشد الطلابي', subTextColor),
              _buildSignatureItem('مدير المدرسة / الختم', subTextColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureItem(String title, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '.......................',
          style: TextStyle(
            fontSize: 10,
            color: color.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  String _getGradeAppreciation(double totalOutOf50) {
    final double percentage = totalOutOf50 * 2;
    if (percentage >= 90) return 'ممتاز';
    if (percentage >= 80) return 'جيد جداً';
    if (percentage >= 65) return 'جيد';
    if (percentage >= 50) return 'مقبول';
    return 'ضعيف';
  }

  Color _getGradeAppreciationColor(double totalOutOf50, bool isDark) {
    final double percentage = totalOutOf50 * 2;
    if (percentage >= 90) return isDark ? Colors.greenAccent : const Color(0xFF059669);
    if (percentage >= 80) return isDark ? Colors.lightBlueAccent : const Color(0xFF0284C7);
    if (percentage >= 65) return isDark ? Colors.amberAccent : const Color(0xFFD97706);
    if (percentage >= 50) return isDark ? Colors.orangeAccent : const Color(0xFFEA580C);
    return isDark ? Colors.redAccent : const Color(0xFFDC2626);
  }
}

