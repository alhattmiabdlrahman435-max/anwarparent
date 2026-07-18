
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/providers/parent_provider.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<void> build() {}

  Future<bool> uploadAvatar(String path) async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(apiClientProvider);
      final parent = ref.read(currentParentProvider);
      
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          path,
          filename: path.split('/').last,
        ),
      });

      final response = await dio.post(ApiRoutes.updatePhoto, data: formData);

      if (response.data != null && response.data['success'] == true) {
        final newUrl = response.data['photo_url'];
        await ref.read(currentParentProvider.notifier).setProfile(
          id: parent.id,
          name: parent.name,
          phoneNumber: parent.phoneNumber,
          nationalId: parent.nationalId,
          avatarUrl: newUrl,
        );
        state = const AsyncValue.data(null);
        return true;
      }
      state = AsyncValue.error('Failed to upload', StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> saveDetails({required String name, required String phone}) async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(apiClientProvider);
      final parent = ref.read(currentParentProvider);

      final response = await dio.put(ApiRoutes.updateParent(parent.id), data: {
        'name_ar': name,
        'phone': phone,
      });

      if (response.data != null && response.data['success'] == true) {
        final updatedParent = response.data['parent'];
        await ref.read(currentParentProvider.notifier).setProfile(
          id: parent.id,
          name: updatedParent['name_ar'] ?? name,
          phoneNumber: updatedParent['phone'] ?? phone,
          nationalId: parent.nationalId,
          avatarUrl: parent.avatarUrl,
        );
        state = const AsyncValue.data(null);
        return true;
      }
      state = AsyncValue.error('Failed to update', StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.post(ApiRoutes.updatePassword, data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      });

      if (response.data != null && response.data['success'] == true) {
        state = const AsyncValue.data(null);
        return null; // success (no error message)
      } else {
        final errorMsg = response.data['message'] ?? 'فشل تغيير كلمة المرور';
        state = AsyncValue.error(errorMsg, StackTrace.current);
        return errorMsg;
      }
    } catch (e, st) {
      const fallbackError = 'كلمة المرور الحالية غير صحيحة';
      state = AsyncValue.error(fallbackError, st);
      return fallbackError;
    }
  }
}
