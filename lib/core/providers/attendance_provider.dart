import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/attendance.dart';

part 'attendance_provider.g.dart';

@riverpod
class AttendanceData extends _$AttendanceData {
  @override
  List<AttendanceRecord> build() {
    return _mockData;
  }

  AttendanceRecord? getRecordForStudent(String studentId) {
    try {
      return state.firstWhere((r) => r.studentId == studentId);
    } catch (e) {
      return null;
    }
  }
}

final _mockData = [
  AttendanceRecord(
    studentId: '1',
    presentDays: 7,
    absentDays: 1,
    attendanceData: {
      DateTime.now().subtract(const Duration(days: 1)): true,
      DateTime.now().subtract(const Duration(days: 2)): true,
      DateTime.now().subtract(const Duration(days: 3)): false,
      DateTime.now().subtract(const Duration(days: 6)): true,
      DateTime.now().subtract(const Duration(days: 7)): true,
      DateTime.now().subtract(const Duration(days: 8)): true,
      DateTime.now().subtract(const Duration(days: 9)): true,
      DateTime.now().subtract(const Duration(days: 10)): true,
    },
  ),
  AttendanceRecord(
    studentId: '2',
    presentDays: 3,
    absentDays: 0,
    attendanceData: {
      DateTime.now().subtract(const Duration(days: 1)): true,
      DateTime.now().subtract(const Duration(days: 2)): true,
      DateTime.now().subtract(const Duration(days: 3)): true,
    },
  ),
  AttendanceRecord(
    studentId: '3',
    presentDays: 5,
    absentDays: 2,
    attendanceData: {
      DateTime.now().subtract(const Duration(days: 1)): true,
      DateTime.now().subtract(const Duration(days: 2)): false,
      DateTime.now().subtract(const Duration(days: 3)): false,
      DateTime.now().subtract(const Duration(days: 6)): true,
      DateTime.now().subtract(const Duration(days: 7)): true,
      DateTime.now().subtract(const Duration(days: 8)): true,
      DateTime.now().subtract(const Duration(days: 9)): true,
    },
  ),
];
