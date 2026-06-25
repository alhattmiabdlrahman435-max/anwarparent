import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'children_provider.g.dart';

class Student {
  final String id;
  final String name;
  final String grade;

  Student({required this.id, required this.name, required this.grade});
}

@riverpod
List<Student> children(Ref ref) {
  return [
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
    Student(id: '3', name: 'عمر محمد عبدالله', grade: 'الصف الأول - شعبة (ج)'),
  ];
}

@riverpod
class CurrentChild extends _$CurrentChild {
  @override
  Student? build() {
    final kids = ref.watch(childrenProvider);
    return kids.isNotEmpty ? kids.first : null;
  }

  void setChild(Student child) {
    state = child;
  }
}
