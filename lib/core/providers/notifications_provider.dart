import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/app_notification.dart';
import '../network/api_client.dart';
import '../network/pusher_service.dart';
import '../services/badge_service.dart';
import 'parent_provider.dart';

part 'notifications_provider.g.dart';

@Riverpod(keepAlive: true)
class Notifications extends _$Notifications {
  static const int _perPage = 20;

  String? _loadedParentId;
  int _currentPage = 0;
  int _lastPage = 1;
  bool _isLoadingMore = false;

  /// هل توجد إشعارات أقدم لم تُحمَّل بعد من الخادم
  bool get hasMore => _currentPage < _lastPage;
  bool get isLoadingMore => _isLoadingMore;

  @override
  FutureOr<List<AppNotification>> build() async {
    final parent = ref.watch(currentParentProvider);
    if (parent.id.isEmpty) {
      _loadedParentId = null;
      return [];
    }
    if (_loadedParentId == parent.id && state.hasValue) {
      return state.requireValue;
    }
    _loadedParentId = parent.id;
    _listenToRealtimeChanges();
    return _loadNotifications();
  }

  bool _realtimeSubscribed = false;

  /// WebSocket (Reverb): عند إرسال الإدارة إشعاراً أو تعديله أو حذفه
  /// نعيد جلب القائمة في نفس اللحظة. الحدث لا يحمل المحتوى، والخادم يُرجع ما يخص ولي الأمر فقط.
  void _listenToRealtimeChanges() {
    if (_realtimeSubscribed) return;
    _realtimeSubscribed = true;
    PusherService().subscribe('public-notifications', 'notifications_changed', (_) {
      if (ref.mounted && _loadedParentId != null) refresh();
    });
  }

  /// يجلب صفحة واحدة من الخادم ويحدّث رقم الصفحة الحالية والأخيرة.
  /// يُرجع null عند الفشل.
  Future<List<AppNotification>?> _fetchPage(int page) async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get(
        'notifications',
        queryParameters: {'page': page, 'per_page': _perPage},
      );

      if (!ref.mounted) return null;

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['notifications'] ?? [];
        _currentPage = (response.data['current_page'] as num?)?.toInt() ?? page;
        _lastPage =
            (response.data['last_page'] as num?)?.toInt() ?? _currentPage;
        return list.map((json) => AppNotification.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading notifications page $page: $e');
    }
    return null;
  }

  Future<List<AppNotification>> _loadNotifications() async {
    _currentPage = 0;
    _lastPage = 1;
    final parsed = await _fetchPage(1);
    if (parsed == null) return [];

    final unreadCount = parsed.where((n) => !n.isRead).length;
    BadgeService.setBadge(unreadCount);

    return parsed;
  }

  /// يحمّل الصفحة التالية (الإشعارات الأقدم) ويضيفها لنهاية القائمة
  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || !state.hasValue) return;
    _isLoadingMore = true;
    try {
      final older = await _fetchPage(_currentPage + 1);
      if (!ref.mounted) return;
      if (older == null) {
        // توقف عن المحاولة التلقائية حتى يسحب المستخدم للتحديث
        _lastPage = _currentPage;
        return;
      }

      final currentList = state.value ?? [];
      final existingIds = currentList.map((n) => n.id).toSet();
      state = AsyncValue.data([
        ...currentList,
        ...older.where((n) => !existingIds.contains(n.id)),
      ]);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.put('notifications/$id/read');

      if (!ref.mounted) return;

      if (response.data != null && response.data['success'] == true) {
        final currentList = state.value ?? [];
        final updatedList = [
          for (final notif in currentList)
            if (notif.id == id) notif.copyWith(isRead: true) else notif,
        ];
        state = AsyncValue.data(updatedList);

        final unreadCount = updatedList.where((n) => !n.isRead).length;
        BadgeService.setBadge(unreadCount);
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.put('notifications/read-all');

      if (!ref.mounted) return;

      if (response.data != null && response.data['success'] == true) {
        final currentList = state.value ?? [];
        final updatedList = [
          for (final notif in currentList) notif.copyWith(isRead: true),
        ];
        state = AsyncValue.data(updatedList);

        BadgeService.clearBadge();
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    if (state.hasValue) {
      final result = await AsyncValue.guard(() => _loadNotifications());
      if (ref.mounted) {
        state = result;
      }
    } else {
      state = const AsyncValue.loading();
      final result = await AsyncValue.guard(() => _loadNotifications());
      if (ref.mounted) {
        state = result;
      }
    }
  }
}
