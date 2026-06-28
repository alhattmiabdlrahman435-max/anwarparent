import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assignment.dart';
import '../data/mock/mock_assignments.dart';

part 'assignments_provider.g.dart';

@riverpod
class Assignments extends _$Assignments {
  @override
  List<Assignment> build() {
    return MockAssignments.getAssignments;
  }

  List<Assignment> getAssignmentsForDate(String studentId, DateTime date) {
    return state
        .where(
          (a) =>
              a.studentId == studentId &&
              a.date.year == date.year &&
              a.date.month == date.month &&
              a.date.day == date.day,
        )
        .toList();
  }
}
