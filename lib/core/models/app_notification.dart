class AppNotification {
  final String id;
  final String title;
  final String content;
  final String type;

  /// مصدر الإشعار: admin | assignments | grades | attendance | exams | schedule | absence | finance | reports | other
  final String source;
  final bool isRead;
  final String targetType;
  final String? targetId;
  final String? attachmentUrl;
  final DateTime createdAt;

  /// وقت تعديل الإدارة للإشعار بعد إرساله (null = لم يُعدَّل)
  final DateTime? editedAt;

  bool get isEdited => editedAt != null;

  /// إشعار "واجب مدرسي جديد": رقم الواجب لفتحه في صفحة الواجبات
  final String? assignmentId;

  AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.source = 'other',
    required this.isRead,
    required this.targetType,
    this.targetId,
    this.attachmentUrl,
    required this.createdAt,
    this.editedAt,
    this.assignmentId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      source: json['source']?.toString() ?? 'other',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      targetType: json['target_type']?.toString() ?? 'all_parents',
      targetId: json['target_id']?.toString(),
      attachmentUrl: json['attachment_url']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      assignmentId: json['assignment_id']?.toString(),
      editedAt: json['edited_at'] != null
          ? DateTime.tryParse(json['edited_at'].toString())
          : null,
    );
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? content,
    String? type,
    bool? isRead,
    String? targetType,
    String? targetId,
    String? attachmentUrl,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      source: source,
      isRead: isRead ?? this.isRead,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt,
      assignmentId: assignmentId,
    );
  }
}
