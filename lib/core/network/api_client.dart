import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/constants.dart';

part 'api_client.g.dart';

@riverpod
Dio apiClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add interceptors for auth tokens, logging, etc.
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  return dio;
}
