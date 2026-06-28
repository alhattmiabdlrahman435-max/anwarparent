import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/class_schedule.dart';
import '../data/mock/mock_schedule.dart';

part 'schedule_provider.g.dart';

@riverpod
class ClassSchedules extends _$ClassSchedules {
  @override
  List<ClassSchedule> build() {
    return MockSchedule.getSchedules;
  }

  ClassSchedule? getScheduleForStudent(String studentId) {
    try {
      return state.firstWhere((s) => s.studentId == studentId);
    } catch (_) {
      return null;
    }
  }
}
