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
    extends $NotifierProvider<AttendanceData, List<AttendanceRecord>> {
  AttendanceDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attendanceDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attendanceDataHash();

  @$internal
  @override
  AttendanceData create() => AttendanceData();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AttendanceRecord> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AttendanceRecord>>(value),
    );
  }
}

String _$attendanceDataHash() => r'8a4a3c0d8219f42aa12c7f6bcd474df4f6dadb4a';

abstract class _$AttendanceData extends $Notifier<List<AttendanceRecord>> {
  List<AttendanceRecord> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<List<AttendanceRecord>, List<AttendanceRecord>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<AttendanceRecord>, List<AttendanceRecord>>,
              List<AttendanceRecord>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
