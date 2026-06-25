// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currentParent)
final currentParentProvider = CurrentParentProvider._();

final class CurrentParentProvider
    extends $FunctionalProvider<ParentProfile, ParentProfile, ParentProfile>
    with $Provider<ParentProfile> {
  CurrentParentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentParentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentParentHash();

  @$internal
  @override
  $ProviderElement<ParentProfile> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ParentProfile create(Ref ref) {
    return currentParent(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParentProfile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParentProfile>(value),
    );
  }
}

String _$currentParentHash() => r'5272d6ca09ffc2e6abaa7f7560f7c43003640b31';
