// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absence_requests_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AbsenceRequests)
final absenceRequestsProvider = AbsenceRequestsProvider._();

final class AbsenceRequestsProvider
    extends $NotifierProvider<AbsenceRequests, List<AbsenceRequest>> {
  AbsenceRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'absenceRequestsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$absenceRequestsHash();

  @$internal
  @override
  AbsenceRequests create() => AbsenceRequests();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AbsenceRequest> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AbsenceRequest>>(value),
    );
  }
}

String _$absenceRequestsHash() => r'102a061ce92afdc586886cfc69708b107da3048f';

abstract class _$AbsenceRequests extends $Notifier<List<AbsenceRequest>> {
  List<AbsenceRequest> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<AbsenceRequest>, List<AbsenceRequest>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<AbsenceRequest>, List<AbsenceRequest>>,
              List<AbsenceRequest>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
