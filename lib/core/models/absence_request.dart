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

  static AbsenceRequestStatus _parseStatus(String statusStr) {
    switch (statusStr.toLowerCase()) {
      case 'approved':
        return AbsenceRequestStatus.approved;
      case 'rejected':
        return AbsenceRequestStatus.rejected;
      case 'pending':
      default:
        return AbsenceRequestStatus.pending;
    }
  }

  static String _statusToString(AbsenceRequestStatus status) {
    switch (status) {
      case AbsenceRequestStatus.approved:
        return 'approved';
      case AbsenceRequestStatus.rejected:
        return 'rejected';
      case AbsenceRequestStatus.pending:
        return 'pending';
    }
  }

  factory AbsenceRequest.fromJson(Map<String, dynamic> json) {
    final student = json['student'];
    final studentName = student != null ? (student['name_ar'] ?? '') : '';
    
    final dateStr = json['start_date']?.toString() ?? json['requested_date']?.toString();
    final date = dateStr != null ? DateTime.tryParse(dateStr) ?? DateTime.now() : DateTime.now();

    return AbsenceRequest(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      studentName: studentName.toString(),
      date: date,
      duration: '1 يوم',
      reason: json['reason_ar']?.toString() ?? json['reason']?.toString() ?? '',
      status: _parseStatus(json['status']?.toString() ?? 'pending'),
      rejectionReason: json['admin_note_ar']?.toString(),
    );
  }

  Map<String, dynamic> toJson(String parentId) {
    return {
      'student_id': studentId,
      'parent_id': parentId,
      'start_date': date.toIso8601String().substring(0, 10),
      'end_date': date.toIso8601String().substring(0, 10),
      'reason_ar': reason,
      'status': _statusToString(status),
    };
  }
}
