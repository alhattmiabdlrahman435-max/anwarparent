import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/providers/parent_provider.dart';
import '../../../../core/providers/children_provider.dart';
import '../../../../core/providers/attendance_provider.dart';
import '../../../../core/providers/assignments_provider.dart';
import '../../../../core/providers/grades_provider.dart';
import '../../../../core/providers/schedule_provider.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../../../core/providers/notifications_provider.dart';

import '../../../../core/services/badge_service.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  String? _cachedToken;

  @override
  FutureOr<bool> build() async {
    // Listen to token refresh to sync it dynamically
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      _syncToken(fcmToken);
    });

    try {
      final token = await _storage.read(key: _tokenKey);
      _cachedToken = token;
      final isLoggedIn = token != null && token.isNotEmpty;
      if (isLoggedIn) {
        Future.microtask(() => syncFcmToken());
      }
      return isLoggedIn;
    } catch (e) {
      debugPrint('Error reading auth_token from secure storage: $e');
      // Do NOT call _storage.deleteAll() on temporary read errors to avoid wiping session!
      return _cachedToken != null && _cachedToken!.isNotEmpty;
    }
  }

  Future<void> _syncToken(String fcmToken) async {
    try {
      final isLoggedIn = state.value ?? false;
      if (!isLoggedIn) return;

      final dio = ref.read(apiClientProvider);
      await dio.post(ApiRoutes.updateFcmToken, data: {
        'fcm_token': fcmToken,
      });
      if (kDebugMode) {
        debugPrint('FCM Token synced to backend successfully via refresh.');
      }
    } catch (e) {
      debugPrint('Error syncing FCM Token to backend on refresh: $e');
    }
  }

  Future<void> syncFcmToken() async {
    try {
      final dio = ref.read(apiClientProvider);

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        
        if (apnsToken == null && !kReleaseMode) {
          debugPrint('iOS Simulator/Debug detected: APNS token is null (Push Notifications are only supported on physical iOS devices).');
        } else {
          int retries = 0;
          // Wait up to 15 seconds for APNS token
          while (apnsToken == null && retries < 15) {
            await Future.delayed(const Duration(seconds: 1));
            apnsToken = await FirebaseMessaging.instance.getAPNSToken();
            retries++;
          }
        }
        
        if (apnsToken == null && kReleaseMode) {
          debugPrint('FCM Token Sync: APNS token is null. Skipping FCM registration.');
          return;
        }
      }

      String? fcmToken = await FirebaseMessaging.instance.getToken();
      int fcmRetries = 0;
      while (fcmToken == null && fcmRetries < 5) {
        await Future.delayed(const Duration(seconds: 1));
        fcmToken = await FirebaseMessaging.instance.getToken();
        fcmRetries++;
      }

      if (fcmToken != null) {
        await dio.post(ApiRoutes.updateFcmToken, data: {
          'fcm_token': fcmToken,
        });
        if (kDebugMode) {
          debugPrint('FCM Token synced to backend successfully.');
        }
      } else {
        debugPrint('FCM Token Sync: FCM token is null after retries.');
      }
    } catch (e) {
      debugPrint('Error syncing FCM Token to backend: $e');
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.post(ApiRoutes.login, data: {
        'username': username,
        'password': password,
      });

      if (response.data != null && response.data['success'] == true) {
        final data = response.data;
        final role = data['user']['role'];
        if (role != 'parent') {
          throw Exception('هذا الحساب غير مصرح له بالدخول كتطبيق ولي أمر.');
        }

        final token = data['token'];
        _cachedToken = token;
        await _storage.write(key: _tokenKey, value: token);

        final userData = data['user'];
        final displayName = userData['name_ar'] ?? userData['name'] ?? '';
        final parentId = userData['id']?.toString() ?? '';
        final displayPhoto = userData['photo_url'] ?? userData['photo'] ?? '🧔';
        final nationalId = userData['national_id'] ?? username;
        final actualPhone = userData['phone'] ?? '';
        
        await ref.read(currentParentProvider.notifier).setProfile(
          id: parentId,
          name: displayName,
          phoneNumber: actualPhone,
          nationalId: nationalId,
          avatarUrl: displayPhoto,
        );

        state = const AsyncValue.data(true);
        Future.microtask(() => syncFcmToken());
      } else {
        throw Exception(response.data['message'] ?? 'فشل تسجيل الدخول');
      }
    } catch (e, st) {
      String errorMessage = 'حدث خطأ أثناء تسجيل الدخول';
      if (e is DioException) {
        errorMessage = e.response?.data['message'] ?? 'اسم المستخدم أو كلمة المرور غير صحيحة';
      } else if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      state = AsyncValue.error(errorMessage, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(apiClientProvider);
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final Map<String, dynamic> logoutData = {};
      if (fcmToken != null) {
        logoutData['fcm_token'] = fcmToken;
      }
      // Invalidate Sanctum token and detach FCM token on the backend
      await dio.post(ApiRoutes.logout, data: logoutData);
    } catch (e) {
      debugPrint('Error invalidating token on server: $e');
    } finally {
      // Clear FCM registration token on the device
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (e) {
        debugPrint('Error deleting FCM token on logout: $e');
      }

      // Clear cached badge count
      try {
        await BadgeService.clearBadge();
      } catch (e) {
        debugPrint('Error clearing badge: $e');
      }

      // Always delete local token and set auth state to false (logged out)
      _cachedToken = null;
      await _storage.delete(key: _tokenKey);
      await ref.read(currentParentProvider.notifier).clearProfile();

      // Invalidate all keepAlive providers to clear cached user data
      // This prevents data from the previous user session from leaking
      ref.invalidate(childrenProvider);
      ref.invalidate(attendanceDataProvider);
      ref.invalidate(assignmentsProvider);
      ref.invalidate(gradesProvider);
      ref.invalidate(classSchedulesProvider);
      ref.invalidate(financeProvider);
      ref.invalidate(notificationsProvider);

      state = const AsyncValue.data(false);
    }
  }

  String? get cachedToken => _cachedToken;

  void setCachedToken(String token) {
    _cachedToken = token;
  }
}
