import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/app_notification.dart';
import '../network/api_client.dart';
import '../services/badge_service.dart';
import 'parent_provider.dart';

part 'notifications_provider.g.dart';

@Riverpod(keepAlive: true)
class Notifications extends _$Notifications {
  String? _loadedParentId;

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
    return _loadNotifications();
  }

  Future<List<AppNotification>> _loadNotifications() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('notifications');

      if (!ref.mounted) return [];

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['notifications'] ?? [];
        final parsed = list.map((json) => AppNotification.fromJson(json)).toList();

        final unreadCount = parsed.where((n) => !n.isRead).length;
        BadgeService.setBadge(unreadCount);

        return parsed;
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
        final updatedList = [
          for (final notif in currentList)
            if (notif.id == id)
              notif.copyWith(isRead: true)
            else
              notif
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
          for (final notif in currentList)
            notif.copyWith(isRead: true)
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
