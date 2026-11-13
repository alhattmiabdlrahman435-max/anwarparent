import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/assignment.dart';

/// متى يُرسَل التذكير الافتراضي بالنسبة لموعد التسليم
enum ReminderLead { oneDay, twoDays, threeDays, dueDayMorning }

/// إعدادات تذكير الواجبات غير المسلَّمة (تُحفظ محلياً)
class HomeworkReminderSettings {
  final bool enabled;
  final ReminderLead lead;
  final int hour;
  final int minute;

  /// false حتى تُقرأ القيم المحفوظة؛ لا نجدول قبلها حتى لا نجدول بإعدادات خاطئة
  final bool loaded;

  const HomeworkReminderSettings({
    this.enabled = true,
    this.lead = ReminderLead.oneDay,
    this.hour = 19,
    this.minute = 0,
    this.loaded = false,
  });

  HomeworkReminderSettings copyWith({
    bool? enabled,
    ReminderLead? lead,
    int? hour,
    int? minute,
    bool? loaded,
  }) {
    return HomeworkReminderSettings(
      enabled: enabled ?? this.enabled,
      lead: lead ?? this.lead,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      loaded: loaded ?? this.loaded,
    );
  }
}

/// تذكيرات محلية مجدولة على الجهاز للواجبات التي لم تُسلَّم بعد.
///
/// - التذكير الافتراضي: واحد لكل واجب غير مسلَّم حسب الإعدادات.
/// - التذكير المخصص: يختاره ولي الأمر لواجب محدد (تاريخ + وقت) ويُحفظ ليبقى بعد إعادة التشغيل.
///
/// المعرّفات ثابتة ومشتقة من رقم التسليم (submission id) حتى يمكن إلغاؤها وإعادة جدولتها.
class HomeworkReminderService {
  HomeworkReminderService._();
  static final HomeworkReminderService instance = HomeworkReminderService._();

  static const String channelId = 'high_importance_channel_v2';
  static const String channelName = 'إشعارات هامة';

  static const int _defaultBase = 1200000000;
  static const int _customBase = 1650000000;
  static const int _rangeSize = 450000000;

  static const String _customKey = 'hw_reminder_custom_v1';
  static const String _datesKey = 'hw_reminder_dates_v1';

  static final Completer<void> _pluginReady = Completer<void>();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _tzReady = false;
  Future<void> _queue = Future.value();

  /// يُستدعى من main.dart بعد تهيئة flutter_local_notifications (أو عند فشلها).
  static void markPluginReady() {
    if (!_pluginReady.isCompleted) _pluginReady.complete();
  }

  /// هل هذا المعرّف لإشعار تذكير واجب (افتراضي أو مخصص)؟
  static bool isReminderNotificationId(int? id) =>
      id != null && id >= _defaultBase && id < _customBase + _rangeSize;

  static int _slot(String submissionId) {
    final n = int.tryParse(submissionId);
    if (n != null && n >= 0 && n < _rangeSize) return n;
    // معرّف غير رقمي: تجزئة ثابتة (FNV-1a) لأن String.hashCode غير مضمون الثبات
    var h = 0x811c9dc5;
    for (final c in submissionId.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return h % _rangeSize;
  }

  static int defaultIdFor(String submissionId) => _defaultBase + _slot(submissionId);
  static int customIdFor(String submissionId) => _customBase + _slot(submissionId);

  static bool _isSubmitted(String status) => status == 'submitted' || status == 'submitted_late';

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// لم يُسلَّم وموعد التسليم لم ينتهِ بعد (اليوم أو بعده)
  static bool isReminderEligible(Assignment a) =>
      !_isSubmitted(a.status) && !_dayOnly(a.dueDate).isBefore(_dayOnly(DateTime.now()));

  /// وقت التذكير الافتراضي لواجب حسب الإعدادات
  static DateTime defaultReminderTime(DateTime dueDate, HomeworkReminderSettings s) {
    final due = _dayOnly(dueDate);
    switch (s.lead) {
      case ReminderLead.oneDay:
        return DateTime(due.year, due.month, due.day - 1, s.hour, s.minute);
      case ReminderLead.twoDays:
        return DateTime(due.year, due.month, due.day - 2, s.hour, s.minute);
      case ReminderLead.threeDays:
        return DateTime(due.year, due.month, due.day - 3, s.hour, s.minute);
      case ReminderLead.dueDayMorning:
        return DateTime(due.year, due.month, due.day, 7, 0);
    }
  }

  Future<bool> _ensureReady() async {
    if (kIsWeb) return false;
    try {
      await _pluginReady.future.timeout(const Duration(seconds: 20));
    } catch (_) {
      // نكمل حتى لو تأخرت التهيئة؛ أي خطأ لاحق يُلتقط
    }
    if (!_tzReady) {
      try {
        tz_data.initializeTimeZones();
      } catch (_) {}
      _tzReady = true;
    }
    return true;
  }

  /// نجدول بلحظة زمنية مطلقة (UTC) محسوبة من التوقيت المحلي للجهاز،
  /// فلا نحتاج معرفة اسم المنطقة الزمنية ولا تثبيت +3.
  tz.TZDateTime _toTz(DateTime local) => tz.TZDateTime.from(local.toUtc(), tz.UTC);

  /// تنفيذ العمليات بالتتابع حتى لا تتداخل عمليات الإلغاء والجدولة
  Future<T> _serial<T>(Future<T> Function() task) {
    final completer = Completer<T>();
    _queue = _queue.then((_) async {
      try {
        completer.complete(await task());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  String _firstName(String name) {
    final t = name.trim();
    if (t.isEmpty) return '';
    return t.split(RegExp(r'\s+')).first;
  }

  String _body(Assignment a, String childName) {
    final due = DateFormat('yyyy-MM-dd').format(a.dueDate);
    final first = _firstName(childName);
    final forChild = first.isEmpty ? '' : ' لابنكم $first';
    return 'واجب ${a.subjectName}: ${a.title}$forChild — موعد التسليم $due';
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  /// هل يسمح أندرويد بالتذكير في الدقيقة المحددة بالضبط (إذن "المنبّهات والتذكيرات")
  Future<bool> _canExact() async {
    try {
      return await _android?.canScheduleExactNotifications() ?? true;
    } catch (_) {
      return false;
    }
  }

  /// يطلب إذن التذكير الدقيق مرة عند ضبط تذكير مخصص (أندرويد 12+). بدون الإذن يعمل التذكير بتوقيت تقريبي.
  Future<void> _ensureExactPermission() async {
    try {
      if (!await _canExact()) {
        await _android?.requestExactAlarmsPermission();
      }
    } catch (_) {}
  }

  Future<void> _schedule(int id, DateTime at, Assignment a, String childName) async {
    // بالضبط في الوقت المحدد إن سُمح بذلك، وإلا تقريبي (قد يتأخر أندرويد حتى ساعة)
    final exact = await _canExact();
    Future<void> scheduleWith(AndroidScheduleMode mode) => _plugin.zonedSchedule(
          id: id,
          scheduledDate: _toTz(at),
          notificationDetails: _details,
          androidScheduleMode: mode,
          title: 'تذكير بواجب لم يُسلَّم',
          body: _body(a, childName),
          payload: 'assignment:${a.id}',
        );
    try {
      await scheduleWith(exact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle);
    } catch (_) {
      await scheduleWith(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  Future<void> _cancel(int id) async {
    try {
      await _plugin.cancel(id: id);
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // مزامنة التذكيرات الافتراضية والمخصصة مع قائمة الواجبات

  /// يُستدعى كلما تغيّرت الواجبات أو الإعدادات أو قائمة الأبناء.
  /// [childNames]: studentId -> الاسم
  Future<void> sync({
    required List<Assignment> assignments,
    required HomeworkReminderSettings settings,
    required Map<String, String> childNames,
  }) {
    return _serial(() async {
      if (!await _ensureReady()) return;
      try {
        final now = DateTime.now();
        final prefs = await SharedPreferences.getInstance();

        // تواريخ النشر لفتح الواجب الصحيح عند الضغط على الإشعار
        final dates = <String, String>{
          for (final a in assignments) a.id: DateFormat('yyyy-MM-dd').format(a.date),
        };
        await prefs.setString(_datesKey, jsonEncode(dates));

        // 1) التذكيرات الافتراضية: نحسب المطلوب ثم نلغي كل ما سواه في نطاقها
        final desired = <int, (DateTime, Assignment)>{};
        if (settings.enabled) {
          for (final a in assignments) {
            if (!isReminderEligible(a)) continue;
            final at = defaultReminderTime(a.dueDate, settings);
            if (!at.isAfter(now)) continue; // لا نجدول في الماضي
            desired[defaultIdFor(a.id)] = (at, a);
          }
        }

        final pendingIds = <int>{};
        try {
          final pending = await _plugin.pendingNotificationRequests();
          pendingIds.addAll(pending.map((p) => p.id));
        } catch (_) {}

        for (final id in pendingIds) {
          if (id >= _defaultBase && id < _customBase && !desired.containsKey(id)) {
            await _cancel(id);
          }
        }
        for (final entry in desired.entries) {
          final (at, a) = entry.value;
          try {
            await _schedule(entry.key, at, a, childNames[a.studentId] ?? '');
          } catch (e) {
            debugPrint('[HomeworkReminder] schedule failed for ${a.id}: $e');
          }
        }

        // 2) التذكيرات المخصصة: نلغي ما سُلِّم أو مضى وقته، ونعيد جدولة الباقي
        final custom = await _readCustom(prefs);
        final byId = {for (final a in assignments) a.id: a};
        var changed = false;
        for (final subId in custom.keys.toList()) {
          final at = custom[subId]!;
          final a = byId[subId];
          if ((a != null && _isSubmitted(a.status)) || !at.isAfter(now)) {
            await _cancel(customIdFor(subId));
            custom.remove(subId);
            changed = true;
            continue;
          }
          // واجب غير موجود في القائمة (لم تُحمَّل بعد): نترك الجدولة كما هي
          if (a == null) continue;
          try {
            await _schedule(customIdFor(subId), at, a, childNames[a.studentId] ?? '');
          } catch (e) {
            debugPrint('[HomeworkReminder] custom schedule failed for $subId: $e');
          }
        }
        if (changed) await _writeCustom(prefs, custom);

        debugPrint('[HomeworkReminder] synced: ${desired.length} default, ${custom.length} custom');
      } catch (e) {
        debugPrint('[HomeworkReminder] sync failed: $e');
      }
    });
  }

  /// جدولة تذكير مخصص لواجب محدد. يُرجع false إن تعذّرت الجدولة.
  Future<bool> scheduleCustom({
    required Assignment assignment,
    required DateTime at,
    required String childName,
  }) {
    return _serial(() async {
      if (!at.isAfter(DateTime.now())) return false;
      if (!await _ensureReady()) return false;
      await _ensureExactPermission();
      try {
        await _schedule(customIdFor(assignment.id), at, assignment, childName);
        final prefs = await SharedPreferences.getInstance();
        final custom = await _readCustom(prefs);
        custom[assignment.id] = at;
        await _writeCustom(prefs, custom);
        final dates = _readDates(prefs);
        dates[assignment.id] = DateFormat('yyyy-MM-dd').format(assignment.date);
        await prefs.setString(_datesKey, jsonEncode(dates));
        return true;
      } catch (e) {
        debugPrint('[HomeworkReminder] scheduleCustom failed: $e');
        return false;
      }
    });
  }

  /// وقت التذكير المخصص المحفوظ لواجب (إن وُجد ولم يمضِ)
  Future<DateTime?> customReminderFor(String submissionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final at = (await _readCustom(prefs))[submissionId];
      if (at != null && at.isAfter(DateTime.now())) return at;
    } catch (_) {}
    return null;
  }

  /// عند تسجيل الخروج: إلغاء كل تذكيرات الواجبات وحذف المخصصة
  Future<void> cancelAll() {
    return _serial(() async {
      if (kIsWeb) return;
      try {
        final pending = await _plugin.pendingNotificationRequests();
        for (final p in pending) {
          if (isReminderNotificationId(p.id)) await _cancel(p.id);
        }
      } catch (_) {}
      try {
        final prefs = await SharedPreferences.getInstance();
        final custom = await _readCustom(prefs);
        for (final subId in custom.keys) {
          await _cancel(customIdFor(subId));
        }
        await prefs.remove(_customKey);
        await prefs.remove(_datesKey);
      } catch (_) {}
    });
  }

  /// مسار فتح الواجب من إشعار التذكير: `/assignments?date=YYYY-MM-DD&id=<submissionId>`
  static Future<String> routeForSubmission(String submissionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final date = _readDates(prefs)[submissionId];
      if (date != null && date.isNotEmpty) {
        return Uri(path: '/assignments', queryParameters: {'date': date, 'id': submissionId}).toString();
      }
    } catch (_) {}
    return Uri(path: '/assignments', queryParameters: {'id': submissionId}).toString();
  }

  static Map<String, String> _readDates(SharedPreferences prefs) {
    try {
      final raw = prefs.getString(_datesKey);
      if (raw == null) return {};
      return (jsonDecode(raw) as Map).map((k, v) => MapEntry(k.toString(), v.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, DateTime>> _readCustom(SharedPreferences prefs) async {
    try {
      final raw = prefs.getString(_customKey);
      if (raw == null) return {};
      final map = jsonDecode(raw) as Map;
      final result = <String, DateTime>{};
      map.forEach((k, v) {
        final d = DateTime.tryParse(v.toString());
        if (d != null) result[k.toString()] = d;
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeCustom(SharedPreferences prefs, Map<String, DateTime> custom) async {
    await prefs.setString(
      _customKey,
      jsonEncode(custom.map((k, v) => MapEntry(k, v.toIso8601String()))),
    );
  }
}
