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
    extends $AsyncNotifierProvider<AbsenceRequests, List<AbsenceRequest>> {
  AbsenceRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'absenceRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$absenceRequestsHash();

  @$internal
  @override
  AbsenceRequests create() => AbsenceRequests();
}

String _$absenceRequestsHash() => r'115d4bbed80d9b2fd29b13bc69d7869c4a955b09';

abstract class _$AbsenceRequests extends $AsyncNotifier<List<AbsenceRequest>> {
  FutureOr<List<AbsenceRequest>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<AbsenceRequest>>, List<AbsenceRequest>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AbsenceRequest>>,
                List<AbsenceRequest>
              >,
              AsyncValue<List<AbsenceRequest>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
