import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/exam_schedule.dart';
import '../data/mock/mock_exams.dart';

part 'exams_provider.g.dart';

@riverpod
class Exams extends _$Exams {
  @override
  List<ExamSchedule> build() {
    return MockExams.getExams;
  }

  List<ExamSchedule> getExamsForStudent(String studentId) {
    return state.where((e) => e.studentId == studentId).toList();
  }
}
