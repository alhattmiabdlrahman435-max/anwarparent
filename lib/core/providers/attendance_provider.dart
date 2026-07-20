import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/attendance.dart';
import '../models/student.dart';
import '../network/api_client.dart';
import '../network/api_routes.dart';
import 'children_provider.dart';
import 'parent_provider.dart';

part 'attendance_provider.g.dart';

@Riverpod(keepAlive: true)
class AttendanceData extends _$AttendanceData {
  List<String> _loadedKidIds = [];

  @override
  FutureOr<List<AttendanceRecord>> build() async {
    final kids = ref.watch(childrenProvider);
    if (kids.isEmpty) {
      _loadedKidIds = [];
      return [];
    }

    final kidIds = kids.map((k) => k.id).toList();
    if (listEquals(_loadedKidIds, kidIds) && state.hasValue) {
      return state.requireValue;
    }

    _loadedKidIds = kidIds;
    return _loadForKids(kids);
  }

  Future<List<AttendanceRecord>> _loadForKids(List<Student> kids) async {
    final parentId = ref.read(currentParentProvider).id;
    final dio = ref.read(apiClientProvider);
    
    // Load attendance for all children in parallel for faster loading
    final results = await Future.wait(
      kids.map((kid) async {
        try {
          final response = await dio.get(ApiRoutes.studentAttendance(kid.id.toString()));

          if (response.data != null && response.data['success'] == true) {
            final List<dynamic> list = response.data['attendance'] ?? [];

            // بناء خريطة التواريخ: DateTime → true(حاضر)/false(غائب)
            final Map<DateTime, bool> attendanceMap = {};
            for (final record in list) {
              final dateStr = record['record_date']?.toString() ?? record['date']?.toString();
              if (dateStr == null) continue;

              final date = DateTime.tryParse(dateStr);
              if (date == null) continue;

              final status = record['status']?.toString() ?? '';
              attendanceMap[DateTime(date.year, date.month, date.day)] = (status == 'present');
            }

            final presentDays = attendanceMap.values.where((v) => v).length;
            final absentDays = attendanceMap.values.where((v) => !v).length;

            return AttendanceRecord(
              studentId: kid.id.toString(),
              attendanceData: attendanceMap,
              presentDays: presentDays,
              absentDays: absentDays,
            );
          }
        } catch (e) {
          debugPrint('Error loading attendance for student ${kid.id}: $e');
        }
        return null;
      }),
    );

    // Session ownership check: discard if parent changed during fetch
    if (!ref.mounted) return [];
    if (ref.read(currentParentProvider).id != parentId) return [];

    return results.whereType<AttendanceRecord>().toList();
  }

  Future<void> refresh() async {
    final kids = ref.read(childrenProvider);
    if (kids.isNotEmpty) {
      state = const AsyncValue.loading();
      try {
        final records = await _loadForKids(kids);
        state = AsyncValue.data(records);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  AttendanceRecord? getRecordForStudent(String studentId) {
    if (state.value == null) return null;
    try {
      return state.value!.firstWhere((r) => r.studentId == studentId);
    } catch (e) {
      return null;
    }
  }
}
