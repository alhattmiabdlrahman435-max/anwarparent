import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/parent_profile.dart';

part 'parent_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentParent extends _$CurrentParent {
  final _storage = const FlutterSecureStorage();

  @override
  ParentProfile build() {
    _loadFromStorage();
    return ParentProfile(
      id: '',
      name: '',
      phoneNumber: '',
      nationalId: '',
    );
  }

  Future<void> _loadFromStorage() async {
    final id = await _storage.read(key: 'parent_id') ?? '';
    final name = await _storage.read(key: 'parent_name') ?? '';
    final phone = await _storage.read(key: 'parent_phone') ?? '';
    final nationalId = await _storage.read(key: 'parent_national_id') ?? '';
    final avatar = await _storage.read(key: 'parent_avatar');
    
    if (ref.mounted) {
      state = ParentProfile(
        id: id,
        name: name,
        phoneNumber: phone,
        nationalId: nationalId,
        avatarUrl: avatar,
      );
    }
  }

  Future<void> setProfile({
    required String id,
    required String name,
    required String phoneNumber,
    required String nationalId,
    String? avatarUrl,
  }) async {
    await _storage.write(key: 'parent_id', value: id);
    await _storage.write(key: 'parent_name', value: name);
    await _storage.write(key: 'parent_phone', value: phoneNumber);
    await _storage.write(key: 'parent_national_id', value: nationalId);
    if (avatarUrl != null) {
      await _storage.write(key: 'parent_avatar', value: avatarUrl);
    } else {
      await _storage.delete(key: 'parent_avatar');
    }
    
    if (ref.mounted) {
      state = ParentProfile(
        id: id,
        name: name,
        phoneNumber: phoneNumber,
        nationalId: nationalId,
        avatarUrl: avatarUrl,
      );
    }
  }

  Future<void> clearProfile() async {
    await _storage.delete(key: 'parent_id');
    await _storage.delete(key: 'parent_name');
    await _storage.delete(key: 'parent_phone');
    await _storage.delete(key: 'parent_national_id');
    await _storage.delete(key: 'parent_avatar');
    
    if (ref.mounted) {
      state = ParentProfile(
        id: '',
        name: '',
        phoneNumber: '',
        nationalId: '',
      );
    }
  }
}
