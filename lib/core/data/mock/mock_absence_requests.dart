import '../../models/absence_request.dart';

class MockAbsenceRequests {
  static List<AbsenceRequest> get getRequests => [
        AbsenceRequest(
          id: '1',
          studentId: '1',
          studentName: 'شادي عبدالرحمن الحطامي',
          date: DateTime(2026, 6, 18),
          duration: 'يوم كامل',
          reason: 'مرض',
          status: AbsenceRequestStatus.rejected,
          rejectionReason: 'ابنك كذاب',
        ),
        AbsenceRequest(
          id: '2',
          studentId: '1',
          studentName: 'شادي عبدالرحمن الحطامي',
          date: DateTime(2026, 6, 10),
          duration: 'يوم كامل',
          reason: '',
          status: AbsenceRequestStatus.approved,
        ),
        AbsenceRequest(
          id: '3',
          studentId: '2',
          studentName: 'ايلول عبدالرحمن محمد الحطامي',
          date: DateTime(2026, 6, 9),
          duration: 'يوم كامل',
          reason: 'للغ',
          status: AbsenceRequestStatus.approved,
        ),
        AbsenceRequest(
          id: '4',
          studentId: '1',
          studentName: 'شادي عبدالرحمن الحطامي',
          date: DateTime(2026, 6, 8),
          duration: 'يوم كامل',
          reason: '',
          status: AbsenceRequestStatus.approved,
        ),
        AbsenceRequest(
          id: '5',
          studentId: '1',
          studentName: 'شادي عبدالرحمن الحطامي',
          date: DateTime(2026, 6, 7),
          duration: 'يوم كامل',
          reason: '',
          status: AbsenceRequestStatus.approved,
        ),
        AbsenceRequest(
          id: '6',
          studentId: '3',
          studentName: 'ايار عبدالرحمن محمد الحطامي',
          date: DateTime(2026, 6, 6),
          duration: 'يوم كامل',
          reason: '',
          status: AbsenceRequestStatus.rejected,
          rejectionReason: 'no',
        ),
      ];
}
