import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/children_provider.dart';
import '../../../../core/models/student.dart';
import '../../../../core/models/absence_request.dart';
import '../../../../core/providers/absence_requests_provider.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/extensions/localization_extension.dart';

class AbsenceRequestScreen extends ConsumerStatefulWidget {
  const AbsenceRequestScreen({super.key});

  @override
  ConsumerState<AbsenceRequestScreen> createState() =>
      _AbsenceRequestScreenState();
}

class _AbsenceRequestScreenState extends ConsumerState<AbsenceRequestScreen> {
  String? selectedStudentId;
  DateTime? selectedDate = DateTime.now();
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (selectedStudentId == null) {
      _showErrorSnackBar(context.loc.pleaseSelectStudent);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Mocking submission
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      final student = ref.read(childrenProvider).firstWhere((s) => s.id == selectedStudentId);
      final newRequest = AbsenceRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: selectedStudentId!,
        studentName: student.name,
        date: selectedDate ?? DateTime.now(),
        duration: context.loc.language == 'ar' ? 'يوم كامل' : 'Full Day',
        reason: _reasonController.text,
        status: AbsenceRequestStatus.pending,
      );
      ref.read(absenceRequestsProvider.notifier).addRequest(newRequest);

      _showSuccessSnackBar(context.loc.absenceRequestSentSuccessfully);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context.loc.errorSendingAbsenceRequest);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FD);

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          AppSliverHeader(title: context.loc.absenceRequest, showChildSwitcher: false),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel(context, context.loc.children),
                  const SizedBox(height: 12),
                  _studentSelector(context, textTheme, isDark),

                  const SizedBox(height: 30),
                  _buildSectionLabel(context, context.loc.selectDate),
                  const SizedBox(height: 12),
                  _modernDatePicker(textTheme, isDark),

                  const SizedBox(height: 30),
                  _buildSectionLabel(context, context.loc.reasonOptional),
                  const SizedBox(height: 12),
                  _modernReasonField(textTheme, isDark),

                  const SizedBox(height: 40),
                  _submitButton(textTheme),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: isDark
            ? Colors.white.withValues(alpha: 0.8)
            : const Color(0xFF062A5A).withValues(alpha: 0.8),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _studentSelector(
    BuildContext context,
    TextTheme textTheme,
    bool isDark,
  ) {
    final students = ref.watch(childrenProvider);

    if (students.isEmpty) {
      return Center(child: Text(context.loc.noRegisteredStudents));
    }

    // Default to first student if not set
    selectedStudentId ??= students.first.id;

    return Column(
      children: [
        for (var student in students) ...[
          _studentCard(textTheme, student, isDark),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _studentCard(TextTheme textTheme, Student student, bool isDark) {
    final String id = student.id;
    final String name = student.name;
    final bool selected = selectedStudentId == id;
    
    final primaryColor = isDark ? Colors.white : const Color(0xFF062A5A);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return GestureDetector(
      onTap: () => setState(() => selectedStudentId = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? primaryColor.withValues(alpha: 0.08) : cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? primaryColor
                : (isDark
                      ? Colors.white12
                      : Colors.grey.withValues(alpha: 0.2)),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: isDark || selected
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white12 : Colors.grey[100],
              ),
              child: const Icon(
                Icons.person,
                size: 20,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? primaryColor : textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? primaryColor
                      : Colors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: selected
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

  Widget _modernDatePicker(TextTheme textTheme, bool isDark) {
    const primaryColor = Color(0xFF062A5A);
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2023),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: isDark
                    ? const ColorScheme.dark(
                        primary: Colors.white,
                        onPrimary: Color(0xFF0F172A),
                        surface: Color(0xFF1E293B),
                        onSurface: Colors.white,
                      )
                    : const ColorScheme.light(
                        primary: Color(0xFF062A5A),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => selectedDate = picked);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.grey.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: isDark ? Colors.white70 : primaryColor,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                selectedDate != null
                    ? "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}"
                    : context.loc.selectDate,
                style: textTheme.bodyLarge?.copyWith(
                  color: selectedDate != null
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernReasonField(TextTheme textTheme, bool isDark) {
    const primaryColor = Color(0xFF062A5A);
    return TextField(
      controller: _reasonController,
      maxLines: 4,
      cursorColor: primaryColor,
      style: textTheme.bodyLarge?.copyWith(
        color: isDark ? Colors.white : const Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF8F9FA),
        hintText: context.loc.exampleMedicalAppointment,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: isDark
              ? Colors.white60
              : const Color(0xFF64748B).withValues(alpha: 0.6),
        ),
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: primaryColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _submitButton(TextTheme textTheme) {
    const primaryColor = Color(0xFF062A5A);
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF062A5A), Color(0xFF14448A)],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  context.loc.sendAbsenceRequest,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
