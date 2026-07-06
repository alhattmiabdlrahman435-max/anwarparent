import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/absence_request.dart';
import '../network/api_client.dart';
import 'parent_provider.dart';

part 'absence_requests_provider.g.dart';

@riverpod
class AbsenceRequests extends _$AbsenceRequests {
  @override
  FutureOr<List<AbsenceRequest>> build() async {
    return _loadRequests();
  }

  Future<List<AbsenceRequest>> _loadRequests() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('absence-requests');
      
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['absence_requests'] ?? [];
        return list.map((json) => AbsenceRequest.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading absence requests: $e');
    }
    return [];
  }

  Future<bool> addRequest(AbsenceRequest request) async {
    try {
      final dio = ref.read(apiClientProvider);
      
      // Try provider state first, then fall back to secure storage
      var parentId = ref.read(currentParentProvider).id;
      if (parentId.isEmpty) {
        const storage = FlutterSecureStorage();
        parentId = await storage.read(key: 'parent_id') ?? '';
      }

      if (parentId.isEmpty) {
        debugPrint('Error: parent_id is empty, cannot submit absence request');
        return false;
      }
      
      final response = await dio.post(
        'absence-requests',
        data: request.toJson(parentId),
      );

      if (response.data != null && response.data['success'] == true) {
        // Reload state to show the new request from database
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() => _loadRequests());
        return true;
      }
    } catch (e) {
      debugPrint('Error adding absence request: $e');
    }
    return false;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadRequests());
  }
}
