class AttendanceRecord {
  final String studentId;
  final Map<DateTime, bool> attendanceData; // true: present, false: absent
  final int presentDays;
  final int absentDays;

  const AttendanceRecord({
    required this.studentId,
    required this.attendanceData,
    required this.presentDays,
    required this.absentDays,
  });
}
