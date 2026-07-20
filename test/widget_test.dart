import 'package:flutter_test/flutter_test.dart';
import 'package:anwarparent/core/models/student.dart';

void main() {
  test('Student model fromJson parses successfully unit test', () {
    final Map<String, dynamic> json = {
      'id': 202631,
      'name_ar': 'ياسر بن محمد الرويلي',
      'class_id': 3,
      'photo_url': 'https://example.com/photo.jpg',
      'school_class': {
        'name_ar': 'الصف الأول - أ'
      }
    };

    final student = Student(
      id: json['id'].toString(),
      name: json['name_ar'] ?? '',
      grade: json['school_class']?['name_ar'] ?? '',
      classId: json['class_id']?.toString() ?? '',
      photoUrl: json['photo_url'] ?? '',
    );

    expect(student.id, '202631');
    expect(student.name, 'ياسر بن محمد الرويلي');
    expect(student.grade, 'الصف الأول - أ');
    expect(student.classId, '3');
    expect(student.photoUrl, 'https://example.com/photo.jpg');
  });
}
