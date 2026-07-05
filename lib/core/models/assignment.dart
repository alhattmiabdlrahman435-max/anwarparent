class Assignment {
  final String id;
  final String studentId;
  final String subjectName;
  final String title;
  final String content;
  final DateTime date;
  final DateTime dueDate;
  final String? attachmentUrl;
  final String status; // 'pending' or 'submitted'
  final String? teacherNote;

  const Assignment({
    required this.id,
    required this.studentId,
    required this.subjectName,
    required this.title,
    required this.content,
    required this.date,
    required this.dueDate,
    this.attachmentUrl,
    required this.status,
    this.teacherNote,
  });

  Assignment copyWith({
    String? id,
    String? studentId,
    String? subjectName,
    String? title,
    String? content,
    DateTime? date,
    DateTime? dueDate,
    String? attachmentUrl,
    String? status,
    String? teacherNote,
  }) {
    return Assignment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      subjectName: subjectName ?? this.subjectName,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      status: status ?? this.status,
      teacherNote: teacherNote ?? this.teacherNote,
    );
  }
}
