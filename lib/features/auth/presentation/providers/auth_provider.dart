import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/parent_provider.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  @override
  FutureOr<bool> build() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final isLoggedIn = token != null && token.isNotEmpty;
      if (isLoggedIn) {
        Future.microtask(() => syncFcmToken());
      }
      return isLoggedIn;
    } catch (e) {
      // In case of Keystore corruption or platform-specific secure storage read failure,
      // clear the storage and return false (logged out).
      try {
        await _storage.deleteAll();
      } catch (_) {}
      return false;
    }
  }

  Future<void> syncFcmToken() async {
    try {
      final dio = ref.read(apiClientProvider);
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await dio.post('user/fcm-token', data: {
          'fcm_token': fcmToken,
        });
        debugPrint('FCM Token synced to backend successfully: $fcmToken');
      }
    } catch (e) {
      debugPrint('Error syncing FCM Token to backend: $e');
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.post('login', data: {
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
      // Invalidate Sanctum token on the backend
      await dio.post('logout');
    } catch (e) {
      debugPrint('Error invalidating token on server: $e');
    } finally {
      // Always delete local token and set auth state to false (logged out)
      await _storage.delete(key: _tokenKey);
      await ref.read(currentParentProvider.notifier).clearProfile();
      state = const AsyncValue.data(false);
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }
}
