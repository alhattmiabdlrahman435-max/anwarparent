import '../../models/exam_schedule.dart';

class MockExams {
  static List<ExamSchedule> get getExams => [
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
              time: '08:00 ص - 09:30 ص',
              note: 'تسميع سورة البقرة من آية 1 إلى 50',
            ),
            ExamSubject(
              subjectName: 'الرياضيات',
              date: DateTime.now().add(const Duration(days: 3)),
              time: '08:00 ص - 10:00 ص',
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
              time: '08:00 ص - 10:00 ص',
              note: 'النصوص والقواعد النحوية',
            ),
            ExamSubject(
              subjectName: 'العلوم',
              date: DateTime.now().add(const Duration(days: 31)),
              time: '08:00 ص - 09:30 ص',
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
              time: '08:00 ص - 09:30 ص',
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
              time: '08:00 ص - 10:00 ص',
              note: 'شامل كامل الكتاب',
            ),
            ExamSubject(
              subjectName: 'اللغة الإنجليزية',
              date: DateTime.now().add(const Duration(days: 91)),
              time: '08:00 ص - 10:00 ص',
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
              time: '08:00 ص - 09:30 ص',
              note: 'تسميع سورة البقرة من 50 إلى 100',
            ),
          ],
        ),
      ];
}
