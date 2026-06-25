import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assignment.dart';

part 'assignments_provider.g.dart';

@riverpod
class Assignments extends _$Assignments {
  @override
  List<Assignment> build() {
    return _mockAssignments;
  }

  List<Assignment> getAssignmentsForDate(String studentId, DateTime date) {
    return state
        .where(
          (a) =>
              a.studentId == studentId &&
              a.date.year == date.year &&
              a.date.month == date.month &&
              a.date.day == date.day,
        )
        .toList();
  }
}

final _mockAssignments = [
  Assignment(
    id: '1',
    studentId: '1',
    subjectName: 'الرياضيات',
    content: 'حل التمارين صفحة 45 من كتاب الطالب.',
    date: DateTime.now(),
  ),
  Assignment(
    id: '2',
    studentId: '1',
    subjectName: 'العلوم',
    content: 'مراجعة الفصل الثالث استعداداً للاختبار.',
    date: DateTime.now(),
  ),
  Assignment(
    id: '3',
    studentId: '2',
    subjectName: 'اللغة العربية',
    content: 'كتابة موضوع تعبير عن أهمية القراءة.',
    date: DateTime.now(),
  ),
  Assignment(
    id: '4',
    studentId: '1',
    subjectName: 'التاريخ',
    content: 'تلخيص الدرس الثاني.',
    date: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Assignment(
    id: '5',
    studentId: '1',
    subjectName: 'الفيزياء',
    content: 'حل مسائل الحركة بتسارع ثابت.',
    date: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Assignment(
    id: '6',
    studentId: '1',
    subjectName: 'القرآن الكريم',
    content: 'حفظ سورة النبأ.',
    date: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Assignment(
    id: '7',
    studentId: '2',
    subjectName: 'الرياضيات',
    content: 'جدول الضرب من 1 إلى 5.',
    date: DateTime.now().subtract(const Duration(days: 1)),
  ),
];
