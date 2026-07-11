import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/attendance.dart';
import '../models/student.dart';
import '../network/api_client.dart';
import 'children_provider.dart';

part 'attendance_provider.g.dart';

@Riverpod(keepAlive: true)
class AttendanceData extends _$AttendanceData {
  @override
  List<AttendanceRecord> build() {
    final kids = ref.watch(childrenProvider);
    if (kids.isEmpty) return [];

    // جلب سجلات الحضور لجميع الأبناء
    Future.microtask(() => _loadForKids(kids));
    return [];
  }

  Future<void> _loadForKids(List<Student> kids) async {
    try {
      final dio = ref.read(apiClientProvider);
      
      // Load attendance for all children in parallel for faster loading
      final results = await Future.wait(
        kids.map((kid) async {
          final response = await dio.get('attendance/student/${kid.id}');

          if (response.data != null &&
              response.data['success'] == true) {
            final List<dynamic> list =
                response.data['attendance'] ?? [];

            // بناء خريطة التواريخ: DateTime → true(حاضر)/false(غائب)
            final Map<DateTime, bool> attendanceMap = {};
            for (final record in list) {
              final dateStr = record['record_date']?.toString() ??
                  record['date']?.toString();
              if (dateStr == null) continue;

              final date = DateTime.tryParse(dateStr);
              if (date == null) continue;

              final status = record['status']?.toString() ?? '';
              attendanceMap[DateTime(date.year, date.month, date.day)] =
                  (status == 'present');
            }

            final presentDays =
                attendanceMap.values.where((v) => v).length;
            final absentDays =
                attendanceMap.values.where((v) => !v).length;

            return AttendanceRecord(
              studentId: kid.id.toString(),
              attendanceData: attendanceMap,
              presentDays: presentDays,
              absentDays: absentDays,
            );
          }
          return null;
        }),
      );

      final allRecords = results.whereType<AttendanceRecord>().toList();

      if (ref.mounted) {
        state = allRecords;
      }
    } catch (e) {
      debugPrint('Error loading attendance: $e');
    }
  }

  Future<void> refresh() async {
    final kids = ref.read(childrenProvider);
    if (kids.isNotEmpty) {
      await _loadForKids(kids);
    }
  }

  AttendanceRecord? getRecordForStudent(String studentId) {
    try {
      return state.firstWhere((r) => r.studentId == studentId);
    } catch (e) {
      return null;
    }
  }
}
