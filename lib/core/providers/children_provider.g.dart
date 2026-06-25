// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'children_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(children)
final childrenProvider = ChildrenProvider._();

final class ChildrenProvider
    extends $FunctionalProvider<List<Student>, List<Student>, List<Student>>
    with $Provider<List<Student>> {
  ChildrenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'childrenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$childrenHash();

  @$internal
  @override
  $ProviderElement<List<Student>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Student> create(Ref ref) {
    return children(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Student> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Student>>(value),
    );
  }
}

String _$childrenHash() => r'bff20e6e3560940cb2d49def27164ca2e3704bd1';

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
        isAutoDispose: true,
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

String _$currentChildHash() => r'12c6f4fc22cef9fa15c128d1fb8facd8fae3a0eb';

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
