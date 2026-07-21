
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_routes.dart';
import '../../../../core/providers/parent_provider.dart';
import '../../../../core/services/image_compress_service.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  bool _isUploading = false; // debounce guard

  @override
  FutureOr<void> build() {}

  /// [onProgress] is called with values 0.0 → 1.0 during upload.
  Future<bool> uploadAvatar(
    File imageFile, {
    void Function(double progress)? onProgress,
  }) async {
    // Prevent duplicate concurrent uploads
    if (_isUploading) return false;
    _isUploading = true;
    state = const AsyncValue.loading();

    try {
      // ── 1. Compress & validate ──────────────────────────────────────────────
      final result = await ImageCompressService.compress(imageFile);

      // ── 2. Build multipart request ──────────────────────────────────────────
      final dio    = ref.read(apiClientProvider);
      final parent = ref.read(currentParentProvider);

      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          result.file.path,
          filename: '${parent.id}_avatar.jpg',
        ),
      });

      // ── 3. Upload with progress callback ───────────────────────────────────
      final response = await dio.post(
        ApiRoutes.updatePhoto,
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) onProgress?.call(sent / total);
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final newUrl = response.data['photo_url'] as String?;
        await ref.read(currentParentProvider.notifier).setProfile(
          id:          parent.id,
          name:        parent.name,
          phoneNumber: parent.phoneNumber,
          nationalId:  parent.nationalId,
          avatarUrl:   newUrl,
        );
        state = const AsyncValue.data(null);
        return true;
      }

      final msg = response.data?['message'] ?? 'فشل رفع الصورة';
      state = AsyncValue.error(msg, StackTrace.current);
      return false;

    } on ImageValidationException catch (e) {
      // Validation error — do NOT suggest retry (file won't change)
      state = AsyncValue.error(e.message, StackTrace.current);
      return false;

    } on DioException catch (e, st) {
      // Network or server error — retry is meaningful
      final isServerValidation = e.response?.statusCode == 422;
      final msg = isServerValidation
          ? _extract422Message(e)
          : 'تعذّر رفع الصورة. تحقق من الاتصال وأعد المحاولة.';
      state = AsyncValue.error(msg, st);
      return false;

    } catch (e, st) {
      state = AsyncValue.error('حدث خطأ غير متوقع أثناء الرفع.', st);
      return false;

    } finally {
      _isUploading = false;
    }
  }

  String _extract422Message(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      return errors.values
          .map((v) => v is List ? v.join(', ') : v.toString())
          .join('\n');
    }
    return data?['message'] ?? 'البيانات المرسلة غير صحيحة.';
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
      String errorMessage = 'كلمة المرور الحالية غير صحيحة';
      if (e is DioException) {
        final data = e.response?.data;
        if (data != null && data is Map) {
          if (data['errors'] != null && data['errors'] is Map) {
            final errors = data['errors'] as Map;
            errorMessage = errors.values.map((v) => v is List ? v.join(', ') : v.toString()).join('\n');
          } else {
            errorMessage = data['message'] ?? errorMessage;
          }
        }
      }
      state = AsyncValue.error(errorMessage, st);
      return errorMessage;
    }
  }
}
