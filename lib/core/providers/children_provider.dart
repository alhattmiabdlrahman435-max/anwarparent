import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/student.dart';
import '../data/mock/mock_children.dart';

part 'children_provider.g.dart';

@Riverpod(keepAlive: true)
List<Student> children(Ref ref) {
  return MockChildren.getChildren;
}

@Riverpod(keepAlive: true)
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
