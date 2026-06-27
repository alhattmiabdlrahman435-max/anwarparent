import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  @override
  FutureOr<bool> build() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      // Simulate API call for login
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // In a real app, you would get a token from the backend
      final fakeToken = 'simulated_secure_token_${DateTime.now().millisecondsSinceEpoch}';
      
      await _storage.write(key: _tokenKey, value: fakeToken);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _storage.delete(key: _tokenKey);
      state = const AsyncValue.data(false);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
}
