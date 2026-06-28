enum AbsenceRequestStatus {
  pending,
  approved,
  rejected,
}

class AbsenceRequest {
  final String id;
  final String studentId;
  final String studentName;
  final DateTime date;
  final String duration;
  final String reason;
  final AbsenceRequestStatus status;
  final String? rejectionReason;

  const AbsenceRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.duration,
    required this.reason,
    required this.status,
    this.rejectionReason,
  });
}
