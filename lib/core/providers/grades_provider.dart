import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/grade.dart';
import '../models/student.dart';
import '../network/api_client.dart';
import 'children_provider.dart';
import 'parent_provider.dart';

part 'grades_provider.g.dart';

@Riverpod(keepAlive: true)
class Grades extends _$Grades {

  List<String> _loadedKidIds = [];

  @override
  List<SubjectGrade> build() {
    final kids = ref.watch(childrenProvider);
    if (kids.isEmpty) {
      _loadedKidIds = [];
      return [];
    }

    final kidIds = kids.map((k) => k.id).toList();
    if (listEquals(_loadedKidIds, kidIds)) {
      return state;
    }

    _loadedKidIds = kidIds;
    Future.microtask(() => _loadGradesForKids(kids));

    return state;
  }

  Future<void> _loadGradesForKids(List<Student> kids) async {
    final parentId = ref.read(currentParentProvider).id;
    try {
      final dio = ref.read(apiClientProvider);

      // Load grades for all children in parallel for faster loading
      final results = await Future.wait(
        kids.map((kid) async {
          try {
            final response = await dio.get('grades/detailed/${kid.id}');
            if (response.data != null && response.data['success'] == true) {
              final List<dynamic> list = response.data['grades'] ?? [];
              
              // Group by subject_id
              final Map<int, List<dynamic>> grouped = {};
              for (final record in list) {
                final subjectId = int.tryParse(record['subject_id']?.toString() ?? '') ?? 0;
                if (subjectId == 0) continue;
                grouped.putIfAbsent(subjectId, () => []).add(record);
              }

              // Build SubjectGrade for each subject
              final List<SubjectGrade> kidGrades = [];
              grouped.forEach((subjectId, records) {
                final firstRecord = records.first;
                final subjectName = firstRecord['subject']?['name_ar'] ?? '';
                final iconName = _getIconForSubject(subjectName);

                final term1Grade = _buildTermGrade(records, 'term1');
                final term2Grade = _buildTermGrade(records, 'term2');

                kidGrades.add(
                  SubjectGrade(
                    id: '${kid.id}_$subjectId',
                    studentId: kid.id,
                    subjectName: subjectName,
                    iconName: iconName,
                    term1: term1Grade,
                    term2: term2Grade,
                  ),
                );
              });
              return kidGrades;
            }
          } catch (e) {
            debugPrint('Error loading grades for student ${kid.id}: $e');
          }
          return <SubjectGrade>[];
        }),
      );

      if (!ref.mounted) return;
      if (ref.read(currentParentProvider).id != parentId) return;

      final allGrades = results.expand((grades) => grades).toList();
      state = allGrades;
    } catch (e) {
      debugPrint('Error loading detailed grades: $e');
    }
  }

  Future<void> refresh() async {
    final kids = ref.read(childrenProvider);
    if (kids.isNotEmpty) {
      await _loadGradesForKids(kids);
    }
  }

  String _getIconForSubject(String name) {
    if (name.contains('رياضيات')) return 'function';
    if (name.contains('علوم')) return 'lab_flask';
    if (name.contains('لغتي') || name.contains('عربي') || name.contains('اللغة العربية')) return 'book';
    return 'book';
  }

  TermGrade _buildTermGrade(List<dynamic> records, String termKey) {
    final termRecords = records.where((r) => r['term'] == termKey).toList();

    final m1 = termRecords.firstWhere((r) => r['month'] == 'm1', orElse: () => null);
    final m2 = termRecords.firstWhere((r) => r['month'] == 'm2', orElse: () => null);
    final m3 = termRecords.firstWhere((r) => r['month'] == 'm3', orElse: () => null);
    final finalExamRecord = termRecords.firstWhere((r) => r['month'] == 'final', orElse: () => null);

    return TermGrade(
      month1: _buildMonthlyGrade('الشهر الأول', m1),
      month2: _buildMonthlyGrade('الشهر الثاني', m2),
      month3: _buildMonthlyGrade('الشهر الثالث', m3),
      termExam: finalExamRecord != null ? (double.tryParse(finalExamRecord['final_exam']?.toString() ?? '0') ?? 0.0) : 0.0,
    );
  }

  MonthlyGrade _buildMonthlyGrade(String name, dynamic record) {
    if (record == null) {
      return MonthlyGrade(
        monthName: name,
        homework: 0.0,
        attendance: 0.0,
        behavior: 0.0,
        oral: 0.0,
        written: 0.0,
      );
    }

    return MonthlyGrade(
      monthName: name,
      homework: double.tryParse(record['hw_grade']?.toString() ?? '0') ?? 0.0,
      attendance: double.tryParse(record['att_grade']?.toString() ?? '0') ?? 0.0,
      behavior: double.tryParse(record['beh_grade']?.toString() ?? '0') ?? 0.0,
      oral: double.tryParse(record['oral_grade']?.toString() ?? '0') ?? 0.0,
      written: double.tryParse(record['wrt_grade']?.toString() ?? '0') ?? 0.0,
    );
  }
}
