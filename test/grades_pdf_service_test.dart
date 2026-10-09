import 'package:flutter_test/flutter_test.dart';
import 'package:anwarparent/core/models/student.dart';
import 'package:anwarparent/core/models/grade.dart';
import 'package:anwarparent/features/grades/services/grades_pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('GradesPdfService generates PDF bytes successfully with full report data', () async {
    final student = Student(
      id: '1',
      name: 'ابراهيم انور محمد صالح مقبل الحكيمي',
      grade: 'الصف الثالث الثانوي - أ',
    );

    final subjects = [
      SubjectGrade(
        id: 'sub_1',
        studentId: '1',
        subjectName: 'القرآن الكريم',
        iconName: 'book',
        term1: TermGrade(
          month1: const MonthlyGrade(monthName: 'الشهر 1', homework: 0, attendance: 0, behavior: 0, oral: 0, written: 0),
          month2: const MonthlyGrade(monthName: 'الشهر 2', homework: 0, attendance: 0, behavior: 0, oral: 0, written: 0),
          month3: const MonthlyGrade(monthName: 'الشهر 3', homework: 0, attendance: 0, behavior: 0, oral: 0, written: 0),
          termExam: 30,
        ),
        term2: const TermGrade(
          month1: MonthlyGrade(monthName: 'الشهر 1', homework: 0, attendance: 0, behavior: 0, oral: 0, written: 0),
          month2: MonthlyGrade(monthName: 'الشهر 2', homework: 0, attendance: 0, behavior: 0, oral: 0, written: 0),
          month3: MonthlyGrade(monthName: 'الشهر 3', homework: 0, attendance: 0, behavior: 0, oral: 0, written: 0),
          termExam: 0,
        ),
      ),
    ];

    final pdfBytes = await GradesPdfService.generateReportCardPdf(
      student: student,
      subjects: subjects,
      selectedTerm: 1,
    );

    expect(pdfBytes, isNotNull);
    expect(pdfBytes.isNotEmpty, true);
    // PDF file header check (%PDF)
    final header = String.fromCharCodes(pdfBytes.take(4));
    expect(header, equals('%PDF'));
  });
}
