// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'children_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChildrenLoading)
final childrenLoadingProvider = ChildrenLoadingProvider._();

final class ChildrenLoadingProvider
    extends $NotifierProvider<ChildrenLoading, bool> {
  ChildrenLoadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'childrenLoadingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$childrenLoadingHash();

  @$internal
  @override
  ChildrenLoading create() => ChildrenLoading();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$childrenLoadingHash() => r'1be73967547eaae616f98729702cbd9479c28ffd';

abstract class _$ChildrenLoading extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Children)
final childrenProvider = ChildrenProvider._();

final class ChildrenProvider
    extends $NotifierProvider<Children, List<Student>> {
  ChildrenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'childrenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$childrenHash();

  @$internal
  @override
  Children create() => Children();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Student> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Student>>(value),
    );
  }
}

String _$childrenHash() => r'42b25cbb384326bb925b6e66289991671fd7ffb7';

abstract class _$Children extends $Notifier<List<Student>> {
  List<Student> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Student>, List<Student>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Student>, List<Student>>,
              List<Student>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CurrentChild)
final currentChildProvider = CurrentChildProvider._();

final class CurrentChildProvider
    extends $NotifierProvider<CurrentChild, Student?> {
  CurrentChildProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentChildProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentChildHash();

  @$internal
  @override
  CurrentChild create() => CurrentChild();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Student? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Student?>(value),
    );
  }
}

String _$currentChildHash() => r'99e6e93b2c8b48e7a9a2101aa80a51b084653a50';

abstract class _$CurrentChild extends $Notifier<Student?> {
  Student? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Student?, Student?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Student?, Student?>,
              Student?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
