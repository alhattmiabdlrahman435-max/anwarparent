// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentParent)
final currentParentProvider = CurrentParentProvider._();

final class CurrentParentProvider
    extends $NotifierProvider<CurrentParent, ParentProfile> {
  CurrentParentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentParentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentParentHash();

  @$internal
  @override
  CurrentParent create() => CurrentParent();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ParentProfile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ParentProfile>(value),
    );
  }
}

String _$currentParentHash() => r'5bfc1e6797bc343b0de00646606bce9100e052b5';

abstract class _$CurrentParent extends $Notifier<ParentProfile> {
  ParentProfile build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ParentProfile, ParentProfile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ParentProfile, ParentProfile>,
              ParentProfile,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
