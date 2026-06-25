import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/exam_schedule.dart';

part 'exams_provider.g.dart';

@riverpod
class Exams extends _$Exams {
  @override
  List<ExamSchedule> build() {
    return _mockExams;
  }

  List<ExamSchedule> getExamsForStudent(String studentId) {
    return state.where((e) => e.studentId == studentId).toList();
  }
}

final _mockExams = [
  // First Term - Student 1
  ExamSchedule(
    id: 'e1_t1_m1',
    studentId: '1',
    term: ExamTerm.first,
    period: ExamPeriod.month1,
    subjects: [
      ExamSubject(
        subjectName: 'القرآن الكريم',
        date: DateTime.now().add(const Duration(days: 2)),
        note: 'تسميع سورة البقرة من آية 1 إلى 50',
      ),
      ExamSubject(
        subjectName: 'الرياضيات',
        date: DateTime.now().add(const Duration(days: 3)),
        note: 'الباب الأول فقط',
      ),
    ],
  ),
  ExamSchedule(
    id: 'e1_t1_m2',
    studentId: '1',
    term: ExamTerm.first,
    period: ExamPeriod.month2,
    subjects: [
      ExamSubject(
        subjectName: 'اللغة العربية',
        date: DateTime.now().add(const Duration(days: 30)),
        note: 'النصوص والقواعد النحوية',
      ),
      ExamSubject(
        subjectName: 'العلوم',
        date: DateTime.now().add(const Duration(days: 31)),
        note: 'الوحدة الثانية',
      ),
    ],
  ),
  ExamSchedule(
    id: 'e1_t1_m3',
    studentId: '1',
    term: ExamTerm.first,
    period: ExamPeriod.month3,
    subjects: [
      ExamSubject(
        subjectName: 'الاجتماعيات',
        date: DateTime.now().add(const Duration(days: 60)),
        note: 'الجغرافيا والتاريخ',
      ),
    ],
  ),
  ExamSchedule(
    id: 'e1_t1_f',
    studentId: '1',
    term: ExamTerm.first,
    period: ExamPeriod.finalExam,
    subjects: [
      ExamSubject(
        subjectName: 'الرياضيات',
        date: DateTime.now().add(const Duration(days: 90)),
        note: 'شامل كامل الكتاب',
      ),
      ExamSubject(
        subjectName: 'اللغة الإنجليزية',
        date: DateTime.now().add(const Duration(days: 91)),
        note: 'شامل',
      ),
    ],
  ),

  // Second Term - Student 1
  ExamSchedule(
    id: 'e1_t2_m1',
    studentId: '1',
    term: ExamTerm.second,
    period: ExamPeriod.month1,
    subjects: [
      ExamSubject(
        subjectName: 'القرآن الكريم',
        date: DateTime.now().add(const Duration(days: 120)),
        note: 'تسميع سورة البقرة من 50 إلى 100',
      ),
    ],
  ),
];
