class AppNotification {
  final String id;
  final String title;
  final String content;
  final String type;
  final bool isRead;
  final String targetType;
  final String? targetId;
  final String? attachmentUrl;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.isRead,
    required this.targetType,
    this.targetId,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      targetType: json['target_type']?.toString() ?? 'all_parents',
      targetId: json['target_id']?.toString(),
      attachmentUrl: json['attachment_url']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
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
      isRead: isRead ?? this.isRead,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
