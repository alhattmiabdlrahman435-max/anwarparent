class Student {
  final String id;
  final String name;
  final String grade;
  final String classId; // معرف الفصل الدراسي
  final String? photoUrl; // رابط الصورة الشخصية أو الإيموجي

  Student({
    required this.id,
    required this.name,
    required this.grade,
    this.classId = '',
    this.photoUrl,
  });
}
