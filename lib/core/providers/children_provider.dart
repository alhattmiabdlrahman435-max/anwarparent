import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/student.dart';
import '../network/api_client.dart';
import 'parent_provider.dart';

part 'children_provider.g.dart';

@Riverpod(keepAlive: true)
class Children extends _$Children {
  @override
  List<Student> build() {
    _loadFromBackend();
    return [];
  }

  Future<void> _loadFromBackend() async {
    final parent = ref.watch(currentParentProvider);
    if (parent.id.isEmpty) {
      if (ref.mounted) {
        state = [];
      }
      return;
    }

    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('parents/${parent.id}/students');

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['students'] ?? [];
        final mapped = list.map((item) {
          final schoolClass = item['school_class'];
          final gradeName = schoolClass != null ? (schoolClass['name_ar'] ?? '') : '';
          return Student(
            id: item['id'].toString(),
            name: item['name_ar'] ?? '',
            grade: gradeName,
            classId: item['class_id']?.toString() ?? '',
          );
        }).toList();

        if (ref.mounted) {
          state = mapped;
        }
      }
    } catch (e) {
      // Keep empty or log error
      debugPrint('Error loading children: $e');
    }
  }

  Future<void> refresh() async {
    await _loadFromBackend();
  }
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
