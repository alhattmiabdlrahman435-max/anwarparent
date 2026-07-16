import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/class_schedule.dart';
import '../models/student.dart';
import '../network/api_client.dart';
import 'children_provider.dart';

part 'schedule_provider.g.dart';

@Riverpod(keepAlive: true)
class ClassSchedules extends _$ClassSchedules {
  @override
  List<ClassSchedule> build() {
    final kids = ref.watch(childrenProvider);
    if (kids.isEmpty) return [];

    Future.microtask(() => _loadSchedules(kids));
    return [];
  }

  Future<void> _loadSchedules(List<Student> kids) async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('schedules');

      if (response.data != null && response.data['success'] == true) {
        final rawSchedules = response.data['schedules'];
        final Map<String, dynamic> apiSchedules = rawSchedules is Map ? Map<String, dynamic>.from(rawSchedules) : {};
        
        final rawTeachers = response.data['teachers'];
        final Map<String, dynamic> apiTeachers = rawTeachers is Map ? Map<String, dynamic>.from(rawTeachers) : {};
        final List<ClassSchedule> parsedSchedules = [];

        // أوقات الحصص الافتراضية
        final List<Map<String, String>> defaultTimings = [
          {'start': '08:00', 'end': '08:45'},
          {'start': '08:45', 'end': '09:30'},
          {'start': '09:45', 'end': '10:30'},
          {'start': '10:30', 'end': '11:15'},
          {'start': '11:30', 'end': '12:15'},
          {'start': '12:15', 'end': '01:00'},
        ];

        for (final kid in kids) {
          final String classGrade = kid.grade; // مثل "الصف الأول - أ"
          
          if (apiSchedules.containsKey(classGrade)) {
            final classData = apiSchedules[classGrade] as Map<String, dynamic>;
            final List<ClassScheduleDay> scheduleDays = [];

            classData.forEach((dayName, periodsList) {
              if (periodsList is List) {
                final List<ClassPeriod> periods = [];
                for (int i = 0; i < periodsList.length; i++) {
                  final String subject = periodsList[i]?.toString() ?? '';
                  if (subject.isEmpty) continue;

                  // تحديد التوقيت الافتراضي للحصة
                  final timings = i < defaultTimings.length 
                      ? defaultTimings[i] 
                      : {'start': '00:00', 'end': '00:00'};

                  // الحصول على اسم المعلم للمادة في هذا الفصل بشكل آمن
                  String teacherName = 'معلم المادة';
                  if (apiTeachers.containsKey(classGrade)) {
                    final classTeachers = apiTeachers[classGrade];
                    if (classTeachers is Map && classTeachers.containsKey(subject)) {
                      teacherName = classTeachers[subject]?.toString() ?? 'معلم المادة';
                    }
                  }

                  periods.add(
                    ClassPeriod(
                      periodNumber: i + 1,
                      subjectName: subject,
                      startTime: timings['start']!,
                      endTime: timings['end']!,
                      teacherName: teacherName,
                    ),
                  );
                }

                scheduleDays.add(
                  ClassScheduleDay(
                    dayKey: dayName.toLowerCase(),
                    periods: periods,
                  ),
                );
              }
            });

            parsedSchedules.add(
              ClassSchedule(
                studentId: kid.id.toString(),
                days: scheduleDays,
              ),
            );
          }
        }

        if (ref.mounted) {
          state = parsedSchedules;
        }
      }
    } catch (e) {
      debugPrint('Error loading weekly schedules: $e');
    }
  }

  Future<void> refresh() async {
    final kids = ref.read(childrenProvider);
    if (kids.isNotEmpty) {
      await _loadSchedules(kids);
    }
  }

  ClassSchedule? getScheduleForStudent(String studentId) {
    try {
      return state.firstWhere((s) => s.studentId == studentId);
    } catch (_) {
      return null;
    }
  }
}
