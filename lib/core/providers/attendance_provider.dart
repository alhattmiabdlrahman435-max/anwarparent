import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/attendance.dart';
import '../data/mock/mock_attendance.dart';

part 'attendance_provider.g.dart';

@riverpod
class AttendanceData extends _$AttendanceData {
  @override
  List<AttendanceRecord> build() {
    return MockAttendance.getAttendance;
  }

  AttendanceRecord? getRecordForStudent(String studentId) {
    try {
      return state.firstWhere((r) => r.studentId == studentId);
    } catch (e) {
      return null;
    }
  }
}
