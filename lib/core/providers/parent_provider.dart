import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/parent_profile.dart';

part 'parent_provider.g.dart';

@riverpod
ParentProfile currentParent(Ref ref) {
  return ParentProfile(
    id: 'p1',
    name: 'محمد عبدالله',
    phoneNumber: '+966500000000',
  );
}
