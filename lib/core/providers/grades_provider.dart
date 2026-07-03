import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/grade.dart';
import '../data/mock/mock_grades.dart';

part 'grades_provider.g.dart';

@riverpod
class Grades extends _$Grades {
  @override
  List<SubjectGrade> build() {
    return MockGrades.getGrades;
  }

  List<SubjectGrade> getGradesForStudent(String studentId) {
    return state.where((g) => g.studentId == studentId).toList();
  }
}
