class MonthlyGrade {
  final String monthName;
  final double homework; // out of 15
  final double attendance; // out of 15
  final double behavior; // out of 10
  final double oral; // out of 10
  final double written; // out of 50

  const MonthlyGrade({
    required this.monthName,
    required this.homework,
    required this.attendance,
    required this.behavior,
    required this.oral,
    required this.written,
  });

  double get total => homework + attendance + behavior + oral + written; // out of 100
}

class TermGrade {
  final MonthlyGrade month1;
  final MonthlyGrade month2;
  final MonthlyGrade month3;
  final double termExam; // out of 30

  const TermGrade({
    required this.month1,
    required this.month2,
    required this.month3,
    required this.termExam,
  });

  // Calculate the outcome out of 20 (sum of 3 months divided by 15)
  double get outcome => (month1.total + month2.total + month3.total) / 15.0;

  // Calculate the total term grade out of 50
  double get total => outcome + termExam;
}

class SubjectGrade {
  final String id;
  final String studentId;
  final String subjectName;
  final String iconName;
  final TermGrade term1;
  final TermGrade term2;

  const SubjectGrade({
    required this.id,
    required this.studentId,
    required this.subjectName,
    required this.iconName,
    required this.term1,
    required this.term2,
  });

  // Yearly total out of 100
  double get yearlyTotal => term1.total + term2.total;
}
