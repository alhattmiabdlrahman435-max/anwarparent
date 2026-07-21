import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/constants.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'api_client.g.dart';

@Riverpod(keepAlive: true)
Dio apiClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Upload timeout interceptor: extend timeouts for multipart (file upload) requests.
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final isMultipart = options.data is FormData;
      if (isMultipart) {
        options.receiveTimeout = const Duration(seconds: 120);
        options.sendTimeout    = const Duration(seconds: 120);
      }
      handler.next(options);
    },
  ));

  // Interceptor to inject auth tokens
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        var token = ref.read(authProvider.notifier).cachedToken;
        if (token == null || token.isEmpty) {
          try {
            token = await const FlutterSecureStorage().read(key: 'auth_token');
            if (token != null && token.isNotEmpty) {
              ref.read(authProvider.notifier).setCachedToken(token);
            }
          } catch (e) {
            debugPrint('Error reading auth_token in api_client: $e');
          }
        }
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401 &&
            !e.requestOptions.path.contains('login') &&
            !e.requestOptions.path.contains('logout')) {
          final authHeader = e.requestOptions.headers['Authorization'];
          if (authHeader != null && authHeader.toString().isNotEmpty) {
            // Trigger logout only if a token was sent and explicit 401 was returned
            debugPrint('[ApiClient] 401 Unauthorized with valid token header. Logging out...');
            ref.read(authProvider.notifier).logout();
          } else {
            debugPrint('[ApiClient] 401 received without Authorization header. Skipping automatic logout.');
          }
        }

        // Global Error Mapping
        String? friendlyMessage;
        if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
          friendlyMessage = 'انتهى وقت الاتصال. يرجى المحاولة مرة أخرى.';
        } else if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.unknown) {
          friendlyMessage = 'لا يوجد اتصال بالإنترنت.';
        } else if (e.response?.statusCode == 500) {
          friendlyMessage = 'حدث خطأ في الخادم (500). يرجى المحاولة لاحقاً.';
        }
        
        if (friendlyMessage != null) {
          final newError = DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: friendlyMessage,
            message: friendlyMessage,
          );
          return handler.next(newError);
        }

        return handler.next(e);
      },
    ),
  );

  // Add interceptors for logging only in debug mode
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  return dio;
}
