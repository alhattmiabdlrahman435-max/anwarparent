class ClassPeriod {
  final int periodNumber;
  final String subjectName;
  final String startTime;
  final String endTime;
  final String teacherName;

  const ClassPeriod({
    required this.periodNumber,
    required this.subjectName,
    required this.startTime,
    required this.endTime,
    required this.teacherName,
  });
}

class ClassScheduleDay {
  final String dayKey; // e.g. 'saturday', 'sunday', 'monday', 'tuesday', 'wednesday'
  final List<ClassPeriod> periods;

  const ClassScheduleDay({
    required this.dayKey,
    required this.periods,
  });
}

class ClassSchedule {
  final String studentId;
  final List<ClassScheduleDay> days;

  const ClassSchedule({
    required this.studentId,
    required this.days,
  });
}
