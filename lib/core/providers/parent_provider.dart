import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'parent_provider.g.dart';

class ParentProfile {
  final String id;
  final String name;
  final String phoneNumber;
  final String? avatarUrl;

  ParentProfile({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.avatarUrl,
  });
}

@riverpod
ParentProfile currentParent(Ref ref) {
  return ParentProfile(
    id: 'p1',
    name: 'محمد عبدالله',
    phoneNumber: '+966500000000',
  );
}
