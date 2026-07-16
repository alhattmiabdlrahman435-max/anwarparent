import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/exam_schedule.dart';
import '../network/api_client.dart';

part 'exams_provider.g.dart';

@Riverpod(keepAlive: true)
class Exams extends _$Exams {
  @override
  List<ExamSchedule> build() {
    _fetch();
    return [];
  }

  Future<void> _fetch() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('exam-schedules');
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['exam_schedules'] ?? [];
        final parsed = list.map((item) {
          final String title = item['title'] ?? '';
          
          // تحديد الفصل الدراسي بشكل مرن ودقيق
          final termStr = item['term']?.toString() ?? '';
          ExamTerm term = ExamTerm.first;
          if (termStr == '2' || 
              termStr.toLowerCase() == 'second' || 
              termStr.toLowerCase() == 'term2' ||
              termStr.contains('الثاني') || 
              termStr.contains('الترم الثاني') || 
              termStr.contains('الفصل الثاني')) {
            term = ExamTerm.second;
          }

          // تحديد الفترة الدراسية للاختبار
          ExamPeriod period = ExamPeriod.month1;
          if (title.contains('نهاية') || title.contains('النهائي')) {
            period = ExamPeriod.finalExam;
          } else if (title.contains('الثالث')) {
            period = ExamPeriod.month3;
          } else if (title.contains('الثاني')) {
            period = ExamPeriod.month2;
          }

          final List<dynamic> subjectsJson = item['subjects'] ?? [];
          final List<ExamSubject> subjects = subjectsJson.map<ExamSubject>((sub) {
            return ExamSubject(
              subjectName: sub['name_ar'] ?? sub['name'] ?? '',
              date: DateTime.tryParse(sub['exam_date']?.toString() ?? '') ?? DateTime.now(),
              time: sub['exam_time']?.toString() ?? '',
              note: sub['note'] ?? '',
            );
          }).toList();

          return ExamSchedule(
            id: item['id']?.toString() ?? '',
            studentId: item['class_id']?.toString() ?? '1',
            term: term,
            period: period,
            subjects: subjects,
          );
        }).toList();
        if (ref.mounted) state = parsed;
      } else {
        if (ref.mounted) state = [];
      }
    } catch (e) {
      debugPrint('Error fetching exam schedules: $e');
      if (ref.mounted) state = [];
    }
  }

  Future<void> refresh() async {
    await _fetch();
  }

  List<ExamSchedule> getExamsForStudent(String studentId) {
    // Filter by studentId first; if no student-specific schedules exist,
    // fall back to all schedules (for shared class-level exam schedules)
    final filtered = state.where((e) => e.studentId == studentId).toList();
    return filtered.isNotEmpty ? filtered : state;
  }
}
