// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Assignments)
final assignmentsProvider = AssignmentsProvider._();

final class AssignmentsProvider
    extends $NotifierProvider<Assignments, List<Assignment>> {
  AssignmentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assignmentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assignmentsHash();

  @$internal
  @override
  Assignments create() => Assignments();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Assignment> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Assignment>>(value),
    );
  }
}

String _$assignmentsHash() => r'843e97b70ef0b89d6ee3149aedc85750b64620c6';

abstract class _$Assignments extends $Notifier<List<Assignment>> {
  List<Assignment> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Assignment>, List<Assignment>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Assignment>, List<Assignment>>,
              List<Assignment>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
