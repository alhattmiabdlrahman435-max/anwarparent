class Assignment {
  /// رقم نسخة الطالب من الواجب (submission)
  final String id;

  /// رقم الواجب نفسه على الخادم (مشترك بين كل طلاب الصف) — لفتحه من الإشعار
  final String assignmentId;
  final String studentId;
  final String subjectName;
  final String title;
  final String content;
  final DateTime date;
  final DateTime dueDate;
  /// كل مرفقات الواجب (صور/ملفات) بالترتيب
  final List<String> attachmentUrls;
  final String status; // 'pending' or 'submitted'
  final String? teacherNote;

  /// وقت تعديل المعلم للواجب بعد إرساله (null = لم يُعدَّل)
  final DateTime? editedAt;
  bool get isEdited => editedAt != null;

  const Assignment({
    required this.id,
    this.assignmentId = '',
    required this.studentId,
    required this.subjectName,
    required this.title,
    required this.content,
    required this.date,
    required this.dueDate,
    this.attachmentUrls = const [],
    required this.status,
    this.teacherNote,
    this.editedAt,
  });

  /// للتوافق مع الكود القديم: أول مرفق (إن وُجد)
  String? get attachmentUrl => attachmentUrls.isNotEmpty ? attachmentUrls.first : null;

  Assignment copyWith({
    String? id,
    String? studentId,
    String? subjectName,
    String? title,
    String? content,
    DateTime? date,
    DateTime? dueDate,
    List<String>? attachmentUrls,
    String? status,
    String? teacherNote,
  }) {
    return Assignment(
      id: id ?? this.id,
      assignmentId: assignmentId,
      studentId: studentId ?? this.studentId,
      subjectName: subjectName ?? this.subjectName,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      status: status ?? this.status,
      teacherNote: teacherNote ?? this.teacherNote,
      editedAt: editedAt,
    );
  }
}
