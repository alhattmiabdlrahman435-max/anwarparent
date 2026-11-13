import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/localization_extension.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/models/student.dart';

/// كيف يُعرض الإشعار لولي الأمر: من أين جاء، ولمن أُرسل، وأي أبناء يخصهم.
/// التسميات مأخوذة من صفحات التطبيق نفسها (القائمة الجانبية).
class NotificationPresentation {
  final String sourceLabel;
  final IconData icon;
  final Color color;

  /// لمن أُرسل: "لجميع أولياء الأمور" / "الصف الثاني - ب" / "خاص". فارغ للإشعارات الآلية.
  final String audienceLabel;

  /// الأبناء الذين يخصهم الإشعار (فارغ = لجميع أولياء الأمور)
  final List<Student> relatedChildren;

  const NotificationPresentation({
    required this.sourceLabel,
    required this.icon,
    required this.color,
    required this.audienceLabel,
    required this.relatedChildren,
  });

  static bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  /// الأبناء الذين يخصهم الإشعار
  static List<Student> relatedChildrenOf(AppNotification n, List<Student> children) {
    switch (n.targetType) {
      case 'by_student':
        return children.where((c) => c.id == n.targetId).toList();
      case 'by_class':
        return children.where((c) => c.classId.isNotEmpty && c.classId == n.targetId).toList();
      default:
        return const [];
    }
  }

  /// هل يظهر الإشعار عند اختيار هذا الابن (null = كل الأبناء)
  static bool belongsTo(AppNotification n, Student? child) {
    if (child == null) return true;
    if (n.targetType == 'by_student') return n.targetId == child.id;
    if (n.targetType == 'by_class') return n.targetId == child.classId;
    return true; // لجميع أولياء الأمور
  }

  static NotificationPresentation of(
    BuildContext context,
    AppNotification n,
    List<Student> children,
  ) {
    final ar = _isArabic(context);
    final loc = context.loc;
    final related = relatedChildrenOf(n, children);

    late final String label;
    late final IconData icon;
    late final Color color;
    switch (n.source) {
      case 'admin':
        label = ar ? 'إدارة المدرسة' : 'School administration';
        icon = CupertinoIcons.building_2_fill;
        color = const Color(0xFF062A5A);
        break;
      case 'assignments':
        label = loc.schoolAssignments;
        icon = CupertinoIcons.book_fill;
        color = const Color(0xFFD97706);
        break;
      case 'grades':
        label = loc.grades;
        icon = CupertinoIcons.chart_bar_alt_fill;
        color = const Color(0xFF2563EB);
        break;
      case 'attendance':
        label = loc.attendanceRecord;
        icon = CupertinoIcons.checkmark_circle_fill;
        color = const Color(0xFF16A34A);
        break;
      case 'exams':
        label = loc.exams;
        icon = CupertinoIcons.doc_text_search;
        color = const Color(0xFF7C3AED);
        break;
      case 'schedule':
        label = loc.classSchedule;
        icon = CupertinoIcons.calendar;
        color = const Color(0xFF0891B2);
        break;
      case 'absence':
        label = loc.absenceRequest;
        icon = CupertinoIcons.calendar_badge_minus;
        color = const Color(0xFFDB2777);
        break;
      case 'finance':
        label = loc.fees;
        icon = CupertinoIcons.creditcard_fill;
        color = const Color(0xFF059669);
        break;
      case 'reports':
        label = loc.alerts;
        icon = CupertinoIcons.exclamationmark_shield_fill;
        color = const Color(0xFFDC2626);
        break;
      default:
        label = loc.notifications;
        icon = CupertinoIcons.bell_fill;
        color = Colors.orangeAccent;
    }

    String audience = '';
    if (n.source == 'admin') {
      switch (n.targetType) {
        case 'by_student':
          audience = ar ? 'خاص' : 'Private';
          break;
        case 'by_class':
          audience = related.isNotEmpty ? related.first.grade : (ar ? 'صف' : 'Class');
          break;
        default:
          // "جميع المستخدمين" في لوحة التحكم يُحفظ بالنوع general ويصل للمعلمين وأولياء الأمور
          audience = n.type == 'general'
              ? (ar ? 'لجميع المستخدمين' : 'All users')
              : (ar ? 'لجميع أولياء الأمور' : 'All parents');
      }
    }

    return NotificationPresentation(
      sourceLabel: label,
      icon: icon,
      color: color,
      audienceLabel: audience,
      relatedChildren: related,
    );
  }

  /// الاسم الأول للابن (عبدالرحمن بن خالد العسيري → عبدالرحمن)
  static String firstName(Student s) => s.name.trim().split(RegExp(r'\s+')).first;

  /// "عبدالرحمن، يوسف"
  static String childrenNames(BuildContext context, List<Student> kids) {
    final sep = _isArabic(context) ? '، ' : ', ';
    return kids.map(firstName).join(sep);
  }
}
