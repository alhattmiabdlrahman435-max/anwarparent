import '../../models/student.dart';

class MockChildren {
  static List<Student> get getChildren => [
        Student(
          id: '1',
          name: 'أحمد محمد عبدالله',
          grade: 'الصف الخامس - شعبة (أ)',
        ),
        Student(
          id: '2',
          name: 'سارة محمد عبدالله',
          grade: 'الصف الثالث - شعبة (ب)',
        ),
        Student(
          id: '3',
          name: 'عمر محمد عبدالله',
          grade: 'الصف الأول - شعبة (ج)',
        ),
      ];
}
