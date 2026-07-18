// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AttendanceData)
final attendanceDataProvider = AttendanceDataProvider._();

final class AttendanceDataProvider
    extends $AsyncNotifierProvider<AttendanceData, List<AttendanceRecord>> {
  AttendanceDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceDataHash();

  @$internal
  @override
  AttendanceData create() => AttendanceData();
}

String _$attendanceDataHash() => r'6fc446b0b928b37375e28a91e9e91cebe77b290c';

abstract class _$AttendanceData extends $AsyncNotifier<List<AttendanceRecord>> {
  FutureOr<List<AttendanceRecord>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<AttendanceRecord>>, List<AttendanceRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AttendanceRecord>>,
                List<AttendanceRecord>
              >,
              AsyncValue<List<AttendanceRecord>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
