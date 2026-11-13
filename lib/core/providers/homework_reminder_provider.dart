import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../services/homework_reminder_service.dart';
import 'assignments_provider.dart';
import 'children_provider.dart';
import 'parent_provider.dart';

export '../services/homework_reminder_service.dart' show HomeworkReminderSettings, ReminderLead;

/// إعدادات "تذكير الواجبات" في شاشة الإعدادات (shared_preferences)
class HomeworkReminderSettingsNotifier extends Notifier<HomeworkReminderSettings> {
  static const _kEnabled = 'hw_reminder_enabled';
  static const _kLead = 'hw_reminder_lead';
  static const _kHour = 'hw_reminder_hour';
  static const _kMinute = 'hw_reminder_minute';

  @override
  HomeworkReminderSettings build() {
    Future.microtask(_load);
    return const HomeworkReminderSettings();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final leadName = prefs.getString(_kLead);
      final lead = ReminderLead.values.firstWhere(
        (l) => l.name == leadName,
        orElse: () => ReminderLead.oneDay,
      );
      if (!ref.mounted) return;
      state = HomeworkReminderSettings(
        enabled: prefs.getBool(_kEnabled) ?? true,
        lead: lead,
        hour: prefs.getInt(_kHour) ?? 19,
        minute: prefs.getInt(_kMinute) ?? 0,
        loaded: true,
      );
    } catch (_) {
      if (ref.mounted) state = state.copyWith(loaded: true);
    }
  }

  Future<void> setEnabled(bool v) async {
    state = state.copyWith(enabled: v);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kEnabled, v);
    } catch (_) {}
  }

  Future<void> setLead(ReminderLead lead) async {
    state = state.copyWith(lead: lead);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLead, lead.name);
    } catch (_) {}
  }

  Future<void> setTime(int hour, int minute) async {
    state = state.copyWith(hour: hour, minute: minute);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kHour, hour);
      await prefs.setInt(_kMinute, minute);
    } catch (_) {}
  }
}

final homeworkReminderSettingsProvider =
    NotifierProvider<HomeworkReminderSettingsNotifier, HomeworkReminderSettings>(
  HomeworkReminderSettingsNotifier.new,
);

/// يعيد جدولة تذكيرات الواجبات كلما تغيّرت الواجبات أو الإعدادات أو الأبناء.
/// يُفعَّل مرة واحدة من جذر التطبيق (main.dart) عبر listenManual.
final homeworkReminderSyncProvider = Provider<void>((ref) {
  final auth = ref.watch(authProvider);
  final parentId = ref.watch(currentParentProvider.select((p) => p.id));
  final settings = ref.watch(homeworkReminderSettingsProvider);
  final assignments = ref.watch(assignmentsProvider);
  final children = ref.watch(childrenProvider);

  final service = HomeworkReminderService.instance;
  // خروج مؤكد (وليس مجرد تحميل عند بدء التشغيل): نلغي كل التذكيرات
  if (auth is AsyncData<bool> && auth.value == false) {
    service.cancelAll();
    return;
  }

  if (!settings.loaded || parentId.isEmpty) return;
  // قائمة فارغة غالباً تعني أنها لم تُحمَّل بعد (أو لا يوجد اتصال): لا نلغي شيئاً
  if (assignments.isEmpty) return;

  service.sync(
    assignments: assignments,
    settings: settings,
    childNames: {for (final c in children) c.id: c.name},
  );
});
