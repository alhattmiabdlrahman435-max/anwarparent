enum ExamTerm { first, second }

enum ExamPeriod { month1, month2, month3, finalExam }

extension ExamPeriodExt on ExamPeriod {
  String get displayName {
    switch (this) {
      case ExamPeriod.month1:
        return 'الشهر الأول';
      case ExamPeriod.month2:
        return 'الشهر الثاني';
      case ExamPeriod.month3:
        return 'الشهر الثالث';
      case ExamPeriod.finalExam:
        return 'اختبار نهاية الترم';
    }
  }
}

class ExamSchedule {
  final String id;
  final String studentId;
  final ExamTerm term;
  final ExamPeriod period;
  final List<ExamSubject> subjects;

  const ExamSchedule({
    required this.id,
    required this.studentId,
    required this.term,
    required this.period,
    required this.subjects,
  });
}

class ExamSubject {
  final String subjectName;
  final DateTime date;
  final String note;

  const ExamSubject({
    required this.subjectName,
    required this.date,
    required this.note,
  });
}
