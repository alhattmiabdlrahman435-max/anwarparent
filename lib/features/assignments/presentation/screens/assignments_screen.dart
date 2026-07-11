import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher.dart';

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
  int _selectedTab = 0; // 0: Active/Pending, 1: Completed/Submitted

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// يحسب أقرب سبت سابق (أو نفس اليوم إن كان سبتاً)
  DateTime _getStartOfWeek(DateTime date) {
    // Dart weekday: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
    // Saturday = 6, so we subtract (weekday - 6) % 7 days
    int daysToSubtract = (date.weekday - DateTime.saturday) % 7;
    if (daysToSubtract < 0) daysToSubtract += 7;
    final start = date.subtract(Duration(days: daysToSubtract));
    return DateTime(start.year, start.month, start.day);
  }

  /// يُعيد 5 أيام: السبت، الأحد، الإثنين، الثلاثاء، الأربعاء
  List<DateTime> _getWeekDays(DateTime startOfWeek) {
    return List.generate(5, (index) {
      return startOfWeek.add(Duration(days: index));
    });
  }

  Future<void> _openAttachment(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.loc.localeName == 'en'
                  ? 'Could not open attachment'
                  : 'تعذر فتح المرفق',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAssignmentDetails(BuildContext context, Assignment assignment, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Watch assignments state to reflect immediate changes
            final currentAssignments = ref.watch(assignmentsProvider);
            final currentAssignment = currentAssignments.firstWhere(
              (a) => a.id == assignment.id,
              orElse: () => assignment,
            );

            final isPending = currentAssignment.status == 'pending';
            final isOverdue = isPending && currentAssignment.dueDate.isBefore(DateTime.now());

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.only(
                top: 12,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentAssignment.subjectName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF062A5A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentAssignment.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPending
                              ? (isOverdue
                                  ? Colors.red.withValues(alpha: 0.15)
                                  : Colors.amber.withValues(alpha: 0.15))
                              : Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPending
                                ? (isOverdue ? Colors.red : Colors.amber)
                                : Colors.green,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPending
                                  ? (isOverdue ? Icons.error_outline : Icons.pending_actions)
                                  : Icons.check_circle_outline,
                              size: 16,
                              color: isPending
                                  ? (isOverdue ? Colors.red : Colors.amber[800])
                                  : Colors.green[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isPending
                                  ? (isOverdue
                                      ? (isArabic ? 'متأخر' : 'Overdue')
                                      : (isArabic ? 'نشط / معلق' : 'Active / Pending'))
                                  : (isArabic ? 'مكتمل / تم التسليم' : 'Completed / Submitted'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isPending
                                    ? (isOverdue ? Colors.red : Colors.amber[900])
                                    : Colors.green[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'تاريخ النشر' : 'Published Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('yyyy-MM-dd').format(currentAssignment.date),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'تاريخ التسليم' : 'Due Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('yyyy-MM-dd').format(currentAssignment.dueDate),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isOverdue ? Colors.red : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isArabic ? 'تفاصيل الواجب' : 'Assignment Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentAssignment.content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (currentAssignment.attachmentUrl != null) ...[
                    Text(
                      isArabic ? 'المرفقات' : 'Attachments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _openAttachment(context, currentAssignment.attachmentUrl!),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white10 : const Color(0xFFBAE6FD),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              color: isDark ? Colors.red[300] : Colors.red[700],
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic ? 'مرفق شرح الواجب.pdf' : 'Assignment Attachment.pdf',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF0369A1),
                                    ),
                                  ),
                                  Text(
                                    isArabic ? 'انقر للتحميل والعرض' : 'Tap to download and view',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white70 : const Color(0xFF0284C7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.open_in_new,
                              color: isDark ? Colors.white70 : const Color(0xFF0284C7),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (!isPending && currentAssignment.teacherNote != null) ...[
                    Text(
                      isArabic ? 'ملاحظة المعلم وتقييمه' : 'Teacher Note & Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white10 : const Color(0xFFDCFCE7),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber[600],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? 'ملاحظة المعلم:' : 'Teacher Note:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white70 : Colors.green[800],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentAssignment.teacherNote!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final currentChild = ref.watch(currentChildProvider);
    final assignments = ref.watch(assignmentsProvider);

    List<Assignment> dailyAssignments = [];
    if (currentChild != null) {
      dailyAssignments = assignments
          .where(
            (a) =>
                a.studentId == currentChild.id &&
                a.date.year == selectedDate.year &&
                a.date.month == selectedDate.month &&
                a.date.day == selectedDate.day,
          )
          .toList();
    }

    // Split daily assignments into Active vs Completed
    final activeAssignments = dailyAssignments.where((a) => a.status == 'pending').toList();
    final completedAssignments = dailyAssignments.where((a) => a.status == 'submitted').toList();

    final filteredAssignments = _selectedTab == 0 ? activeAssignments : completedAssignments;

    final weekDays = _getWeekDays(_getStartOfWeek(_focusedDate));

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => ref.read(assignmentsProvider.notifier).refresh(),
        child: CustomScrollView(
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
                                final currentStart = _getStartOfWeek(_focusedDate);
                                if (isAr) {
                                  // في اللغة العربية، السير باتجاه اليسار يعني الانتقال للمستقبل (الأسبوع القادم)
                                  _focusedDate = currentStart.add(const Duration(days: 7));
                                } else {
                                  // في اللغة الإنجليزية، السير باتجاه اليسار يعني الانتقال للماضي (الأسبوع السابق)
                                  _focusedDate = currentStart.subtract(const Duration(days: 7));
                                }
                              });
                            },
                          ),
                          Text(
                            DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode)
                                .format(_getStartOfWeek(_focusedDate)),
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
                                final currentStart = _getStartOfWeek(_focusedDate);
                                if (isAr) {
                                  // في اللغة العربية، السير باتجاه اليمين يعني الانتقال للماضي (الأسبوع السابق)
                                  _focusedDate = currentStart.subtract(const Duration(days: 7));
                                } else {
                                  // في اللغة الإنجليزية، السير باتجاه اليمين يعني الانتقال للمستقبل (الأسبوع القادم)
                                  _focusedDate = currentStart.add(const Duration(days: 7));
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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
                            color: Colors.transparent,
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

          // Custom Slide/Tab Selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? (isDark ? Colors.white : const Color(0xFF062A5A))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isArabic ? 'الواجبات النشطة' : 'Active',
                            style: TextStyle(
                              color: _selectedTab == 0
                                  ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                                  : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? (isDark ? Colors.white : const Color(0xFF062A5A))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isArabic ? 'الواجبات المكتملة' : 'Completed',
                            style: TextStyle(
                              color: _selectedTab == 1
                                  ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                                  : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
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
          else if (filteredAssignments.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.doc_text_search,
                      size: 64,
                      color: isDark ? Colors.white38 : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _selectedTab == 0
                            ? (isArabic ? 'لا توجد واجبات نشطة لهذا اليوم' : 'No active assignments for today')
                            : (isArabic ? 'لا توجد واجبات مكتملة لهذا اليوم' : 'No completed assignments for today'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
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
                    assignment: filteredAssignments[index],
                    isDark: isDark,
                  );
                }, childCount: filteredAssignments.length),
              ),
            ),
        ],
        ),
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
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isPending = assignment.status == 'pending';
    final isOverdue = isPending && assignment.dueDate.isBefore(DateTime.now());

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAssignmentDetails(context, assignment, ref),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              assignment.subjectName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (assignment.attachmentUrl != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Icon(
                                Icons.attach_file,
                                size: 16,
                                color: isDark ? Colors.white60 : Colors.grey[600],
                              ),
                            ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPending
                                  ? (isOverdue ? Colors.red : Colors.amber)
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        assignment.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        assignment.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: subTextColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.alarm,
                                size: 14,
                                color: isOverdue ? Colors.red : subTextColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${isArabic ? 'تسليم: ' : 'Due: '}${DateFormat('yyyy-MM-dd').format(assignment.dueDate)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isOverdue ? Colors.red : subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
