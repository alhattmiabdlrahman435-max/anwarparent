import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/app_notification.dart';
import '../network/api_client.dart';

part 'notifications_provider.g.dart';

@Riverpod(keepAlive: true)
class Notifications extends _$Notifications {
  @override
  FutureOr<List<AppNotification>> build() async {
    // FCM foreground listening is centralized in main.dart (_ParentAppState).
    // It calls ref.invalidate(notificationsProvider) when a notification arrives,
    // which triggers a rebuild of this provider automatically.
    return _loadNotifications();
  }

  Future<List<AppNotification>> _loadNotifications() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('notifications');

      if (!ref.mounted) return [];

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['notifications'] ?? [];
        return list.map((json) => AppNotification.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
    return [];
  }

  Future<void> markAsRead(String id) async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.put('notifications/$id/read');

      if (!ref.mounted) return;

      if (response.data != null && response.data['success'] == true) {
        final currentList = state.value ?? [];
        state = AsyncValue.data([
          for (final notif in currentList)
            if (notif.id == id)
              notif.copyWith(isRead: true)
            else
              notif
        ]);
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
        state = AsyncValue.data([
          for (final notif in currentList)
            notif.copyWith(isRead: true)
        ]);
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadNotifications());
  }
}
