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
import '../widgets/assignment_attachments.dart';
import '../../../../core/services/homework_reminder_service.dart';


/// حالات الخادم التي تعني أن الطالب سلّم الواجب (كما في لوحة التحكم وتطبيق المعلم)
bool isSubmittedStatus(String status) => status == 'submitted' || status == 'submitted_late';

/// انتهى موعد التسليم: بعد نهاية يوم التسليم كاملاً (موعد التسليم تاريخ بدون وقت)
bool isPastDueDate(DateTime dueDate) {
  final endOfDueDay = DateTime(dueDate.year, dueDate.month, dueDate.day).add(const Duration(days: 1));
  return DateTime.now().isAfter(endOfDueDay);
}

class AssignmentsScreen extends ConsumerStatefulWidget {
  /// من الإشعار: رقم الواجب (aid) أو رقم نسخة الطالب (id)، ويوم نشر الواجب (YYYY-MM-DD)
  final String? initialAssignmentId;
  final String? initialSubmissionId;
  final String? initialDate;

  const AssignmentsScreen({
    super.key,
    this.initialAssignmentId,
    this.initialSubmissionId,
    this.initialDate,
  });

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  /// يوم محدد اختاره ولي الأمر من التقويم (null = كل الأيام، وهو الافتراضي)
  DateTime? _dayFilter;
  int _selectedTab = 0; // 0: Active/Pending, 1: Completed/Submitted

  /// فتح الواجب القادم من الإشعار مرة واحدة فقط
  bool _deepLinkHandled = false;

  bool get _hasDeepLink =>
      (widget.initialAssignmentId?.isNotEmpty ?? false) || (widget.initialSubmissionId?.isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(assignmentsProvider.notifier).refresh();
      }
    });
  }

  /// من الإشعار: اختيار الابن الصحيح، والانتقال ليوم الواجب وتبويبه، ثم فتح تفاصيله
  void _handleDeepLink(List<Assignment> assignments, dynamic currentChild) {
    if (_deepLinkHandled || !_hasDeepLink || assignments.isEmpty) return;
    final aid = widget.initialAssignmentId ?? '';
    final sid = widget.initialSubmissionId ?? '';
    final matches = assignments
        .where((a) => (aid.isNotEmpty && a.assignmentId == aid) || (sid.isNotEmpty && a.id == sid))
        .toList();
    if (matches.isEmpty) return; // ربما لم تُحمَّل بعد؛ نعيد المحاولة عند وصول البيانات
    _deepLinkHandled = true;

    // إن كان الواجب لأكثر من ابن في نفس الصف نفضّل الابن المختار حالياً
    final target = matches.firstWhere(
      (a) => currentChild != null && a.studentId == currentChild.id,
      orElse: () => matches.first,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final kids = ref.read(childrenProvider);
      final kid = kids.where((k) => k.id == target.studentId).firstOrNull;
      if (kid != null && (currentChild == null || currentChild.id != kid.id)) {
        ref.read(currentChildProvider.notifier).setChild(kid);
      }
      setState(() {
        _dayFilter = null;
        _selectedTab = isSubmittedStatus(target.status) ? 1 : 0;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAssignmentDetails(context, target, ref);
      });
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

            final isPending = !isSubmittedStatus(currentAssignment.status);
            final isOverdue = isPending && isPastDueDate(currentAssignment.dueDate);

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
              // قابل للتمرير حتى لا يتجاوز الشاشة عند وجود نص طويل وعدة صور
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: SingleChildScrollView(
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
                                      // "متأخر" وحدها كانت تُفهم أنها "سلّم متأخراً"
                                      ? (isArabic ? 'لم يُسلَّم وانتهى الموعد' : 'Not submitted, overdue')
                                      : (isArabic ? 'لم يُسلَّم بعد' : 'Not submitted'))
                                  : (currentAssignment.status == 'submitted_late'
                                      ? (isArabic ? 'سلّم متأخراً' : 'Submitted late')
                                      : (isArabic ? 'تم التسليم' : 'Submitted')),
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
                  if (currentAssignment.attachmentUrls.isNotEmpty) ...[
                    Text(
                      isArabic ? 'المرفقات' : 'Attachments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AssignmentAttachments(
                      urls: currentAssignment.attachmentUrls,
                      isDark: isDark,
                      isArabic: isArabic,
                      onOpenFile: (url) => _openAttachment(context, url),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (currentAssignment.teacherNote != null && currentAssignment.teacherNote!.trim().isNotEmpty) ...[
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
                  // تذكير مخصص لهذا الواجب (غير مسلَّم وموعده لم ينتهِ)
                  if (HomeworkReminderService.isReminderEligible(currentAssignment))
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.alarm_add_rounded),
                        label: const Text('تذكيري في وقت محدد'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          final kids = ref.read(childrenProvider);
                          final childName = kids
                              .where((c) => c.id == currentAssignment.studentId)
                              .map((c) => c.name)
                              .firstOrNull;
                          _pickHomeworkReminder(context, currentAssignment, childName ?? '');
                        },
                      ),
                    ),
                ],
              ),
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
    final children = ref.watch(childrenProvider);
    final assignments = ref.watch(assignmentsProvider);
    _handleDeepLink(assignments, currentChild);

    // كل واجبات الابن المختار (كل الأيام)، أو يوم محدد إن اختاره ولي الأمر من التقويم
    final childAssignments = currentChild == null
        ? <Assignment>[]
        : (assignments
            .where((a) =>
                a.studentId == currentChild.id &&
                (_dayFilter == null || isSameDay(a.date, _dayFilter!)))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date)));

    // قاعدة واحدة: المسلَّم = "تم التسليم" أو "سلّم متأخراً"، وكل ما عداه لم يُسلَّم بعد
    final completedAssignments = childAssignments.where((a) => isSubmittedStatus(a.status)).toList();
    final activeAssignments = childAssignments.where((a) => !isSubmittedStatus(a.status)).toList();
    final filteredAssignments = _selectedTab == 0 ? activeAssignments : completedAssignments;

    // عدد الواجبات التي لم تُسلَّم لكل ابن (كل الأيام) — يظهر بجانب اسمه
    int unsubmittedFor(String studentId) =>
        assignments.where((a) => a.studentId == studentId && !isSubmittedStatus(a.status)).length;

    // عناصر القائمة: عنوان لكل يوم ثم واجبات ذلك اليوم
    final listItems = <Object>[];
    DateTime? lastDay;
    for (final a in filteredAssignments) {
      final day = DateTime(a.date.year, a.date.month, a.date.day);
      if (lastDay == null || !isSameDay(lastDay, day)) {
        listItems.add(day);
        lastDay = day;
      }
      listItems.add(a);
    }

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
            // اختيار الابن من الشريط أدناه (مع عدد واجباته غير المسلَّمة)
            AppSliverHeader(title: context.loc.schoolAssignments, showChildSwitcher: false),

            if (children.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    children: [
                      for (final kid in children)
                        _buildChildChip(
                          name: kid.name.trim().split(RegExp(r'\s+')).first,
                          count: unsubmittedFor(kid.id),
                          selected: currentChild?.id == kid.id,
                          isDark: isDark,
                          onTap: () => ref.read(currentChildProvider.notifier).setChild(kid),
                        ),
                    ],
                  ),
                ),
              ),

            // التبويبان مع عدد كل منهما + زر التقويم (اختياري لعرض يوم محدد)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            _buildTab(
                              0,
                              isArabic
                                  ? 'لم تُسلَّم بعد (${activeAssignments.length})'
                                  : 'Not submitted (${activeAssignments.length})',
                              isDark,
                            ),
                            _buildTab(
                              1,
                              isArabic
                                  ? 'تم التسليم (${completedAssignments.length})'
                                  : 'Submitted (${completedAssignments.length})',
                              isDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: IconButton.filledTonal(
                        tooltip: isArabic ? 'عرض يوم محدد' : 'Show a specific day',
                        onPressed: _pickDayFilter,
                        icon: const Icon(CupertinoIcons.calendar),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_dayFilter != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: InputChip(
                      avatar: const Icon(CupertinoIcons.calendar, size: 16),
                      label: Text(
                        '${isArabic ? 'واجبات يوم' : 'Homework of'} ${DateFormat('EEEE d MMMM', isArabic ? 'ar' : 'en').format(_dayFilter!)}',
                      ),
                      onDeleted: () => setState(() => _dayFilter = null),
                      deleteButtonTooltipMessage: isArabic ? 'كل الأيام' : 'All days',
                    ),
                  ),
                ),
              ),

            // توضيح معنى التبويبين لولي الأمر
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.info_circle, size: 14, color: isDark ? Colors.white54 : Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isArabic
                            ? 'ينتقل الواجب إلى «تم التسليم» عندما يسجّل المعلم أن ابنكم سلّمه.'
                            : 'An assignment moves to "Submitted" once the teacher records that your child handed it in.',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

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
                              ? (isArabic ? 'لا توجد واجبات لم تُسلَّم' : 'No unsubmitted homework')
                              : (isArabic ? 'لا توجد واجبات تم تسليمها' : 'No submitted homework'),
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
                    final item = listItems[index];
                    if (item is DateTime) {
                      return _buildDayHeader(item, isDark, isArabic);
                    }
                    return _buildAssignmentCard(
                      assignment: item as Assignment,
                      isDark: isDark,
                    );
                  }, childCount: listItems.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// اسم الابن في الشريط العلوي مع عدد واجباته التي لم تُسلَّم
  Widget _buildChildChip({
    required String name,
    required int count,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    const brand = Color(0xFF062A5A);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? brand : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? brand : (isDark ? Colors.white12 : Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF334155)),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, bool isDark) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: selected ? (isDark ? Colors.white : const Color(0xFF062A5A)) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                  : (isDark ? Colors.white70 : Colors.black87),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  /// عنوان اليوم فوق واجباته: "اليوم" / "أمس" / "الأربعاء 11 نوفمبر"
  Widget _buildDayHeader(DateTime day, bool isDark, bool isArabic) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    String label;
    if (isSameDay(day, today)) {
      label = isArabic ? 'اليوم' : 'Today';
    } else if (isSameDay(day, today.subtract(const Duration(days: 1)))) {
      label = isArabic ? 'أمس' : 'Yesterday';
    } else {
      label = DateFormat('EEEE d MMMM yyyy', isArabic ? 'ar' : 'en').format(day);
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Row(
        children: [
          Icon(CupertinoIcons.calendar_today, size: 16, color: isDark ? Colors.white60 : const Color(0xFF062A5A)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : const Color(0xFF062A5A),
            ),
          ),
        ],
      ),
    );
  }

  /// عرض واجبات يوم محدد (اختياري) — الافتراضي كل الأيام
  Future<void> _pickDayFilter() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dayFilter ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      helpText: 'اختر يوم نشر الواجب',
    );
    if (picked != null && mounted) {
      setState(() => _dayFilter = picked);
    }
  }

  Widget _buildAssignmentCard({
    required Assignment assignment,
    required bool isDark,
  }) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isPending = !isSubmittedStatus(assignment.status);
    final isOverdue = isPending && isPastDueDate(assignment.dueDate);

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
                          if (assignment.attachmentUrls.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    assignment.attachmentUrls.any(isImageAttachmentUrl)
                                        ? Icons.photo_outlined
                                        : Icons.attach_file,
                                    size: 16,
                                    color: isDark ? Colors.white60 : Colors.grey[600],
                                  ),
                                  if (assignment.attachmentUrls.length > 1)
                                    Text(
                                      '${assignment.attachmentUrls.length}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white60 : Colors.grey[600],
                                      ),
                                    ),
                                ],
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
                      if (assignment.teacherNote != null && assignment.teacherNote!.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? Colors.white12 : const Color(0xFFDCFCE7),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star_rounded, color: Colors.amber[600], size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${isArabic ? "ملاحظة المعلم: " : "Teacher Note: "}${assignment.teacherNote!}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.green[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                                assignment.isEdited
                                    ? '${DateFormat('yyyy-MM-dd').format(assignment.date)} · ${isArabic ? 'معدَّل' : 'Edited'}'
                                    : DateFormat('yyyy-MM-dd').format(assignment.date),
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

/// تذكير مخصص: يختار ولي الأمر يوماً (من اليوم حتى موعد التسليم) ثم وقتاً، فيُجدول تذكيراً لهذا الواجب.
Future<void> _pickHomeworkReminder(BuildContext context, Assignment assignment, String childName) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(assignment.dueDate.year, assignment.dueDate.month, assignment.dueDate.day);
  if (due.isBefore(today)) return;

  final existing = await HomeworkReminderService.instance.customReminderFor(assignment.id);
  if (!context.mounted) return;

  var initialDate = existing != null
      ? DateTime(existing.year, existing.month, existing.day)
      : due.subtract(const Duration(days: 1));
  if (initialDate.isBefore(today)) initialDate = today;
  if (initialDate.isAfter(due)) initialDate = due;

  final date = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: today,
    lastDate: due,
    helpText: 'اختر يوم التذكير',
  );
  if (date == null || !context.mounted) return;

  final time = await showTimePicker(
    context: context,
    initialTime: existing != null
        ? TimeOfDay.fromDateTime(existing)
        : const TimeOfDay(hour: 19, minute: 0),
    helpText: 'اختر وقت التذكير',
  );
  if (time == null || !context.mounted) return;

  final at = DateTime(date.year, date.month, date.day, time.hour, time.minute);
  final messenger = ScaffoldMessenger.of(context);
  if (!at.isAfter(DateTime.now())) {
    messenger.showSnackBar(
      const SnackBar(content: Text('اختر وقتاً لاحقاً للوقت الحالي')),
    );
    return;
  }

  final ok = await HomeworkReminderService.instance.scheduleCustom(
    assignment: assignment,
    at: at,
    childName: childName,
  );
  if (!context.mounted) return;

  String dayLabel;
  try {
    dayLabel = DateFormat('EEEE d/M', 'ar').format(at);
  } catch (_) {
    dayLabel = DateFormat('yyyy-MM-dd').format(at);
  }
  final h12 = at.hour % 12 == 0 ? 12 : at.hour % 12;
  final timeLabel = '$h12:${at.minute.toString().padLeft(2, '0')} ${at.hour < 12 ? 'ص' : 'م'}';

  // نغلق نافذة التفاصيل حتى لا تحجب رسالة التأكيد
  if (ok) Navigator.of(context).pop();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        ok
            ? 'سيتم تذكيرك يوم $dayLabel الساعة $timeLabel'
            : 'تعذّرت جدولة التذكير، تأكد من السماح بالإشعارات للتطبيق',
      ),
      backgroundColor: ok ? null : Colors.red,
    ),
  );
}
